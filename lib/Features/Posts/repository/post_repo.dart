import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../Core/Constants/firebase_constants.dart';
import '../../../Core/Providers/firebase_providers.dart';
import '../../../Core/failure.dart';
import '../../../Core/type_def.dart';
import '../../../Models/post_model.dart';

//*****getting firestore instance from firebase provider******//
final postRepoProvider = Provider(
  (ref) => PostRepository(
    firestore: ref.read(firebaseProvider),
  ),
);
//*****MAIN CLASS STARTED******//

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

//*******ADD POST FUNCTION *******//
  FutureVoid addPost(PostModel post) async {
    try {
      //! cannot add new users to members list like this [userId] directly
      return right(
        _posts.doc(post.id).set(
              post.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(
        Failure(
          e.toString(),
        ),
      );
    }
  }

//*****COLLECTION REFFERENCE FROM FIREBASE ******//

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
}
