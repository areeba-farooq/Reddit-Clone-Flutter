import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reddit_clone/Common/error_text.dart';
import 'package:reddit_clone/Common/loader.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Features/Community/controller/community_controller.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:routemaster/routemaster.dart';

import '../../../Common/post_card.dart';

class CommunityDetailScreen extends ConsumerWidget {
  final String name;
  const CommunityDetailScreen({super.key, required this.name});

  void navToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  void joinCommunity(
      WidgetRef ref, BuildContext context, CommunityModel communityModel) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(communityModel, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      body: ref
          .watch(getCommunityByNameProvider(name.replaceAll('%20', ' ')))
          .when(
            data: (community) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 150,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              community.banner,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Align(
                              alignment: Alignment.topLeft,
                              child: CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'r/${community.name}',
                                  style: GoogleFonts.lato(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                //? community.mods.contains(user.uid) we are checking if the user is the moderator of that community.
                                community.mods.contains(user.uid)
                                    ? OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25),
                                        ),
                                        onPressed: () => navToModTools(context),
                                        child: const Text('Mod Tools'),
                                      )
                                    : OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 25),
                                        ),
                                        onPressed: () => joinCommunity(
                                            ref, context, community),
                                        //?community.members.contains(user.uid) we are checking if the user is the part of that community
                                        child: Text(
                                            community.members.contains(user.uid)
                                                ? 'Joined'
                                                : 'Join'),
                                      )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child:
                                  Text('${community.members.length} members'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: ref
                    .watch(
                        getCoomunityPostProvider(name.replaceAll('%20', ' ')))
                    .when(
                      data: (data) {
                        return ListView.builder(
                            itemCount: data.length,
                            itemBuilder: (context, i) {
                              final post = data[i];
                              return PostCard(
                                postModel: post,
                              );
                            });
                      },
                      error: (error, stackTrace) {
                        return ErrorText(errortxt: error.toString());
                      },
                      loading: () => const Loader(),
                    )),
            error: (error, stackTrace) => ErrorText(
              errortxt: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
