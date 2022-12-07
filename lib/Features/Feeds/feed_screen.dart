import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Common/post_card.dart';
import 'package:reddit_clone/Features/Community/controller/community_controller.dart';
import 'package:reddit_clone/Features/Posts/controller/post_controller.dart';

import '../../Common/error_text.dart';
import '../../Common/loader.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //? we have fetched the user's community then we want the user's posts
    return ref.watch(userCommunitiesProvider).when(
          data: (communities) => ref.watch(userPostsProvider(communities)).when(
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
                error: (error, stackTrace) =>
                    ErrorText(errortxt: error.toString()),
                loading: () => const Loader(),
              ),
          error: (error, stackTrace) => ErrorText(errortxt: error.toString()),
          loading: () => const Loader(),
        );
  }
}
