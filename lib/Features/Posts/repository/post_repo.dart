import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../Core/Constants/firebase_constants.dart';
import '../../../Core/Providers/firebase_providers.dart';
import '../../../Core/failure.dart';
import '../../../Core/type_def.dart';
import '../../../Models/comment_model.dart';
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

  //**********DELETE POST FUNCTION**************//
  FutureVoid deletePost(PostModel post) async {
    try {
      return right(_posts.doc(post.id).delete());
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

  //**********UPVOTE FUNCTION**************//
  void upvote(PostModel post, String userId) async {
    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

//**********DOWNVOTE FUNCTION**************//
  void downvote(PostModel post, String userId) async {
    if (post.upvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'upvotes': FieldValue.arrayRemove([userId]),
      });
    }

    if (post.downvotes.contains(userId)) {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayRemove([userId]),
      });
    } else {
      _posts.doc(post.id).update({
        'downvotes': FieldValue.arrayUnion([userId]),
      });
    }
  }

  //**********GETTING POSTS FUNCTION**************//
  Stream<PostModel> getPostById(String postId) {
    return _posts.doc(postId).snapshots().map(
          (event) => PostModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

//*****ADD COMMENT FUNCTION ******//
  FutureVoid addComment(CommentModel comment) async {
    try {
      await _comments.doc(comment.id).set(
            comment.toMap(),
          );
      return right(_posts.doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      }));
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

  //*****GETTING COMMENTS FUNCTION ******//
  Stream<List<CommentModel>> getComments(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map(
              (e) => CommentModel.fromMap(e.data() as Map<String, dynamic>),
            )
            .toList());
  }

  //*****GIVE AWARDS TO POSTS FUNCTION ******//
  FutureVoid awardPost(PostModel post, String award, String senderID) async {
    try {
      //?went to the post collections -> post id -> update awards section -> so we can display the awards right above the post
      //!AWARDS ADDED TO THE POST
      _posts.doc(post.id).update({
        'awards': FieldValue.arrayUnion([award]),
      });
      //? whoever the sender gifting the awards to post, that awards will be remove from that senderID
      _user.doc(senderID).update({
        'awards': FieldValue.arrayRemove([award]),
      });
//? the person whom we are gifting awards --> will add that awrads to the user
      //!AWARDS ADDED TO THE USER

      return right(
        _user.doc(post.uid).update(
          {
            'awards': FieldValue.arrayUnion([award]),
          },
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

  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);
  CollectionReference get _user =>
      _firestore.collection(FirebaseConstants.usersCollection);
}
