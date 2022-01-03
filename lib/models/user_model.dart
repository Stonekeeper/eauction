class UserModel {
  String? uid;
  String? name;
  String? email;
  String? mobileno;
  String? aadharid;

  UserModel({this.uid, this.name, this.email, this.aadharid, this.mobileno});

  //Receiving data from the server
  factory UserModel.fromMap(map) {
    return UserModel(
        uid: map['uid'],
        name: map['name'],
        email: map['email'],
        mobileno: map['mobileno'],
        aadharid: map['aadharid']);
  }

  // Sending data to server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'mobileno': mobileno,
      'aadharid': aadharid
    };
  }
}
