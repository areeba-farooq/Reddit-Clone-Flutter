import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Features/Home/Delegates/search_community.dart';
import 'package:reddit_clone/Features/Home/drawers/list_drawer.dart';
import 'package:reddit_clone/Features/Home/drawers/profile_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  void displayDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void profileDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //!to display user uid we will convert statelesswidget to consumerwidget inoreder to contact with the user provider
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => displayDrawer(context),
            icon: const Icon(Icons.menu),
          );
        }),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchCommunityDelegate(ref),
              );
            },
            icon: const Icon(Icons.search),
          ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => profileDrawer(context),
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user!.profilePic),
              ),
            );
          })
        ],
      ),
      drawer: const CommunityListDrawer(),
      endDrawer: const ProfileDrawer(),
    );
  }
}
