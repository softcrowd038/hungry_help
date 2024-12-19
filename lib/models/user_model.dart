class UserAccount {
  final bool success;
  final UserProfile userProfile;

  UserAccount({
    required this.success,
    required this.userProfile,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      success: json['success'],
      userProfile: UserProfile.fromJson(json['userProfile']),
    );
  }
}

class UserProfile {
  final int? id;
  final String? uuid;
  final String? imageurl;
  final String? username;
  final String? firstname;
  final String? lastname;
  final String? location;
  final String? latitude;
  final String? longitude;
  final DateTime? birthdate;
  final DateTime? createdAt;

  UserProfile({
    this.id,
    this.uuid,
    this.imageurl,
    this.username,
    this.firstname,
    this.lastname,
    this.location,
    this.latitude,
    this.longitude,
    this.birthdate,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      uuid: json['uuid'],
      imageurl: json['imageurl'],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      birthdate:
          json['birthdate'] != null ? DateTime.parse(json['birthdate']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
