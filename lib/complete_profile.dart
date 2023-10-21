import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'homepage.dart';
import 'models/ui_helper.dart';
import 'models/user_model.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({
    super.key,
    required this.userModel,
    required this.firebaseUser,
  });

  final UserModel userModel;
  final User firebaseUser;

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  Future _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;

      File? pickImage = File(image.path);
      pickImage = await _cropImage(imageFiles: pickImage);
      setState(() {
        imageFile = pickImage;
      });
    } on PlatformException catch (e) {
      UIHelper.showAlertDialog(
        context,
        "Error",
        e.message.toString(),
      );
    }
  }

  Future<File?> _cropImage({required File imageFiles}) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: imageFiles.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );
    if (croppedImage == null) return null;

    return File(croppedImage.path);
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo_album),
                  title: const Text("Select from Gallery"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take a photo"),
                ),
              ],
            ),
          );
        });
  }

  void checkValues() {
    String fullname = fullNameController.text.trim();

    if (fullname == "" || imageFile == null) {
      UIHelper.showAlertDialog(context, 'Incomplete', "Fill all fields");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UIHelper.showLoadingDialog(context, "Uploading image...");
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;

    String? imageUrl = await snapshot.ref.getDownloadURL();
    String? fullname = fullNameController.text.trim();

    widget.userModel.fullName = fullname;
    widget.userModel.profileImage = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return MyHome(
            userModel: widget.userModel,
            firebaseUser: widget.firebaseUser,
          );
        }),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        centerTitle: true,
        title: const Text('Complete Profile'),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 40,
          ),
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                padding: const EdgeInsets.all(0),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? const Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                ),
              ),
              const SizedBox(
                height: 30,
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
                  onPressed: () {
                    checkValues();
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
