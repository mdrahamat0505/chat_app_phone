import 'package:chat_app_phone/phone.dart';
import 'package:chat_app_phone/search_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import 'chat_room_page.dart';
import 'models/chat_room_model.dart';
import 'models/firebase_helper.dart';
import 'models/user_model.dart';

class MyHome extends StatefulWidget {
  const MyHome({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  final UserModel userModel;
  final User firebaseUser;

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text(
          'My Home',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) {
                  return const MyPhone();
                }),
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("chatRoom")
              .where("allUsers", arrayContains: widget.userModel.uid)
              .orderBy("createdon")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;
                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                      chatRoomSnapshot.docs[index].data()
                          as Map<String, dynamic>,
                    );
                    Map<String, dynamic> participants =
                        chatRoomModel.participant!;
                    List<String> participantKey = participants.keys.toList();
                    participantKey.remove(widget.userModel.uid);

                    return FutureBuilder(
                      future: FirebaseHelper.getUserModel(participantKey[0]),
                      builder: (context, userData) {
                        if (userData.connectionState == ConnectionState.done) {
                          if (userData.data != null) {
                            UserModel targetUser = userData.data as UserModel;
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChatRoomPage(
                                        targetUser: targetUser,
                                        chatRoom: chatRoomModel,
                                        userModel: widget.userModel,
                                        firebaseUser: widget.firebaseUser,
                                      );
                                    },
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  targetUser.profileImage.toString(),
                                ),
                              ),
                              title: Text(
                                targetUser.fullName.toString(),
                              ),
                              subtitle:
                                  (chatRoomModel.lastMessage.toString() != "")
                                      ? Text(
                                          chatRoomModel.lastMessage.toString(),
                                        )
                                      : const Text("Say Hi..!"),
                            );
                          } else {
                            return Container();
                          }
                        } else {
                          return Container();
                        }
                      },
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                  ),
                );
              } else {
                return const Center(
                  child: Text('No Chats'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return SearchPage(
                  userModel: widget.userModel,
                  firebaseUser: widget.firebaseUser,
                );
              },
            ),
          );
        },
        child: const Icon(
          Icons.search,
        ),
      ),
    );
  }
}
