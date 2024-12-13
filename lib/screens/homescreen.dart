import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:message_in_a_botlle/models/user_model.dart';
import 'package:message_in_a_botlle/providers/auth_provider.dart';
import 'package:message_in_a_botlle/providers/search_user_provider.dart';
import 'package:message_in_a_botlle/providers/user_provider.dart';
// import 'package:message_in_a_botlle/routes.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<User> _filteredUsers = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // homePageRefreshNotifier.refresh();
      try {
        await ref.read(userProvider.notifier).fetchUserProfile();
        await ref.read(searchProvider.notifier).fetchUsers();
        await ref.read(searchProvider.notifier).fetchVisibleUsers();
      } catch (e) {
        print("Home Page Initialization error: $e");
      }
    });
  }

  void _filterUsers(String searchTerm) {
    final allUsers = ref.read(searchProvider).allUsers;
    if (searchTerm.isNotEmpty) {
      setState(() {
        _filteredUsers = allUsers
            .where((user) => "${user.firstName} ${user.lastName}"
                .toLowerCase()
                .contains(searchTerm.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        _filteredUsers = [];
      });
    }
    print(_filteredUsers);
  }

  void handleLogout(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure you want to logout"),
      actions: [
        TextButton(
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go("/auth/login");
            },
            child: const Text("Yes")),
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("No")),
      ],
    );

    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.read(userProvider);
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            "assets/logos/miab.png",
            fit: BoxFit.contain,
            width: 96,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Users'),
            ],
          ),
          actions: [
            userState.user!.isPremium
                ? const SizedBox()
                : TextButton(
                    onPressed: () {
                      context.push("/enable-ai");
                    },
                    child: const Text("Enable Ai")),
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                  onTap: () {
                    context.push("/edit-profile");
                    // context.pop();
                  },
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    handleLogout(context);
                  },
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  userState.user?.avatar ??
                      "https://img.freepik.com/free-psd/3d-icon-social-media-app_23-2150049569.jpg?t=st=1733298836~exp=1733302436~hmac=1f15270d55a1c3142a5cbd171f3c553dc74b45bc25afb5e19257171d3339169e&w=740",
                ),
                radius: 16,
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/bg_chat.png"),
                      fit: BoxFit.cover,
                      opacity: 0.3)),
              child: ZIMKitConversationListView(
                onPressed: (context, conversation, defaultAction) {
                  context.push("/chat", extra: {
                    "firstName": conversation.name,
                    "lastName": "",
                    "mobile": "",
                    "avatar": conversation.avatarUrl,
                    "id": conversation.id,
                  });
                },
                onLongPress: (context, conversation, longPressDownDetails,
                    defaultAction) {
                  final conversationBox =
                      context.findRenderObject()! as RenderBox;
                  final offset = conversationBox.localToGlobal(
                      Offset(0, conversationBox.size.height / 2));

                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      longPressDownDetails.globalPosition.dx,
                      offset.dy,
                      longPressDownDetails.globalPosition.dx,
                      offset.dy,
                    ),
                    items: [
                      const PopupMenuItem(value: 0, child: Text('Delete Chat')),
                      if (conversation.type == ZIMConversationType.group)
                        const PopupMenuItem(
                            value: 1, child: Text('Leave Group')),
                    ],
                  ).then((value) {
                    if (context.mounted) {
                      switch (value) {
                        case 0:
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text(
                                    'Do you want to delete this conversation?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ZIMKit().deleteConversation(
                                          conversation.id, conversation.type);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                          break;
                        case 1:
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text(
                                    'Do you want to leave this group?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ZIMKit().leaveGroup(conversation.id);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                          break;
                      }
                    }
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/bg_chat.png"),
                      fit: BoxFit.cover,
                      opacity: 0.3)),
              child: Column(
                children: [
                  SearchBar(
                    hintText: "Search users by name",
                    autoFocus: false,
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        setState(() {
                          isSearching = false;
                        });
                      } else {
                        setState(() {
                          isSearching = true;
                        });
                      }
                      _filterUsers(value);
                    },
                  ),

                  // Filtered User should show here
                  const SizedBox(
                    height: 16,
                  ),
                  if (searchState.isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else if (_filteredUsers.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredUsers.length,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(user.avatar),
                              radius: 16,
                            ),
                            title: Text("${user.firstName} ${user.lastName}"),
                            subtitle: Text(user.mobile),
                            onTap: () {
                              searchNotifier.saveVisibleUser(user.id);
                              context.push("/chat", extra: {
                                "firstName": user.firstName,
                                "lastName": user.lastName,
                                "mobile": user.mobile,
                                "avatar": user.avatar,
                                "id": user.id,
                              });
                            },
                          );
                        },
                      ),
                    ),

                  if (!isSearching &&
                      searchState.visibleUsers != null &&
                      searchState.visibleUsers!.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: searchState.visibleUsers!.length,
                      itemBuilder: (context, index) {
                        final user = searchState.visibleUsers![index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user.avatar),
                            radius: 16,
                          ),
                          title: Text("${user.firstName} ${user.lastName}"),
                          subtitle: Text(user.mobile),
                          onTap: () async {
                            context.push("/chat", extra: {
                              "firstName": user.firstName,
                              "lastName": user.lastName,
                              "mobile": user.mobile,
                              "avatar": user.avatar,
                              "id": user.id,
                            });
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
