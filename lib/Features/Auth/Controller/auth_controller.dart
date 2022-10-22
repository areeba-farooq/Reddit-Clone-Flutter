import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Features/Auth/Repository/auth_repo.dart';

//! this ref allow us to talk with other providers
final authControllerProvider = Provider(
  (ref) => AuthController(
    authRepository: ref.read(
        authRepoProvider), //? gives us the instance of the authRepoProvider
  ),
);

class AuthController {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository;

  void signinWithGoogle() {
    //!from AuthRepository Class
    _authRepository.signinWithGoogle();
  }
}
