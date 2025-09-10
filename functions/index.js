const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

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
    snapshot.forEach((doc) => {
      const data = doc.data();
      const subFor = data.subFor;
      const subStartRaw = data.subStartDate;
      if (!subFor || !subStartRaw) {
        return;
      }
      const subStart = subStartRaw.toDate ? subStartRaw.toDate() : new Date(subStartRaw);
      const expiry = new Date(subStart);
      expiry.setDate(expiry.getDate() + subFor);
      if (expiry < now) {
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
