import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../Core/Constants/firebase_constants.dart';
import '../../../Core/Providers/firebase_providers.dart';
import '../../../Core/failure.dart';
import '../../../Core/type_def.dart';
import '../../../Models/community_model.dart';
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

//**********FETCHING CREATED POSTS FROM FIREBASE**************//
  Stream<List<PostModel>> fetchUserPosts(List<CommunityModel> communities) {
    //? grabing the posts by their community names whereIn allows us to pass it list of names. We ordered it according to the date and in the descending order so thw newly released post come at the top and then we are getting it snapshot converting it into a list of posts.
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => PostModel.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList());
  }

//*****COLLECTION REFFERENCE FROM FIREBASE ******//

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);
}
