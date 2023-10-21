import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  String? chatRoomId;
  Map<String, dynamic>? participant;
  String? lastMessage;
  List<dynamic>? allUsers;
  DateTime? createdon;

  ChatRoomModel({
    this.chatRoomId,
    this.participant,
    this.lastMessage,
    this.allUsers,
    this.createdon,
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatRoomId = map["chatRoomId"];
    participant = map["participant"];
    lastMessage = map["lastMessage"];
    allUsers = map["allUsers"];
    createdon = (map["createdon"] as Timestamp).toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "chatRoomId": chatRoomId,
      "participant": participant,
      "lastMessage": lastMessage,
      "allUsers": allUsers,
      "createdon": createdon,
    };
  }
}
