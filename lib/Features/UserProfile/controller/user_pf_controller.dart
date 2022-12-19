import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/Enums/enums.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Features/UserProfile/repository/user_pf_repo.dart';
import 'package:reddit_clone/Models/user_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../Core/Providers/storage_repo_provider.dart';
import '../../../Core/utils.dart';
import '../../../Models/post_model.dart';

//*****getting firestore instance from firebase provider******//
final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userRepo = ref.watch(userProfileRepoProvider);
  final storageRepo = ref.watch(storageRepProvider);
  return UserProfileController(
      userProfileRepository: userRepo,
      ref: ref,
      storageRepository: storageRepo);
});
//************* GETTING USER POSTS STREAM PROVIDER ********//
final getUserPostProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPost(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  //! to contact the userProvider to get the user id
  final Ref _ref;
  final StorageRepository _storageRepository;
  UserProfileController({
    required StorageRepository storageRepository,
    required UserProfileRepository userProfileRepository,
    required Ref ref,
  })  : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  //************* EDIT COMMUNITY FUNCTION FROM REPOSITORY ********//
//* we are going to update to this communityModel now
  void editProfile(
      {required File? profileFile,
      required File? bannerFile,
      required BuildContext context,
      required String name}) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/profile',
        id: user.uid,
        file: profileFile,
      );
      res.fold(
        (l) => showSnackBar(l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'users/banner',
        id: user.uid,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(l.message),
        (r) => user = user.copyWith(banner: r),
      );
    }
    user = user.copyWith(username: name);
    //* if user don't change anything it will return as it is file
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(l.message), (r) {
      //? update this userprovider
      _ref.read(userProvider.notifier).update((state) => user);
      Routemaster.of(context).pop();
    });
  }

  //***********DISPLAYING USER POST TO PF************//
  Stream<List<PostModel>> getUserPost(String uid) {
    return _userProfileRepository.getUserPost(uid);
  }

  //*******KARMA FUNCTION *******//
  void updateUserKarma(UserKarma userKarma) async {
    //? read the user
    UserModel user = _ref.read(userProvider)!;
    //? userKarma is the enum in which there is a property of karma, we have just copied that
    //! user.karma is whatever the karma user has already
    user = user.copyWith(karma: user.karma + userKarma.karma);
    //? now we are talk with our repository
    final res = await _userProfileRepository.updateUserKarma(user);
    //? for success , update the user provider withn the newly karma that we have
    res.fold((l) => showSnackBar(l.message),
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
