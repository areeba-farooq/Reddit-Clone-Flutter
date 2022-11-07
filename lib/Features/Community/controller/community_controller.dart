import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/Core/Constants/constants.dart';
import 'package:reddit_clone/Core/Providers/storage_repo_provider.dart';
import 'package:reddit_clone/Core/failure.dart';
import 'package:reddit_clone/Core/utils.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Features/Community/repository/community_repo.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:routemaster/routemaster.dart';

//************* USER COMMUNITY STREAM PROVIDER ********//
final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunity();
});

//*****getting firestore instance from firebase provider******//
final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepo = ref.watch(communityRepoProvider);
  final storageRepo = ref.watch(storageRepProvider);
  return CommunityController(
      communityRepository: communityRepo,
      ref: ref,
      storageRepository: storageRepo);
});
//************* GET COMMUNITY  BY NAME STREAM PROVIDER ********//
final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name.replaceAll('%20', ' '));
});

//************* SERACH COMMUNITY STREAM PROVIDER ********//
final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

//************* COMMUNITY CONTROLLER CLASS ********//
class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  //! to contact the userProvider to get the user id
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepository storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false); //loading

//************* CREATE COMMUNITY FUNCTION FROM REPOSITORY ********//
  void createCommunity(String name, BuildContext context) async {
    state = true; //loading start
    final uid = _ref.read(userProvider)?.uid ?? '';
    CommunityModel communityModel = CommunityModel(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );

    final res = await _communityRepository.createCommunity(communityModel);
    state = false; //loading stops
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Community created successfully!');
      Routemaster.of(context).pop();
    });
  }

//************* GET USER COMMUNITY FROM REPOSITORY ********//
  Stream<List<CommunityModel>> getUserCommunity() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunity(uid);
  }

//************* GET COMMUNITY BY NAME FROM REPOSITORY ********//
  Stream<CommunityModel> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

//************* EDIT COMMUNITY FUNCTION FROM REPOSITORY ********//
//* we are going to update to this communityModel now
  void editCommunity(
      {required CommunityModel communityModel,
      required File? profileFile,
      required File? bannerFile,
      required BuildContext context}) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/profile',
        id: communityModel.name,
        file: profileFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => communityModel = communityModel.copyWith(avatar: r),
      );
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'communities/banner',
        id: communityModel.name,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => communityModel = communityModel.copyWith(banner: r),
      );
    }
    //* if user don't change anything it will return as it is file
    final res = await _communityRepository.editCommunity(communityModel);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

//************* SEARCH COMMUNITY FROM REPOSITORY ********//
  Stream<List<CommunityModel>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

//************* JOIN COMMUNITY FROM REPOSITORY ********//
  void joinCommunity(
      CommunityModel communityModel, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    //?if I am the part of the community then I should show the leave community option
    Either<Failure, void> res;
    if (communityModel.members.contains(user.uid)) {
      res = await _communityRepository.leaveCommunity(
          communityModel.name, user.uid);
    } else {
      //?if I am not part of the community then I should show the join community option
      res = await _communityRepository.joinCommunity(
          communityModel.name, user.uid);
    }
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (communityModel.members.contains(user.uid)) {
        showSnackBar(context, 'Community left successfully!');
      } else {
        showSnackBar(context, 'Community joined successfully!');
      }
    });
  }

  //********** SAVE NEW MODERATOR *************//
  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(communityName, uids);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }
}
