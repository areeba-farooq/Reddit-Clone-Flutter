//*****getting firestore instance from firebase provider******//
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/Enums/enums.dart';
import 'package:reddit_clone/Core/utils.dart';
import 'package:reddit_clone/Features/Posts/repository/post_repo.dart';
import 'package:reddit_clone/Features/UserProfile/controller/user_pf_controller.dart';
import 'package:reddit_clone/Models/comment_model.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:reddit_clone/Models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../Core/Providers/storage_repo_provider.dart';
import '../../Auth/Controller/auth_controller.dart';

//************* POST CONTROLLER PROVIDER ********//
final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepo = ref.watch(postRepoProvider);
  final storageRepo = ref.watch(storageRepProvider);
  return PostController(
      postRepository: postRepo, ref: ref, storageRepository: storageRepo);
});

//************* USER POST PROVIDER ********//

final userPostsProvider =
    StreamProvider.family((ref, List<CommunityModel> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

//************* GETTING POST PROVIDER ********//

final getPostsByIDProvider = StreamProvider.family((ref, String postID) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postID);
});

//************* GETTING COMMENTS PROVIDER ********//
final getCommentsProvider = StreamProvider.family((ref, String postID) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchComments(postID);
});

//************* POST CONTROLLER CLASS ********//
class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  //! to contact the userProvider to get the user id
  final Ref _ref;
  final StorageRepository _storageRepository;
  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

//************* SHARE TEXT FUNCTION ********//
//? whenever user share a post we want to update the karma
  void shareTextPost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required String description,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final PostModel post = PostModel(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.username,
      uid: user.uid,
      type: 'text',
      createdAt: DateTime.now(),
      awards: [],
      description: description,
    );
    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
    state = false;
    res.fold((l) => showSnackBar(l.message), (r) {
      showSnackBar('Posted Successfully!');
      Routemaster.of(context).pop();
    });
  }

//************* SHARE lINK FUNCTION ********//
//? whenever user share a post we want to update the karma
  void shareLinkPost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required String link,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    final PostModel post = PostModel(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      upvotes: [],
      downvotes: [],
      commentCount: 0,
      username: user.username,
      uid: user.uid,
      type: 'link',
      createdAt: DateTime.now(),
      awards: [],
      link: link,
    );
    final res = await _postRepository.addPost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackBar(l.message), (r) {
      showSnackBar('Posted Successfully!');
      Routemaster.of(context).pop();
    });
  }

//************* SHARE IMAGE FUNCTION ********//
//? whenever user share a post we want to update the karma
  void shareImagePost({
    required BuildContext context,
    required String title,
    required CommunityModel selectedCommunity,
    required File? file,
  }) async {
    state = true;
    String postId = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imgRes = await _storageRepository.storeFile(
        path: 'posts/${selectedCommunity.name}', id: postId, file: file);

    imgRes.fold((l) => showSnackBar(l.message), (r) async {
      final PostModel post = PostModel(
        id: postId,
        title: title,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.username,
        uid: user.uid,
        type: 'image',
        createdAt: DateTime.now(),
        awards: [],
        link: r,
      );
      final res = await _postRepository.addPost(post);
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
      state = false;
      res.fold((l) => showSnackBar(l.message), (r) {
        showSnackBar('Posted Successfully!');
        Routemaster.of(context).pop();
      });
    });
  }

//**********FETCHING CREATED POSTS FROM FIREBASE**************//
  Stream<List<PostModel>> fetchUserPosts(List<CommunityModel> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  //**********DELETE POST FUNCTION**************//
  void deletePost(PostModel post) async {
    final res = await _postRepository.deletePost(post);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
    res.fold(
        (l) => showSnackBar(l.message), (r) => showSnackBar('Post Deleted!'));
  }

  //**********UPVOTE FUNCTION**************//
  void upvote(PostModel post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  //**********DOWNVOTE FUNCTION**************//
  void downvote(PostModel post) async {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }

  //**********GETTING POSTS  FUNCTION**************//
  Stream<PostModel> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  //*****ADD COMMENT FUNCTION ******//
  void addComment(
      {required String text,
      required PostModel post,
      required BuildContext context}) async {
    state = true;
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    CommentModel comment = CommentModel(
        id: commentId,
        text: text,
        createdAt: DateTime.now(),
        postId: post.id,
        username: user.username,
        profilePic: user.profilePic);
    _postRepository.addComment(comment);
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    state = false;
    res.fold((l) => showSnackBar(l.message), (r) => null);
  }

  //*****GETTING COMMENTS FUNCTION ******//
  Stream<List<CommentModel>> fetchComments(String postId) {
    return _postRepository.getComments(postId);
  }

  //*****GIVE AWARDS TO POSTS FUNCTION ******//
  void awardPost({
    required PostModel postModel,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepository.awardPost(postModel, award, user.uid);
    res.fold((l) => showSnackBar(l.message), (r) {
      //? updating the user karma
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      //? Now the award remove from the user
      _ref.read(userProvider.notifier).update((state) {
        //?state can be null, if its null don't do anything, if its not null then remove particular award frm awards aray.
        state?.awards.remove(award);
        return state; // return newly made state;
      });
      Routemaster.of(context).pop();
    });
  }
}
