import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Themes/pallets.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});
  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logOut();
  }

  void navToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('u/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(user.profilePic),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'u/${user.username}',
              style: GoogleFonts.lato(fontSize: 18),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.person,
                color: Colors.blue,
              ),
              title: const Text('My Profile'),
              onTap: () => navToUserProfile(context, user.uid),
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Pallete.redColor,
              ),
              title: const Text('Log Out'),
              onTap: () => logOut(ref),
            ),
            Switch.adaptive(
                activeColor: Colors.lightGreenAccent,
                value: true,
                onChanged: (val) {}),
          ],
        ),
      ),
    );
  }
}
