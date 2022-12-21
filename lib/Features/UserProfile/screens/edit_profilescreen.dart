import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Features/UserProfile/controller/user_pf_controller.dart';
import 'package:reddit_clone/Responsiveness/responsive.dart';
import 'package:reddit_clone/Themes/pallets.dart';

import '../../../Common/error_text.dart';
import '../../../Common/loader.dart';
import '../../../Core/Constants/constants.dart';
import '../../../Core/utils.dart';

class EditProfileSCreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileSCreen({super.key, required this.uid});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileSCreenState();
}

class _EditProfileSCreenState extends ConsumerState<EditProfileSCreen> {
  File? bannerFile;
  File? profile;
  Uint8List? bannerWebFile;
  Uint8List? profileWebFile;
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: ref.read(userProvider)!.username);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

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

  void save() {
    ref.read(userProfileControllerProvider.notifier).editProfile(
        profileFile: profile,
        bannerFile: bannerFile,
        context: context,
        name: nameController.text.trim(),
        profileWebFile: profileWebFile,
        bannerWebFile: bannerWebFile);
  }

  @override
  Widget build(BuildContext context) {
    final islaoding = ref.watch(userProfileControllerProvider);
    final currentTheme = ref.watch(themeNotifierProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
        data: (user) => Scaffold(
              backgroundColor: currentTheme.backgroundColor,
              appBar: AppBar(
                title: const Text('Edit Profile'),
                actions: [
                  TextButton(
                    onPressed: save,
                    child: const Text('Save'),
                  ),
                ],
              ),
              body: islaoding
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
                                                  : user.banner.isEmpty ||
                                                          user.banner ==
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
                                                          user.banner)),
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
                                                            user.profilePic),
                                                  ),
                                      ))
                                ],
                              ),
                            ),
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(
                                filled: true,
                                hintText: 'Name',
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.blue),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.all(18),
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
