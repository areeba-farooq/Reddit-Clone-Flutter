//*****getting firestore instance from firebase provider******//
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/utils.dart';
import 'package:reddit_clone/Features/Posts/repository/post_repo.dart';
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

final userPostsProvider =
    StreamProvider.family((ref, List<CommunityModel> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
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
    state = false;
    res.fold((l) => showSnackBar(l.message), (r) {
      showSnackBar('Posted Successfully!');
      Routemaster.of(context).pop();
    });
  }

//************* SHARE lINK FUNCTION ********//
  void sharelInkPost({
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
    state = false;
    res.fold((l) => showSnackBar(l.message), (r) {
      showSnackBar('Posted Successfully!');
      Routemaster.of(context).pop();
    });
  }

//************* SHARE IMAGE FUNCTION ********//
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
      state = false;
      res.fold((l) => showSnackBar(l.message), (r) {
        showSnackBar('Posted Successfully!');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<PostModel>> fetchUserPosts(List<CommunityModel> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }
}
