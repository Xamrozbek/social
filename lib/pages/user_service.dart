import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:social/auth/upload_and_delete_service.dart';
import 'package:social/enam/privacy_setting.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart'
    show VideoPlayer, VideoPlayerController;
import 'package:social/components/my_circle.dart';

import '../auth/auth_service.dart';
import '../auth/chat/chat_service.dart';
import '../util/toast_message.dart';
import '../utilities/constants.dart';

class UserService extends StatefulWidget {
  const UserService({super.key});

  @override
  State<UserService> createState() => _UserServiceState();
}

class _UserServiceState extends State<UserService> {
  final AuthService _auth = AuthService();
  final ChatService _chatService = ChatService();
  final UploadAndDeleteService _uploadService = UploadAndDeleteService();
  final ToastMessage toastMessage = ToastMessage();

  String? picUrl;
  String? username;
  String? email;
  File? _image, _video;
  final _pickerImage = ImagePicker();
  String? mediaType;
  late VideoPlayerController _videoController;
  late bool _isMuted = false;
  int _activeIndex = 0;
  int? selectedButton;
  String? selectedCollection;
  String _currentLocation = "Unknown";
  List<Map<String, dynamic>> mediaList = [];
  late final List<String> mediaDownloadURLs = [];

  List<String> category = [
    'Post',
    'Story',
    'Food',
    'Flight',
    'Auto',
    'Hotel',
    'Tour guide',
  ];
  List<String> option = [
    Constants().POSTS_COLLECTION,
    Constants().STORES_COLLECTION,
    Constants().FOOD_COLLECTION,
    Constants().FLIGHT_COLLECTION,
    Constants().AUTO_COLLECTION,
    Constants().HOTEL_COLLECTION,
    Constants().TOURGUIDE_COLLECTION,
  ];

  double _progress = 0.0;

  bool _isButtonPressed = false;

  final TextEditingController _contentController = TextEditingController();

  void addMedia(File file, String fileType) {
    setState(() {
      mediaList.add({'filePath': file, 'fileType': fileType});
    });
  }

  Future<void> uploadAllFiles() async {
    for (var media in mediaList) {
      File file = media['filePath'];
      String fileType = media['fileType'];

      String fileUrl = await uploadFile(file, fileType);
      if (fileUrl.isNotEmpty) {
        media['fileUrl'] = fileUrl;
        mediaDownloadURLs.add(fileUrl);
        print('Yuklangan URL: $fileUrl');
      } else {
        print('Fayl yuklashda xato: ${file.path}');
      }
    }
  }

