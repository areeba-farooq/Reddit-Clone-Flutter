import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Models/user_model.dart';

import '../../../Core/Constants/firebase_constants.dart';
import '../../../Core/Providers/firebase_providers.dart';
import '../../../Core/failure.dart';
import '../../../Core/type_def.dart';

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
}
