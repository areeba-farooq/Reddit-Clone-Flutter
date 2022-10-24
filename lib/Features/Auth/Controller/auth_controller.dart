import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Core/utils.dart';
import 'package:reddit_clone/Features/Auth/Repository/auth_repo.dart';

import '../../../Models/user_model.dart';

//***********Storing Data to Provider *********//
//! Provider is the read only widget we cannot change anything later once we set it so we use stateProvider that will be able to change the value
//*this userProvider will give us username, ui........ etc
final userProvider = StateProvider<UserModel?>((ref) => null);

//* STATENOTIFIERPROVIDER => updates the state, notify to all providers also returns the AuthController */
//! this ref allow us to talk with other providers
final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    ref: ref,
    authRepository: ref.watch(
        authRepoProvider), //? gives us the instance of the authRepoProvider
  ),
);
final authStateChangeProvider = StreamProvider(
  (ref) {
    final authController =
        ref.watch(authControllerProvider.notifier); //insttance
    return authController.authStateChange;
  },
);

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier); //insttance
  return authController.getUserData(uid);
});

//? StateNotifier is similar to hcangeNotifier
//? if any change in state it should notify to all providers which will be listening to it.
class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  //! to contact the userProvider to get the user id
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
      : _authRepository = authRepository,
        _ref = ref,
        super(false); //loading

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signinWithGoogle(BuildContext context) async {
    state = true; //loading start
    //!from AuthRepository Class
    final user = await _authRepository.signinWithGoogle();
    state = false; //loading stops
    user.fold(
        (l) => showSnackBar(context, l.message),

        //?_ref.read(userProvider) = this gives us access to userModel not anythin to update.
        //?_ref.read(userProvider.notifier) with this notifier we have access to multiple methods that will allow us to change the content
        (usermodel) =>
            _ref.read(userProvider.notifier).update((state) => usermodel));
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }
}
