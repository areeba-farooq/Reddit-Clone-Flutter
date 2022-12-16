import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Common/error_text.dart';
import 'package:reddit_clone/Core/Constants/constants.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Features/Community/controller/community_controller.dart';
import 'package:reddit_clone/Features/Posts/controller/post_controller.dart';
import 'package:reddit_clone/Models/post_model.dart';
import 'package:reddit_clone/Themes/pallets.dart';
import 'package:routemaster/routemaster.dart';

import 'loader.dart';

class PostCard extends ConsumerWidget {
  final PostModel postModel;
  const PostCard({
    required this.postModel,
    super.key,
  });

  void deletePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(postModel);
  }

  void upvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).upvote(postModel);
  }

  void downvotePost(WidgetRef ref) async {
    ref.read(postControllerProvider.notifier).downvote(postModel);
  }

  //? we can navigate to the user profile who posted in the group
  void navToUserPF(BuildContext context) {
    Routemaster.of(context).push('/u/${postModel.uid}');
  }

  void navToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${postModel.communityName}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = postModel.type == 'image';
    final isTypeText = postModel.type == 'text';
    final isTypeLink = postModel.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    // final isLoading = ref.watch(postControllerProvider);
    final user = ref.watch(userProvider);
    return Column(
      children: [
        Container(
          decoration:
              BoxDecoration(color: currentTheme.drawerTheme.backgroundColor),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 10)
                          .copyWith(right: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => navToCommunity(context),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          postModel.communityProfilePic),
                                      radius: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(
                                      children: [
                                        Text(
                                          'r/${postModel.communityName}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        GestureDetector(
                                          onTap: () => navToUserPF(context),
                                          child: Text(
                                            'u/${postModel.username}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (postModel.uid == user!.uid)
                                IconButton(
                                  onPressed: () => deletePost(ref),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Pallete.redColor,
                                  ),
                                ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              postModel.title,
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isTypeImage)
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.network(
                                postModel.link!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (isTypeText)
                            Container(
                                alignment: Alignment.bottomLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Text(postModel.description!)),
                          if (isTypeLink)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              child: AnyLinkPreview(
                                displayDirection:
                                    UIDirection.uiDirectionHorizontal,
                                link: postModel.link!,
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => upvotePost(ref),
                                    icon: Icon(
                                      Constants.up,
                                      size: 30,
                                      color:
                                          postModel.upvotes.contains(user.uid)
                                              ? Pallete.redColor
                                              : null,
                                    ),
                                  ),
                                  Text(
                                    '${postModel.upvotes.length - postModel.downvotes.length == 0 ? 'Vote' : postModel.upvotes.length - postModel.downvotes.length}',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  IconButton(
                                    onPressed: () => downvotePost(ref),
                                    icon: Icon(
                                      Constants.down,
                                      size: 30,
                                      color:
                                          postModel.downvotes.contains(user.uid)
                                              ? Pallete.blueColor
                                              : null,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.comment),
                                  ),
                                  Text(
                                    '${postModel.commentCount == 0 ? 'Comment' : postModel.commentCount}',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ],
                              ),

                              //**Want to show moderator icon if the user is moderator**// to access moderator
                              ref
                                  .watch(getCommunityByNameProvider(
                                      postModel.communityName))
                                  .when(
                                      data: (data) {
                                        if (data.mods.contains(user.uid)) {
                                          return IconButton(
                                            onPressed: () => deletePost(ref),
                                            icon: const Icon(
                                                Icons.admin_panel_settings),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                      error: (error, stackTrace) =>
                                          ErrorText(errortxt: error.toString()),
                                      loading: () => const Loader()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
