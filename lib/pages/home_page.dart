import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:word_wall/components/myTextFormFields.dart';
import 'package:word_wall/components/my_drawer.dart';
import 'package:word_wall/components/post.dart';
import 'package:word_wall/constants.dart';
import 'package:word_wall/helper/helper_methods.dart';
import 'package:word_wall/pages/profile_page.dart';
import 'dart:developer';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  // scroll controller
  ScrollController scrollController = ScrollController();

  // pickedfile
  PlatformFile? pickedfile;
  bool permissionGranted = false;
  bool isLoading = false;

  String? ImageURL = ''; // image url from firebase storage

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void postmessage() async {
    // if text field is not empty
    if (textController.text.isNotEmpty) {
      // show loading circle
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          });

      // fetching user name
      final userData = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .get();

      final username = userData.data()!['username'];

      if (pickedfile != null) {
        await uploadImageToFirebase();
      }

      // Check if ImageURL is empty, if so, set it to null
      ImageURL = ImageURL!.isNotEmpty ? ImageURL : null;

      // add post in firestore
      FirebaseFirestore.instance.collection('User Posts').add({
        'Message': textController.text,
        'UserEmail': currentUser.email,
        'TimeStamp': Timestamp.now(),
        'username': username,
        'Likes': [],
        'Image': ImageURL,
      });

      // clear the image url and picked file
      setState(() {
        pickedfile = null;
        ImageURL = '';
      });

      // pop loading circle

      Navigator.pop(context);

      // clear the textfield

      textController.clear();
    }
  }

  void goToProfilePage() {
    Get.back();
    Get.to(() => ProfilePage(), transition: Transition.fadeIn);
  }

  void ScrollToTop() {
    return WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // Scroll to the bottom of the list after new data is loaded
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  // getting storage permission from user
  Future _getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        permissionGranted = true;
      });
    }
  }

  // picking file from gallery
  Future pickImage() async {
    log('pick Image function called');
    // _getStoragePermission();
    // Set isLoading to true to display loading icon
    setState(() {
      isLoading = true;
    });

    // picking file using file picker package
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result == null) {
      log('No file selected');
      // Set isLoading to true to display loading icon
      setState(() {
        isLoading = false;
      });
      return;
    }

    // get the file
    setState(() {
      pickedfile = result.files.first;
      log(pickedfile!.name.toString());
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: 1000.ms,
      backgroundColor: Color(0xff00B4D8),
      dismissDirection: DismissDirection.horizontal,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
      content: Row(
        children: [
          Text(
            'Image Loaded successfully',
            style: TextStyle(color: Colors.white),
          ),
          10.h.horizontalSpace,
          Icon(
            Icons.check,
            size: 24.sp,
          ).animate().fade(duration: 300.ms).scaleXY(begin: 0, end: 1.0)
        ],
      ),
    ));
  }

  // Function to upload image to Firebase Storage
  Future uploadImageToFirebase() async {
    log('uploading image to firebase');
    log(pickedfile!.path.toString());

    if (pickedfile != null) {
      try {
        // timestamp
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        // path of the posted images to be stored on firestorage
        final path = 'post_images/${timestamp}-${pickedfile!.name}';

        // image to be uploaded
        final file = File(pickedfile!.path!);

        final storageReference = FirebaseStorage.instance.ref().child(path);

        // uploading image

        final uploadTask = storageReference.putFile(file);
        log('image uploaded');

        final snapshot = await uploadTask.whenComplete(() {});

        ImageURL = await snapshot.ref.getDownloadURL();
        log('Download-Link: $ImageURL');
      } catch (e) {
        print('Error uploading image: $e');
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Word Wall',
        ),
      ),
      body: Center(
        child: Column(children: [
          // newsfeed
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('User Posts')
                      .orderBy('TimeStamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        controller: scrollController,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          // get the message
                          final post = snapshot.data!.docs[index];

                          return Post(
                            message: post['Message'],
                            user: post['username'],
                            userEmail: post['UserEmail'],
                            postId: post.id,
                            likes: List<String>.from(post['Likes'] ?? []),
                            time: FormatedDate(post['TimeStamp']),
                            imageUrl: post['Image'],
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }
                    return Center(
                        child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ));
                  }),
            ),
          ),

          // post message field
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: PostMessageField(
                      textController: textController,
                      onTap: () {},

                      // image upload button

                      prefix: isLoading
                          ? Icon(
                              Icons.more_horiz_outlined,
                              size: 24.sp,
                            )
                              .animate(
                                onPlay: (controller) => controller.repeat(),
                              )
                              .fade()
                              .rotate()
                          : Icon(
                              Icons.image,
                              size: 24.sp,
                            ),
                      onTapPrefix: () {
                        pickImage();
                      }),
                ),
                IconButton(
                    onPressed: () async {
                      postmessage();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ))
              ],
            ),
          ),
          // current user email
          Padding(
            padding: EdgeInsets.only(bottom: 15.h),
            child: Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Theme.of(context).colorScheme.tertiary,
              ),
              child: Text('Logged in as ' + currentUser.email!,
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

class PostMessageField extends StatefulWidget {
  PostMessageField({
    super.key,
    required this.textController,
    required this.onTap,
    required this.prefix,
    this.onTapPrefix,
  });

  final TextEditingController textController;
  final void Function()? onTap;
  final Widget? prefix;
  final void Function()? onTapPrefix;

  @override
  State<PostMessageField> createState() => _PostMessageFieldState();
}

class _PostMessageFieldState extends State<PostMessageField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Theme.of(context).colorScheme.onTertiary,
      onTap: widget.onTap,
      style: TextStyle(
        // height: 1.h,
        fontSize: 16.sp,
      ),
      controller: widget.textController,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus!.unfocus();
      },
      decoration: InputDecoration(
        prefixIcon: GestureDetector(
          child: widget.prefix,
          onTap: widget.onTapPrefix,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 15.w),
        filled: true,
        fillColor: Theme.of(context).colorScheme.primary,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(4.r),
        ),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 1.w,
        )),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onTertiary,
            width: 1.w,
          ),
          borderRadius: BorderRadius.circular(4.r),
        ),
        hintText: 'Write your thoughts..',
        hintStyle: TextStyle(
          fontSize: 16.sp,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
