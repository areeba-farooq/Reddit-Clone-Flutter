import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit_clone/Core/Constants/constants.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Themes/pallets.dart';

//!consumerWidget comes from riverpod library
//?ConsumerWidget will allow use to use WidgetRef
class SigninButton extends ConsumerWidget {
  //if the user signin with the guest account and then decided to signin weith Google then we will convert that guest account into google account.
  final bool isFromLogin;
  const SigninButton({Key? key, this.isFromLogin = true}) : super(key: key);

//*this contact with the AuthController class
  void signinWithGoogle(BuildContext context, WidgetRef ref) {
    ref
        .read(authControllerProvider.notifier)
        .signinWithGoogle(context, isFromLogin);
  }

  @override

  //!WidgetRef object that allows widgets to interact with providers.
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
        onPressed: () => signinWithGoogle(context, ref),
        icon: Image.asset(
          Constants.googlePath,
          width: 35,
        ),
        label: Text(
          'Continue with Google',
          style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.greyColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
