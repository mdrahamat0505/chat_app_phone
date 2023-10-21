import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'chat_room_page.dart';
import 'main.dart';
import 'models/chat_room_model.dart';
import 'models/user_model.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const SearchPage({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoom(UserModel targetUser) async {
    ChatRoomModel? chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatRoom")
        .where("participant.${widget.userModel.uid}", isEqualTo: true)
        .where(
          "participant.${targetUser.uid}",
          isEqualTo: true,
        )
        .get();
    if (snapshot.docs.isNotEmpty) {
      var docData = snapshot.docs[0].data();
      ChatRoomModel existingChat = ChatRoomModel.fromMap(
        docData as Map<String, dynamic>,
      );
      chatRoom = existingChat;
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
        chatRoomId: uuid.v1(),
        lastMessage: "",
        participant: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
        allUsers: [
          widget.userModel.toString(),
          targetUser.uid.toString(),
        ],
        createdon: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(newChatRoom.chatRoomId)
          .set(
            newChatRoom.toMap(),
          );

      chatRoom = newChatRoom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Page'),
      ),
      body: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: "Full Name",
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          CupertinoButton(
            onPressed: () {
              setState(() {});
            },
            color: Theme.of(context).colorScheme.secondary,
            child: const Text("Search"),
          ),
          const SizedBox(
            height: 20,
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where(
                  "fullName",
                  isEqualTo: searchController.text,
                )
                .where(
                  "fullName",
                  isNotEqualTo: widget.userModel.fullName,
                )
                .snapshots(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;

                  if (datasnapshot.docs.isNotEmpty) {
                    Map<String, dynamic> userMap =
                        datasnapshot.docs[0].data() as Map<String, dynamic>;

                    UserModel searchUser = UserModel.fromMap(userMap);
                    return ListTile(
                      onTap: () async {
                        ChatRoomModel? chatroomModel =
                            await getChatRoom(searchUser);

                        if (chatroomModel != null) {
                          if (!mounted) return;
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ChatRoomPage(
                                  targetUser: searchUser,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser,
                                  chatRoom: chatroomModel,
                                );
                              },
                            ),
                          );
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[400],
                        backgroundImage: NetworkImage(
                          searchUser.profileImage!,
                        ),
                      ),
                      title: Text(
                        searchUser.fullName!,
                      ),
                      subtitle: Text(
                        searchUser.phoneNumber!,
                      ),
                      trailing: const Icon(
                        Icons.keyboard_arrow_right,
                      ),
                    );
                  } else {
                    return const Text('No result found');
                  }
                } else if (snapshot.hasError) {
                  return const Text("An error occured!");
                } else {
                  return const Text("No results found!");
                }
              } else {
                return const CircularProgressIndicator();
              }
            }),
          )
        ],
      ),
    );
  }
}
