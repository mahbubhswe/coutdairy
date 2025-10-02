const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const TIME_ZONE = 'Asia/Dhaka';
const DHAKA_OFFSET_MINUTES = 6 * 60; // Bangladesh follows UTC+6 without DST
const BULK_SMS_URL = 'https://bulksmsbd.net/api/smsapi';

const toTomorrowUtcRangeForDhaka = () => {
  const nowUtc = new Date();
  const nowDhaka = new Date(nowUtc.getTime() + DHAKA_OFFSET_MINUTES * 60 * 1000);
  const startDhaka = new Date(nowDhaka);
  startDhaka.setUTCDate(startDhaka.getUTCDate() + 1);
  startDhaka.setUTCHours(0, 0, 0, 0);
  const endDhaka = new Date(startDhaka);
  endDhaka.setUTCHours(23, 59, 59, 999);
  return {
    startUtc: new Date(startDhaka.getTime() - DHAKA_OFFSET_MINUTES * 60 * 1000),
    endUtc: new Date(endDhaka.getTime() - DHAKA_OFFSET_MINUTES * 60 * 1000),
  };
};

const formatDateInDhaka = (date) => {
  const options = { timeZone: TIME_ZONE, year: 'numeric', month: 'long', day: 'numeric' };
  try {
    return new Intl.DateTimeFormat('bn-BD', options).format(date);
  } catch (err) {
    return new Intl.DateTimeFormat('en-GB', options).format(date);
  }
};

const normalizePhone = (raw) => {
  if (!raw) {
    return null;
  }
  const digits = String(raw).replace(/\D/g, '');
  if (digits.length === 11 && digits.startsWith('01')) {
    return digits;
  }
  if (digits.length === 13 && digits.startsWith('8801')) {
    return digits.slice(2);
  }
  if (digits.length === 14 && digits.startsWith('88001')) {
    return digits.slice(3);
  }
  return null;
};

const sendSmsViaBulk = async ({ apiKey, senderId, phone, message }) => {
  const url = new URL(BULK_SMS_URL);
  url.searchParams.set('api_key', apiKey);
  url.searchParams.set('type', 'text');
  url.searchParams.set('number', phone.startsWith('88') ? phone : `88${phone}`);
  url.searchParams.set('senderid', senderId);
  url.searchParams.set('message', message);

  try {
    const response = await fetch(url.toString());
    const data = await response.json();
    if (data && Number(data.response_code) === 202) {
      return true;
    }
    functions.logger.warn('SMS provider rejected request', { phone, response: data });
    return false;
  } catch (error) {
    functions.logger.error('Failed to call SMS provider', { phone, error });
    return false;
  }
};

const getSmsConfig = async (db) => {
  const configDocId = process.env.APP_CONFIG_ID || functions.config().app?.config_id || '7Wv3FSb5VOsWLtjzmpbl';
  const snap = await db.collection('appConfig').doc(configDocId).get();
  if (!snap.exists) {
    functions.logger.error('App config document missing', { configDocId });
    return null;
  }
  const data = snap.data();
  if (!data?.smsApiKey || !data?.smsSenderId) {
    functions.logger.error('SMS credentials missing in app config', { configDocId });
    return null;
  }
  return {
    apiKey: data.smsApiKey,
    senderId: data.smsSenderId,
  };
};

exports.deactivateExpiredLawyers = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('Asia/Dhaka')
  .onRun(async () => {
    const db = admin.firestore();
    const now = new Date();
    const snapshot = await db
      .collection('lawyers')
      .where('isActive', '==', true)
      .get();

    const batch = db.batch();
    const tokens = [];
    const toDate = (value) => {
      if (!value) {
        return null;
      }
      const dateValue = typeof value.toDate === 'function' ? value.toDate() : new Date(value);
      return Number.isNaN(dateValue.getTime()) ? null : dateValue;
    };

    snapshot.forEach((doc) => {
      const data = doc.data();
      const subStart = toDate(data.subStartsAt);
      const subEnd = toDate(data.subEndsAt);
      if (!subStart || !subEnd) {
        return;
      }
      if (subStart > now) {
        return;
      }
      if (subEnd <= now) {
        batch.update(doc.ref, { isActive: false });
        if (data.fcmToken) {
          tokens.push(data.fcmToken);
        }
      }
    });
    await batch.commit();

    if (tokens.length > 0) {
      await admin.messaging().sendEachForMulticast({
        tokens,
        notification: {
          title: 'Account Deactivated',
          body: 'Your subscription has expired and your account has been deactivated.',
        },
      });
    }
    return null;
  });

