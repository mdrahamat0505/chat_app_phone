import 'package:chat_app_phone/complete_profile.dart';
import 'package:chat_app_phone/models/ui_helper.dart';
import 'package:chat_app_phone/models/user_model.dart';
import 'package:chat_app_phone/phone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';


class MyVerify extends StatefulWidget {
  const MyVerify({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  final String phoneNumber;

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  FirebaseAuth auth = FirebaseAuth.instance;
  var code = "";

  void inputData() async {
    User? user = auth.currentUser;
    final uid = user!.uid;

    UserModel newUser = UserModel(
      uid: uid,
      phoneNumber: widget.phoneNumber,
      fullName: "",
      profileImage: "",
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .set(
          newUser.toMap(),
        )
        .then(
      (value) {
        getData();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return CompleteProfile(
                userModel: newUser,
                firebaseUser: auth.currentUser!,
              );
            },
          ),
        );
      },
    );
  }

  void getData() async {
    final User user = auth.currentUser!;
    final uid = user.uid;

    DocumentSnapshot userData =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    UserModel userModel = UserModel.fromMap(
      userData.data() as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 25, right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/img1.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "Phone Verification",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "We need to register your phone without getting started!",
                style: TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 30,
              ),
              Pinput(
                length: 6,
                onChanged: (value) {
                  code = value;
                },
                showCursor: true,
                onCompleted: (pin) {},
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      PhoneAuthCredential credential =
                          PhoneAuthProvider.credential(
                        verificationId: MyPhone.verify,
                        smsCode: code,
                      );
                      await auth.signInWithCredential(credential);
                      inputData();
                    } catch (e) {
                      UIHelper.showAlertDialog(
                        context,
                        "Error",
                        "Error Occured",
                      );
                    }
                  },
                  child: const Text("Verify Phone Number"),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'completprofile');
                      // Navigator.pushNamedAndRemoveUntil(
                      //   context,
                      //   'phone',
                      //   (route) => false,
                      // );
                    },
                    child: const Text(
                      "Edit Phone Number ?",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
