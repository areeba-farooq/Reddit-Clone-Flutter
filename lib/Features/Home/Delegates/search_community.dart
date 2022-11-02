import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/Common/error_text.dart';
import 'package:reddit_clone/Common/loader.dart';
import 'package:reddit_clone/Features/Community/controller/community_controller.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  //!to get the search community provider.
  final WidgetRef ref;
  SearchCommunityDelegate(this.ref);

  //! end part of the Appbar
  //? all the search query init gets remove
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          //*query is form searchdelegate itself
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  //!Drawer part in the appbar

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

//!whatever result come out when we search
  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

//! whatever suggestions we will get while searching
  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommunityProvider(query)).when(
          data: (communities) => ListView.builder(
            itemCount: communities.length,
            itemBuilder: (BuildContext context, int index) {
              final community = communities[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(community.avatar),
                ),
                title: Text('r/${community.name}'),
                onTap: () => navtoCommunityScreen(context, community.name),
              );
            },
          ),
          error: (error, stackTrace) => ErrorText(
            errortxt: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }

  void navtoCommunityScreen(BuildContext context, String communityName) {
    Routemaster.of(context).push('/r/$communityName');
  }
}
