// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Common/error_text.dart';
import 'package:reddit_clone/Common/loader.dart';
import 'package:reddit_clone/Core/Constants/constants.dart';
import 'package:reddit_clone/Core/utils.dart';
import 'package:reddit_clone/Features/Community/controller/community_controller.dart';
import 'package:reddit_clone/Models/community_model.dart';
import 'package:reddit_clone/Responsiveness/responsive.dart';

import '../../../Themes/pallets.dart';

class EditCommunityScreen extends ConsumerStatefulWidget {
  final String name;
  const EditCommunityScreen({
    super.key,
    required this.name,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityScreenState();
}

class _EditCommunityScreenState extends ConsumerState<EditCommunityScreen> {
  File? bannerFile;
  File? profile;
  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;

  void selectBannerImage() async {
    final result = await pickImage();

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          bannerWebFile = result.files.first.bytes;
        });
      } else {
        setState(() {
          bannerFile = File(result.files.first.path!);
        });
      }
    }
  }

  void selectProfileImage() async {
    final result = await pickImage();

    if (result != null) {
      if (kIsWeb) {
        setState(() {
          profileWebFile = result.files.first.bytes;
        });
      } else {
        setState(() {
          profile = File(result.files.first.path!);
        });
      }
    }
  }

  void save(CommunityModel communityModel) {
    ref.read(communityControllerProvider.notifier).editCommunity(
        communityModel: communityModel,
        profileFile: profile,
        bannerFile: bannerFile,
        bannerWebFile: bannerWebFile,
        profileWebFile: profileWebFile,
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);

    return ref.watch(getCommunityByNameProvider(widget.name)).when(
        data: (community) => Scaffold(
              backgroundColor: currentTheme.backgroundColor,
              appBar: AppBar(
                title: const Text('Edit Community'),
                actions: [
                  TextButton(
                    onPressed: () => save(community),
                    child: const Text('Save'),
                  ),
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Responsive(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: Stack(
                                children: [
                                  GestureDetector(
                                    onTap: selectBannerImage,
                                    child: DottedBorder(
                                      borderType: BorderType.RRect,
                                      radius: const Radius.circular(10),
                                      color: currentTheme
                                          .textTheme.bodyText2!.color!,
                                      dashPattern: const [10, 4],
                                      strokeCap: StrokeCap.round,
                                      child: Container(
                                          width: double.infinity,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: bannerWebFile != null
                                              ? Image.memory(bannerWebFile!)
                                              : bannerFile != null
                                                  ? Image.file(bannerFile!)
                                                  : community.banner.isEmpty ||
                                                          community.banner ==
                                                              Constants
                                                                  .bannerDefault
                                                      ? const Center(
                                                          child: Icon(
                                                            Icons
                                                                .camera_alt_outlined,
                                                            size: 40,
                                                          ),
                                                        )
                                                      : Image.network(
                                                          community.banner)),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 20,
                                      left: 20,
                                      child: GestureDetector(
                                        onTap: selectProfileImage,
                                        child: profileWebFile != null
                                            ? CircleAvatar(
                                                radius: 32,
                                                backgroundImage: MemoryImage(
                                                    profileWebFile!),
                                              )
                                            : profile != null
                                                ? CircleAvatar(
                                                    radius: 32,
                                                    backgroundImage:
                                                        FileImage(profile!),
                                                  )
                                                : CircleAvatar(
                                                    radius: 32,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            community.avatar),
                                                  ),
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
        error: (error, stackTrace) => ErrorText(
              errortxt: error.toString(),
            ),
        loading: () => const Loader());
  }
}
