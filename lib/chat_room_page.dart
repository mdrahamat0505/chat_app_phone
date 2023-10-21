import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'models/chat_room_model.dart';
import 'models/message_model.dart';
import 'models/user_model.dart';


class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;
  const ChatRoomPage({
    super.key,
    required this.targetUser,
    required this.chatRoom,
    required this.userModel,
    required this.firebaseUser,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String myMessage = messageController.text.trim();
    messageController.clear();

    if (myMessage != "") {
      MessageModel newMessage = MessageModel(
        messageId: uuid.v1(),
        text: myMessage,
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        seen: false,
      );

      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(widget.chatRoom.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      widget.chatRoom.lastMessage = myMessage;
      FirebaseFirestore.instance
          .collection("chatRoom")
          .doc(widget.chatRoom.chatRoomId)
          .set(
        widget.chatRoom.toMap(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              backgroundImage: NetworkImage(
                widget.targetUser.profileImage.toString(),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              widget.targetUser.fullName.toString(),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("chatRoom")
                    .doc(widget.chatRoom.chatRoomId)
                    .collection("messages")
                    .orderBy(
                  "createdon",
                  descending: true,
                )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      QuerySnapshot dataSnapshot =
                      snapshot.data as QuerySnapshot;

                      return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMessages = MessageModel.fromMap(
                            dataSnapshot.docs[index].data()
                            as Map<String, dynamic>,
                          );
                          return Row(
                            mainAxisAlignment:
                            (currentMessages.sender == widget.userModel.uid)
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: (currentMessages.sender ==
                                      widget.userModel.uid)
                                      ? const Color.fromARGB(255, 218, 200, 200)
                                      : const Color.fromARGB(255, 249, 238, 86),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  currentMessages.text.toString(),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text("An error occured"),
                      );
                    } else {
                      return const Center(
                        child: Text("Say hi to friend"),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Text Message",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: const Icon(
                    Icons.send,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}