class CommercialUser {
  String hyperlink;
  String businessId;
  String profilePicture;
  String name;
  String description;

  CommercialUser({
    required this.name,
    required this.profilePicture,
    required this.hyperlink,
    required this.businessId,
    required this.description,
  });

  factory CommercialUser.fromMap(Map<String, dynamic> map) {
    return CommercialUser(
      name: map['name'] ?? '',
      profilePicture: map['profilePicture'] ?? '',
      hyperlink: map['hyperlink'],
      businessId: map['businessId'],
      description: map['description'],
    );
  }
}
