import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Common/error_text.dart';
import 'package:reddit_clone/Common/loader.dart';
import 'package:reddit_clone/Features/Auth/Controller/auth_controller.dart';
import 'package:reddit_clone/Features/Community/controller/community_controller.dart';

class AddModerator extends ConsumerStatefulWidget {
  final String name;
  const AddModerator({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModeratorState();
}

class _AddModeratorState extends ConsumerState<AddModerator> {
//! set is similar to list but the major difference is that you cannot have repeating values
  Set<String> uids = {};

  //? this will make sure and keep track of the number of times that checkboxlisttile rebuild
  int counter = 0;

  void addUids(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUids(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(
              Icons.check,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(

          //? i got the uid
          data: (community) => ListView.builder(
              itemCount: community.members.length,
              itemBuilder: (context, i) {
                final member = community.members[i];
//? got this uid to get the user data and i displayed the username
                return ref.watch(getUserDataProvider(member)).when(
                      data: (user) {
                        if (community.mods.contains(member) && counter == 0) {
                          uids.add(member);
                        }
                        counter++;
                        return CheckboxListTile(
                          value: uids.contains(user.uid),
                          onChanged: (val) {
                            if (val!) {
                              addUids(user.uid);
                            } else {
                              removeUids(user.uid);
                            }
                          },
                          title: Text(user.username),
                        );
                      },
                      error: (error, stackTrace) => ErrorText(
                        errortxt: error.toString(),
                      ),
                      loading: () => const Loader(),
                    );
              }),
          error: (error, stackTrace) => ErrorText(
                errortxt: error.toString(),
              ),
          loading: () => const Loader()),
    );
  }
}
