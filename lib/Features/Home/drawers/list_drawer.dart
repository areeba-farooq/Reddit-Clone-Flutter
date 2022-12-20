import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Common/error_text.dart';
import 'package:reddit_clone/Common/signin_button.dart';
import 'package:reddit_clone/Features/Community/controller/community_controller.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../Common/loader.dart';
import '../../Auth/Controller/auth_controller.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navtoCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navtoCommunityScreen(BuildContext context, CommunityModel communityMod) {
    Routemaster.of(context).push('/r/${communityMod.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user
        .isAuthenticated; // if user is authenticated then the user is not a guest
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          isGuest
              ? const SigninButton()
              : ListTile(
                  title: const Text('Create a Community'),
                  leading: const Icon(Icons.add),
                  onTap: () => navtoCreateCommunity(context),
                ),
          //?In case of not waste my streams, If the user is not a guest the show all of this.
          if (!isGuest)
            ref.watch(userCommunitiesProvider).when(
                  data: (communities) => Expanded(
                    child: ListView.builder(
                        itemCount: communities.length,
                        itemBuilder: (context, i) {
                          final community = communities[i];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                            ),
                            title: Text('r/${community.name}'),
                            onTap: () =>
                                navtoCommunityScreen(context, community),
                          );
                        }),
                  ),
                  error: (error, stackTrace) =>
                      ErrorText(errortxt: error.toString()),
                  loading: () => const Loader(),
                )
        ],
      )),
    );
  }
}
