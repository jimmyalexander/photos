import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PhotoPage(),
    );
  }
}

class PhotoPage extends StatefulWidget {
  @override
  _PhotoPageState createState() => _PhotoPageState();
}

class _PhotoPageState extends State<PhotoPage> {
  final ImagePicker _picker = ImagePicker();
  List<String> _photosUrls = [];

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = path.basename(imageFile.path);
      UploadTask uploadTask =
          FirebaseStorage.instance.ref('photos/$fileName').putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _photosUrls.add(downloadUrl);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo App'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _takePhoto,
            child: Text('Take Photo'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _photosUrls.length,
              itemBuilder: (context, index) {
                return Image.network(_photosUrls[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