exports.sendTomorrowCaseSms = functions.pubsub
  .schedule('0 16 * * *')
  .timeZone(TIME_ZONE)
  .onRun(async () => {
    const db = admin.firestore();
    const smsConfig = await getSmsConfig(db);
    if (!smsConfig) {
      return null;
    }

    const { startUtc, endUtc } = toTomorrowUtcRangeForDhaka();
    const startTimestamp = admin.firestore.Timestamp.fromDate(startUtc);
    const endTimestamp = admin.firestore.Timestamp.fromDate(endUtc);

    const lawyersSnapshot = await db
      .collection('lawyers')
      .where('isActive', '==', true)
      .get();

    let totalSent = 0;

    for (const lawyerDoc of lawyersSnapshot.docs) {
      const lawyerData = lawyerDoc.data();
      const smsBalance = Number(lawyerData.smsBalance) || 0;
      if (smsBalance <= 0) {
        continue;
      }

      const partiesSnapshot = await lawyerDoc.ref
        .collection('parties')
        .where('isSendSms', '==', true)
        .get();

      const allowedPhones = new Set();
      partiesSnapshot.forEach((partyDoc) => {
        const normalizedPartyPhone = normalizePhone(partyDoc.data()?.phone);
        if (normalizedPartyPhone) {
          allowedPhones.add(normalizedPartyPhone);
        }
      });

      if (allowedPhones.size === 0) {
        continue;
      }

      const casesSnapshot = await lawyerDoc.ref
        .collection('cases')
        .where('nextHearingDate', '>=', startTimestamp)
        .where('nextHearingDate', '<=', endTimestamp)
        .get();

      if (casesSnapshot.empty) {
        continue;
      }

      let remainingBalance = smsBalance;
      let sentForLawyer = 0;

      for (const caseDoc of casesSnapshot.docs) {
        if (remainingBalance <= 0) {
          break;
        }

        const caseData = caseDoc.data();
        const hearingTimestamp = caseData.nextHearingDate;
        if (!hearingTimestamp?.toDate) {
          continue;
        }
        const hearingDate = hearingTimestamp.toDate();
        const caseTitle = caseData.caseTitle || caseData.caseNumber || 'আপনার মামলা';

        const recipients = [];
        const plaintiff = caseData.plaintiff;
        if (plaintiff) {
          recipients.push({
            role: 'plaintiff',
            name: plaintiff.name,
            phone: plaintiff.phone,
          });
        }
        const defendant = caseData.defendant;
        if (defendant) {
          recipients.push({
            role: 'defendant',
            name: defendant.name,
            phone: defendant.phone,
          });
        }

        for (const recipient of recipients) {
          if (remainingBalance <= 0) {
            break;
          }
          const normalizedPhone = normalizePhone(recipient.phone);
          if (!normalizedPhone) {
            functions.logger.warn('Skipping SMS for invalid phone', {
              lawyerId: lawyerDoc.id,
              caseId: caseDoc.id,
              phone: recipient.phone,
              role: recipient.role,
            });
            continue;
          }

          if (!allowedPhones.has(normalizedPhone)) {
            continue;
          }

          const contactLine = lawyerData.phone
            ? `${lawyerData.phone} নম্বরে যোগাযোগ করুন।`
            : 'অ্যাপে বিস্তারিত দেখুন।';
          const message = `আগামীকাল (${formatDateInDhaka(hearingDate)}) আপনার মামলা "${caseTitle}" এর শুনানি নির্ধারিত আছে। ${contactLine}`;
          const success = await sendSmsViaBulk({
            apiKey: smsConfig.apiKey,
            senderId: smsConfig.senderId,
            phone: normalizedPhone,
            message,
          });

          if (success) {
            sentForLawyer += 1;
            totalSent += 1;
            remainingBalance -= 1;
          }
        }
      }

      if (sentForLawyer > 0) {
        await lawyerDoc.ref.update({
          smsBalance: admin.firestore.FieldValue.increment(-sentForLawyer),
        });
      }
    }

    functions.logger.info('sendTomorrowCaseSms completed', { totalSent });
    return null;
  });
