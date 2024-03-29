import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:word_wall/auth/notification_services.dart';
import 'package:word_wall/components/myTextFormFields.dart';
import 'package:word_wall/components/my_drawer.dart';
import 'package:word_wall/components/post.dart';
import 'package:word_wall/constants.dart';
import 'package:word_wall/helper/helper_methods.dart';
import 'package:word_wall/pages/profile_page.dart';
import 'dart:developer';

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  // text controller
  final textController = TextEditingController();

  // notification Controller
  NotificationServices notificationServices = NotificationServices();

  // scroll controller
  ScrollController scrollController = ScrollController();

  // Scroll Controller

  // pickedfile
  PlatformFile? pickedfile;
  bool permissionGranted = false;
  bool isLoading = false;
  bool showPostMessageField = false;

  String? ImageURL = ''; // image url from firebase storage

  String _username = ''; //curren user name

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  fetchUserName() async {
    final userData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser.email)
        .get();

    final username = userData.data()!['username'];
    setState(() {
      _username = username;
    });
    return username;
  }

  void postmessage() async {
    // if textfield is empty but image is picked
    if (textController.text.isEmpty && pickedfile != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: 1000.ms,
        backgroundColor: Colors.red,
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
        content: Row(
          children: [
            Text(
              'Please write some message',
              style: TextStyle(color: Colors.white),
            ),
            10.h.horizontalSpace,
            Icon(
              Icons.error,
              color: Colors.white,
              size: 24.sp,
            ).animate().fade(duration: 300.ms).scaleXY(begin: 0, end: 1.0)
          ],
        ),
      ));
    }

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

      await sendFCMNotificationToTopic();

      // clear the image url and picked file
      setState(() {
        pickedfile = null;
        ImageURL = '';
      });

      // pop loading circle

      Navigator.pop(context);

      // clear the textfield

      textController.clear();

      ScrollToTop();

      // show snackbar

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: 1000.ms,
        backgroundColor: Color(0xff00B4D8),
        dismissDirection: DismissDirection.horizontal,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
        content: Row(
          children: [
            Text(
              'Posted successfully',
              style: TextStyle(color: Colors.white),
            ),
            10.h.horizontalSpace,
            Icon(
              Icons.check,
              size: 24.sp,
            ).animate().fade(duration: 300.ms).scaleXY(begin: 0, end: 1.0),
          ],
        ),
      ));
    }
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Get.to(() => ProfilePage(), transition: Transition.fadeIn);
  }

  void ScrollToTop() {
    return WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // Scroll to the bottom of the list after new data is loaded
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
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
    _getStoragePermission();
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

  // show post message field when user scroll up

  Future<void> sendFCMNotificationToTopic() async {
    try {
      var currentDeviceToken = await notificationServices.getDeviceToken();
      // Get all user tokens from Firestore
      QuerySnapshot tokenSnapshot =
          await FirebaseFirestore.instance.collection('Users').get();
      List tokens = tokenSnapshot.docs
          .map((doc) => doc['device token'])
          .where((token) => token != currentDeviceToken)
          .toList();

      log('Tokens: ${tokens.length}');

      // Construct the message
      var message = {
        'registration_ids': tokens,
        'priority': 'high',
        'notification': {
          'title': '${_username} added a new Post ! ',
          'body': 'Check out what he is upto :)',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
        }
      };

      // Send the message to the Firebase Cloud Messaging topic
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAAr2uLlVY:APA91bGrDo-ixGSqaNwspdFc0XzbZXqS43Meyk3gwfqOq6dYYv9H1PWK4X1sbLC-DGb4ZUs___1jsvOUXix63VDB2ngzx6QLSSGdjJC9z9Gy6tiS5XTMjn6rSSrLi1SR1AkZ2zcpJr0G'
          },
          body: jsonEncode(message));

      // Send the message
    } catch (e) {
      print('Error sending FCM notification: $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.isTokenRefresh();
    notificationServices
        .getDeviceToken()
        .then((value) => log('Device Token: $value'));
    fetchUserName();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text('Pulse',
            style: TextStyle(
                fontFamily: GoogleFonts.righteous().fontFamily,
                color: Theme.of(context).colorScheme.onPrimary)),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          // newsfeed
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
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
                    return SizedBox(
                      height: 500.h,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }),
            ),
          ),

          // post message field

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                PostMessageField(
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
                      FocusManager.instance.primaryFocus!.unfocus();
                      pickImage();
                    }),
                IconButton(
                    onPressed: () async {
                      postmessage();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ))
              ],
            ),
          ),

          // image preview
          if (pickedfile != null)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                padding: EdgeInsets.all(15),
                child: Stack(children: [
                  // image

                  ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: Image.file(File(pickedfile!.path!),
                          fit: BoxFit.cover)),

                  // cancel button

                  Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            pickedfile = null;
                          });
                        },
                        icon: Icon(Icons.cancel),
                      ))
                ]),
              ),
            ),
          // current user name
          // Padding(
          //   padding: EdgeInsets.only(bottom: 15.h),
          //   child: Container(
          //     padding: EdgeInsets.all(10.sp),
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(8.r),
          //       color: Theme.of(context).colorScheme.tertiary,
          //     ),
          //     child: Text('Logged in as ' + _username,
          //         style: TextStyle(color: Colors.white)),
          //   ),
          // ),
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
    return Expanded(
      child: Scrollbar(
        thickness: 4.w,
        child: TextField(
          scrollPhysics: BouncingScrollPhysics(),
          keyboardType: TextInputType.multiline,
          maxLines: 6,
          minLines: 1,
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
        ),
      ),
    );
  }
}
