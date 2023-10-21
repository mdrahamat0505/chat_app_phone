class UserModel {
  String? uid;
  String? fullName;
  String? phoneNumber;
  String? profileImage;

  UserModel({
    this.uid,
    this.fullName,
    this.phoneNumber,
    this.profileImage,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    uid = map["uid"];
    fullName = map["fullName"];
    phoneNumber = map["phoneNumber"];
    profileImage = map["profileImage"];
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "profileImage": profileImage,
    };
  }
}
