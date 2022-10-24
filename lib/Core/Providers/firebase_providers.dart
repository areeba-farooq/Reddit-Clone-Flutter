import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

//! this ref allow us to talk with other providers
//? Provider is the read only widget we cannot change anything later once we set it
//******contains firebase providers****\\
final firebaseProvider = Provider((ref) => FirebaseFirestore.instance);
final storageProvider = Provider((ref) => FirebaseStorage.instance);
final authProvider = Provider((ref) => FirebaseAuth.instance);
final googleSigninProvider = Provider((ref) => GoogleSignIn());
