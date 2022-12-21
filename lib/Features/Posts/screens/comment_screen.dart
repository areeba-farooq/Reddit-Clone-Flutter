import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Common/error_text.dart';
import 'package:reddit_clone/Common/post_card.dart';
import 'package:reddit_clone/Features/Posts/Widgets/comment_card.dart';
import 'package:reddit_clone/Features/Posts/controller/post_controller.dart';
import 'package:reddit_clone/Models/post_model.dart';
import 'package:reddit_clone/Responsiveness/responsive.dart';

import '../../../Common/loader.dart';
import '../../Auth/Controller/auth_controller.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(PostModel post) {
    ref.read(postControllerProvider.notifier).addComment(
        text: commentController.text.trim(), post: post, context: context);
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider)!;

    final isGuest = !user
        .isAuthenticated; // if user is authenticated then the user is not a guest

    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostsByIDProvider(widget.postId)).when(
          data: (data) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  PostCard(postModel: data),
                  if (!isGuest)
                    Responsive(
                      child: TextField(
                        onSubmitted: (val) => addComment(data),
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'What are you thoughts?',
                          filled: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ref.watch(getCommentsProvider(widget.postId)).when(
                      data: (data) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final comment = data[index];
                            return CommentCard(comment: comment);
                          },
                        );
                      },
                      error: (error, stackTrace) {
                        return ErrorText(
                          errortxt: error.toString(),
                        );
                      },
                      loading: () => const Loader()),
                ],
              ),
            );
          },
          error: (error, stackTrace) {
            return ErrorText(
              errortxt: error.toString(),
            );
          },
          loading: () => const Loader()),
    );
  }
}