  Future<String> uploadFile(File file, String fileType) async {
    try {
      String extension = fileType == 'image' ? 'jpg' : 'mp4';
      String filePath =
          'uploads/${DateTime.now().millisecondsSinceEpoch}.$extension';

      UploadTask uploadTask = FirebaseStorage.instance
          .ref(filePath)
          .putFile(file);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress =
            (snapshot.bytesTransferred.toDouble() /
                snapshot.totalBytes.toDouble()) *
            100;
        setState(() {
          _progress = progress;
        });
      });

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Fayl yuklashda xato: $e');
      return '';
    }
  }

  void uploadPost() async {
    setState(() {
      _isButtonPressed = true;
    });

    if (mediaList.isNotEmpty) {
      if (_contentController.text.isNotEmpty) {
        await uploadAllFiles();
        if (mediaDownloadURLs.isNotEmpty) {
          await _uploadService.uploadPost(
            selectedCollection.toString(),
            _contentController.text,
            mediaType,
            mediaDownloadURLs,
            PrivacySetting.public,
            picUrl.toString(),
            username!,
            mediaType == 'video'
                ? await uploadThumbnail(await getThumbnailImage(_video!.path))
                : '',
            _currentLocation,
            email!,
            context,
          );
          toastMessage.show('Post muvaffaqiyatli yuklandi!');
          mediaList.clear();
          _contentController.clear();
          _image = null;
          _video = null;
          _progress = 0;
        } else {
          toastMessage.show('Rasm yoki Video tanlang!');
        }
      } else {
        toastMessage.show('Post matni  bo\'sh bo\'lmasligi kerak!');
      }
    } else {
      toastMessage.show('Iltimos, media faylini tanlang!');
    }
    setState(() {
      _isButtonPressed = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentLocation = 'Location services are disabled!';
      });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentLocation = "Location permissions denied.";
        });
        return;
      }
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation =
          "Lat: ${position.latitude}, Lon: ${position.longitude}";
    });
  }

  void pickImage() async {
    final pickedPicPath = await _pickerImage.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedPicPath != null) {
      _image = File(pickedPicPath.path);
      mediaType = 'image';
      if (mediaList.isNotEmpty) {
        mediaList =
            mediaList.where((item) => item['fileType'] != 'video').toList();
      }
      addMedia(_image!, mediaType!);
      setState(() {
        _videoController.value.isPlaying ? _videoController.pause() : null;
      });
    }
  }

  void pickVideo() async {
    final pickedVideoPath = await _pickerImage.pickVideo(
      source: ImageSource.gallery,
    );
    if (pickedVideoPath != null) {
      _video = File(pickedVideoPath.path);
      mediaType = 'video';

      if (mediaList.isNotEmpty) {
        mediaList.clear();
      }
      addMedia(_video!, mediaType!);
      _initializeVideo();
      setState(() {});
    }
  }

  Future<File> getThumbnailImage(String videoFilePath) async {
    final thumbnailImage = await VideoCompress.getFileThumbnail(videoFilePath);
    return thumbnailImage;
  }

  Future<String> uploadThumbnail(File thumbnail) async {
    try {
      String filePath =
          'thumbnails/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance
          .ref(filePath)
          .putFile(thumbnail);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Thumbnail yuklashda xato: $e');
      return '';
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _togglePlayPause() {
    setState(() {
      _videoController.value.isPlaying
          ? _videoController.pause()
          : _videoController.play();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _videoController.pause();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(_video!);
    await _videoController.initialize();
    // _videoController.setLooping(true);
    _videoController.play();
  }

  Future<void> _loadUserData() async {
    final snapshot = await _chatService.getUserData(
      _auth.getCurrentUser()!.uid.toString(),
    );
    if (snapshot.exists) {
      final userData = snapshot.data() as Map<String, dynamic>;
      setState(() {
        picUrl = userData[Constants().PROFILE_IMAGE_URL];
        username = userData[Constants().USERNAME];
        email = userData[Constants().EMAIL];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('What is new?', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    _image == null && _video == null
                        ? Center(
                          child: SizedBox(
                            height: 200,
                            width: 200,
                            child: Lottie.network(
                              'https://lottie.host/6d10a3d2-f67a-49c3-9eb8-4a29666d5326/aWOcR6xNVw.json',
                            ),
                          ),
                        )
                        : SizedBox(
                          height: 500,
                          width: double.infinity,
                          child:
                              mediaType == 'image'
                                  ? _buildImageScreen()
                                  : _video != null
                                  ? _buildVideoScreen()
                                  : Center(child: Text('No video available')),
                        ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 125,
                width: double.infinity,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade500, width: .5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              picUrl ?? 'default_image_url',
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.person, size: 35),
                            ),
                          ),
                          SizedBox(width: 10),
                          SizedBox(
                            height: 40,
                            width: 230,
                            child: TextField(
                              controller: _contentController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Write something here...',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              style: TextStyle(color: Colors.grey.shade900),
                              obscureText: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0, left: 10),
                      child: Column(
                        children: [
                          LinearPercentIndicator(
                            lineHeight: 1,
                            percent: _progress / 100,
                            animation: true,
                            animationDuration: 1000,
                            progressColor: Colors.blue.shade900,
                            backgroundColor: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_buildPickerButton(), _buildShareButton()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Choose your option'),
            SizedBox(height: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(0),
                    SizedBox(width: 10),
                    _buildButton(1),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(2),
                    SizedBox(width: 10),
                    _buildButton(3),
                    SizedBox(width: 10),
                    _buildButton(4),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildButton(5),
                    SizedBox(width: 10),
                    _buildButton(6),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoScreen() {
    return Stack(
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(_videoController),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _toggleMute,
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
          child: CarouselSlider(
            items:
                mediaList.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        item['filePath'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  );
                }).toList(),
            options: CarouselOptions(
              autoPlay: mediaList.length > 1 ? true : false,
              aspectRatio: 16 / 9,
              height: 480,
              autoPlayCurve: Curves.fastOutSlowIn,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayInterval: const Duration(seconds: 2),
              enlargeCenterPage: true,
              onPageChanged: (index, reason) {
                setState(() {
                  _activeIndex = index;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 10),
        AnimatedSmoothIndicator(
          activeIndex: _activeIndex,
          count: mediaList.length,
          effect: WormEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 10,
            dotColor: Theme.of(context).colorScheme.inversePrimary,
            activeDotColor: Colors.blue.shade400,
            paintStyle: PaintingStyle.fill,
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    return GestureDetector(
      onTap: () {
        if (selectedCollection == null || selectedCollection!.isEmpty) {
          toastMessage.show('Choose option');
        } else {
          mediaList.isEmpty
              ? toastMessage.show('Choose media file!')
              : uploadPost();
          print('pressed');
        }
      },
      child: Container(
        height: 30,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                _isButtonPressed
                    ? [Colors.grey, Colors.grey]
                    : [Color(0xFF84D3FC), Color(0xFF7870DB)],
          ),
          border: Border.all(width: .5, color: Colors.blue.shade500),
        ),
        child: Center(
          child: Text(
            'Share',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPickerButton() {
    return Row(
      children: [
        MyCircle(
          icon: Icons.image,
          onTap: () {
            pickImage();
          },
        ),
        SizedBox(width: 5),
        MyCircle(
          icon: Icons.video_collection_rounded,
          onTap: () => pickVideo(),
        ),
        SizedBox(width: 5),
        MyCircle(icon: Icons.location_on, onTap: () {}),
      ],
    );
  }

  Widget _buildButton(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedButton = index;
          selectedCollection = option[index].toString();
        });
      },
      child: Container(
        height: 46,
        width: 100,
        decoration: BoxDecoration(
          color:
              selectedButton == index
                  ? Colors.blue
                  : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            category[index],
            style: TextStyle(
              fontWeight:
                  selectedButton == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
