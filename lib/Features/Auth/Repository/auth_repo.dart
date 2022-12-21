import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/Core/Constants/constants.dart';
import 'package:reddit_clone/Core/Constants/firebase_constants.dart';
import 'package:reddit_clone/Core/Providers/firebase_providers.dart';
import 'package:reddit_clone/Core/failure.dart';
import 'package:reddit_clone/Models/user_model.dart';

import '../../../Core/type_def.dart';

//*****getting Firebase(Auth,Firestore,Google) instance from firebase provider******//
final authRepoProvider = Provider(
  (ref) => AuthRepository(
    //!ref.read usually used outside of the buildContext when you don't want to listen any of the changes made in the provider
    auth: ref.read(authProvider), //? gives us the instance of authProvider
    firestore: ref.read(firebaseProvider),
    googleSignIn: ref.read(googleSigninProvider),
  ),
);

class AuthRepository {
  //!!!Private variables
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn
      _googleSignIn; //? provides methods to view the email of our google accounts

//****we cannot access private variables in the constructor so we can assign private to public***\\
  AuthRepository(
      //!public variables
      {required FirebaseAuth auth,
      required FirebaseFirestore firestore,
      required GoogleSignIn googleSignIn})
      : //*Private assigned to public
        _auth = auth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  CollectionReference get _user =>
      _firestore.collection(FirebaseConstants.usersCollection);

//?Firebase is giving us an option to expose a stream which will allow us and let us know if there is data change in user or not e.g name, email,profilepic etc
  Stream<User?> get authStateChange => _auth.authStateChanges();

//**************SiGNIN GOOGLE FUNCTION****************//
//! String type for failure
//! userModel type for success
//?Represents a value of one of two possible types, [Left] or [Right].
//?[Either] is commonly used to handle errors.
//!Future<Either<String, UserModel>>
//isFromLogin: if the user signin with the guest account and then decided to signin weith Google then we will convert that guest account into google account.
  FutureEither<UserModel> signinWithGoogle(bool isFromLogin) async {
    try {
      //? User credential
      UserCredential userCredential;
      //**LOGIN ON WEB**//
      if (kIsWeb) {
        //? access to the google auth provider
        GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        //? we have access to reading the contacts of the user
        googleAuthProvider
            .addScope("https://www.googleapis.com/auth/contacts.readonly");
        userCredential = await _auth.signInWithPopup(googleAuthProvider);
      } else {
        //**LOGIN ON MOBILE**//
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );

        //! if user is from login screen then the user should signin wth google.
        if (isFromLogin) {
          //**************REGISTER USER****************//
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          //!ELSE the user not going to create a new account, we just going to take the GUEST ACCOUNT (which is the current user) and link with credential of that GUEST ACCOUNT with the google signin acoount.
          //**************CONVERT GUEST ACCOUNT INTO GOOGLE ACCOUNT****************//
          userCredential =
              await _auth.currentUser!.linkWithCredential(credential);
        }
      }
      UserModel userModel;

//?to avoid the karma error we need to check is user new or old
      if (userCredential.additionalUserInfo!.isNewUser) {
        //**************USER MODEL INSTANCE****************//

        //? if user is new set all these values and save to DB
        userModel = UserModel(
          banner: Constants.bannerDefault,
          username: userCredential.user!.displayName ?? 'Untitled',
          karma: 0,
          profilePic: userCredential.user!.photoURL ?? Constants.avatarDefault,
          uid: userCredential.user!.uid,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
          isAuthenticated: true,
        );
        //**************Save user credentials to database****************//
        await _user.doc(userCredential.user!.uid).set(userModel.toMap());
      } else {
        //! first will convert the stream into a Future which means it will get us the first element of the stream

        //! for example stream is a bunch of values keep coming together so it will get very first value of it
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    } on FirebaseAuthException catch (e) {
      //? throwing this firebase exception to next catch block
      throw e.message!;
    } catch (e) {
      return left(
        Failure(e.toString()),
      );
    }
  }
  //**********GUEST SIGNUP***********//

  FutureEither<UserModel> signInAsGuest() async {
    try {
      var userCredential = await _auth.signInAnonymously();

//? if the use is sign in as a guest the user ought to be a NEW USER

      //**************UserModel Instance****************//
      //?set all these values and save to DB
      UserModel userModel = UserModel(
        username: 'Guest',
        profilePic: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isAuthenticated: false,
        karma: 0,
        awards: [],
      );

      //**************Save user credentials to database****************//
      await _user.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    } on FirebaseException catch (e) {
      //? throwing this firebase exception to next catch block
      throw e.message!;
    } catch (e) {
      return left(
        Failure(e.toString()),
      );
    }
  }
  //**************To get the user data Function****************//

  //! if the user is not new then we will ask to firebaseDB to give use back of the old user data containing this uid
//?this function persist the state of our app(means when user refresh the app it still logged in)

//! stream => to see real time update happening
  Stream<UserModel> getUserData(String uid) {
    return _user.doc(uid).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>),
        );
  }

  //******LOGOUT FUNCTION ********//
  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
