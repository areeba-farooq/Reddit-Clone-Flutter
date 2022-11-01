import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/Constants/constants.dart';
import 'package:reddit_clone/Core/Providers/storage_repo_provider.dart';
import 'package:reddit_clone/Core/utils.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Features/Community/repository/community_repo.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:routemaster/routemaster.dart';

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

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name.replaceAll('%20', ' '));
});

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

  Stream<List<CommunityModel>> getUserCommunity() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunity(uid);
  }

  Stream<CommunityModel> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

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
}
