import 'dart:math';

import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  const ChatView({
    super.key,
    required this.title,
    required this.image,
  });
  final String title;
  final String image;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  String? text;
  TextEditingController? _controller;
  final List<String> avatars = [
    'assets/images/person1.png',
    'assets/images/person2.png',
  ];
  final List<Message> messages = [
    Message(0,
        "But I may not go if the weather is bad. So lets see the weather condition 😀"),
    Message(0, "I suppose I am."),
    Message(1, "Are you going to market today?"),
    Message(0, "I am good too"),
    Message(1, "I am fine, thank you. How are you? "),
    Message(1, "Hi,"),
    Message(0, "How are you today?"),
    Message(0, "Hello,"),
  ];
  final rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                widget.image,
              ),
            ),
          ),
        ),
        title: Text(
          widget.title,
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              separatorBuilder: (context, index) {
                return const SizedBox(height: 10.0);
              },
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (BuildContext context, int index) {
                Message m = messages[index];
                if (m.user == 0) return _buildMessageRow(m, current: true);
                return _buildMessageRow(m, current: false);
              },
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Container _buildBottomBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30.0),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 20.0,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              textInputAction: TextInputAction.send,
              controller: _controller,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 20.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Colors.green.shade600,
                  ),
                ),
                hintText: "Aa",
              ),
              onEditingComplete: _save,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.green.shade600,
            onPressed: _save,
          )
        ],
      ),
    );
  }

  _save() async {
    if (_controller!.text.isEmpty) return;
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      messages.insert(0, Message(rand.nextInt(2), _controller!.text));
      _controller!.clear();
    });
  }

  Row _buildMessageRow(Message message, {required bool current}) {
    return Row(
      mainAxisAlignment:
          current ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment:
          current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: current ? 30.0 : 20.0),
        if (!current) ...[
          CircleAvatar(
            backgroundImage: AssetImage(
              current ? avatars[0] : avatars[1],
            ),
            radius: 20.0,
          ),
          const SizedBox(width: 5.0),
        ],

        ///Chat bubbles
        Container(
          padding: const EdgeInsets.only(
            bottom: 5,
            right: 5,
          ),
          child: Column(
            crossAxisAlignment:
                current ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                  minHeight: 40,
                  maxHeight: 250,
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                  minWidth: MediaQuery.of(context).size.width * 0.1,
                ),
                decoration: BoxDecoration(
                  color: current ? Colors.red : Colors.white,
                  borderRadius: current
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    top: 10,
                    bottom: 5,
                    right: 5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: current
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 10,
                        ),
                        child: Text(
                          message.description,
                          style: TextStyle(
                            color: current ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.done_all,
                        color: Colors.white,
                        size: 14,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                "2:02",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.5),
                ),
              )
            ],
          ),
        ),
        if (current) ...[
          const SizedBox(width: 5.0),
          CircleAvatar(
            backgroundImage: AssetImage(
              current ? avatars[0] : avatars[1],
            ),
            radius: 10.0,
          ),
        ],
        SizedBox(
          width: current ? 20.0 : 30.0,
        ),
      ],
    );
  }
}

class Message {
  final int user;
  final String description;

  Message(
    this.user,
    this.description,
  );
}
