import 'package:flutter/foundation.dart';

class UserModel {
  final int karma;
  final String uid;
  final String banner;
  final String username;
  final String profilePic;
  final bool isAuthenticated; //? if guest or not
  final List<String> awards;

  //! CONSTRUCTOR
  UserModel({
    required this.karma,
    required this.uid,
    required this.banner,
    required this.username,
    required this.profilePic,
    required this.isAuthenticated,
    required this.awards,
  });

//! FOR OVERRIDING
  UserModel copyWith({
    int? karma,
    String? uid,
    String? banner,
    String? username,
    String? profilePic,
    bool? isAuthenticated,
    List<String>? awards,
  }) {
    return UserModel(
      karma: karma ?? this.karma,
      uid: uid ?? this.uid,
      banner: banner ?? this.banner,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      awards: awards ?? this.awards,
    );
  }

//! HELP USE TO SEND DATA TO FIREBASE
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'karma': karma,
      'uid': uid,
      'banner': banner,
      'username': username,
      'profilePic': profilePic,
      'isAuthenticated': isAuthenticated,
      'awards': awards,
    };
  }

//! WHATEVER VALUE WE PASS AS A MAP, IT WILL CONVERT IT TO A USERMODEL CLASS AND EXTRACTING THE VALUES FORM IT
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      karma: map['karma'] as int,
      uid: map['uid'] as String,
      banner: map['banner'] as String,
      username: map['username'] as String,
      profilePic: map['profilePic'] as String,
      isAuthenticated: map['isAuthenticated'] as bool,
      awards: List<String>.from(
        (map['awards']),
      ),
    );
  }

//! IF I WANT THIS => UserModel.toString();
  @override
  String toString() {
    return 'UserModel(karma: $karma, uid: $uid, banner: $banner, username: $username, profilePic: $profilePic, isAuthenticated: $isAuthenticated, awards: $awards)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.karma == karma &&
        other.uid == uid &&
        other.banner == banner &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.isAuthenticated == isAuthenticated &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return karma.hashCode ^
        uid.hashCode ^
        banner.hashCode ^
        username.hashCode ^
        profilePic.hashCode ^
        isAuthenticated.hashCode ^
        awards.hashCode;
  }
}
