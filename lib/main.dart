import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Common/error_text.dart';
import 'package:reddit_clone/Common/loader.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Models/user_model.dart';
import 'package:reddit_clone/Themes/pallets.dart';
import 'package:reddit_clone/firebase_options.dart';
import 'package:reddit_clone/Routes/router.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  UserModel? userModel;
//! saving user data to userprovider
  void getData(WidgetRef ref, User data) async {
    //?this is a stream to convert it to future we can use .first
    userModel = await ref
        .watch(authControllerProvider.notifier)
        .getUserData(data.uid)
        .first;
    ref.read(userProvider.notifier).update((state) => userModel);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(authStateChangeProvider).when(
        data: (data) => MaterialApp.router(
              scaffoldMessengerKey: scaffoldMessengerKey, // add this

              debugShowCheckedModeBanner: false,
              title: 'Reddit Clone with Flutter',
              theme: ref.watch(themeNotifierProvider),
              routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
                if (data != null) {
                  getData(ref, data);
                  //?now the user is not null
                  if (userModel != null) {
                    return loggedInRoute;
                  }
                }
                return loggedOutRoute;
              }),
              routeInformationParser: const RoutemasterParser(),
            ),
        error: (error, stackTrace) => ErrorText(errortxt: error.toString()),
        loading: () => const Loader());
  }
}
