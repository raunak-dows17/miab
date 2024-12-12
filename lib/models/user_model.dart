class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String avatar;
  // final bool isPremium;s

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.avatar,
    // required this.isPremium,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"] ?? json["id"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      email: json["email"],
      mobile: json["mobile"],
      avatar: json["avatar"] ??
          "https://img.freepik.com/free-psd/3d-icon-social-media-app_23-2150049569.jpg?t=st=1733298836~exp=1733302436~hmac=1f15270d55a1c3142a5cbd171f3c553dc74b45bc25afb5e19257171d3339169e&w=740",
      // isPremium: json["isPremium"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "mobile": mobile,
      "avatar": avatar,
      // "isPremium": isPremium,
    };
  }
}
