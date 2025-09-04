class Party {
  String? docId;
  final String name;
  final String phone;
  final String address;
  final String lawyerId;
  final String? photoUrl;
  final bool isSendSms;

  // Constructor
  Party({
    this.docId,
    required this.name,
    required this.phone,
    required this.address,
    required this.lawyerId, // Include the new field in the constructor
    this.photoUrl,
    this.isSendSms = true,
  });

  // Method to convert Party object to a Map (for example, to store in a database)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'lawyerId': lawyerId, // Include the new field in the map
      'photoUrl': photoUrl,
      'isSendSms': isSendSms,
    // Include dynamic fields in the map
    };
  }

  // Method to create a Party object from a Map (for example, when retrieving from a database)
  factory Party.fromMap(Map<String, dynamic> map, {String? docId}) {
    Party party = Party(
      docId: docId,
      name: map['name'],
      phone: map['phone'],
      address: map['address'],
      lawyerId: map['lawyerId'], // Extract the new field from the map
      photoUrl: map['photoUrl'],
      isSendSms: map['isSendSms'] ?? true,
    );

    return party;
  }



}
