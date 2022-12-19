import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Models/user_model.dart';

import '../../../Core/Constants/firebase_constants.dart';
import '../../../Core/Providers/firebase_providers.dart';
import '../../../Core/failure.dart';
import '../../../Core/type_def.dart';
import '../../../Models/post_model.dart';

//*****getting firestore instance from firebase provider******//
final userProfileRepoProvider = Provider(
  (ref) => UserProfileRepository(
    firestore: ref.read(firebaseProvider),
  ),
);

class UserProfileRepository {
  final FirebaseFirestore _firestore;

  UserProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;
  CollectionReference get _users =>
      _firestore.collection(FirebaseConstants.usersCollection);
  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  //*******EDIT PROFILE FUNCTION *******//
  FutureVoid editProfile(UserModel userModel) async {
    try {
      return right(
        _users.doc(userModel.uid).update(
              userModel.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

//*************DISPLAY USER POSTS TO THEIR PF**********//
  Stream<List<PostModel>> getUserPost(String uid) {
    //? we are returning post where the user uid is equal to the uid we are passing as a parameter.
    //?ORDEREDBY: we want newly created post at the top
    return _posts
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => PostModel.fromMap(e.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  //*******KARMA FUNCTION *******//
  FutureVoid updateUserKarma(UserModel userModel) async {
    try {
      return right(
        _users.doc(userModel.uid).update({
          'karma': userModel.karma,
        }),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
