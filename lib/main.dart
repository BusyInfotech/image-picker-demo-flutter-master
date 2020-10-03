import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:async/async.dart';
import 'dart:io' as Io;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as ImageLib;


import 'package:image_picker_demo_flutter/ProgressDialog.dart';

import 'package:flutter_native_image/flutter_native_image.dart';


void main() => runApp(MyApp());
ProgressDialog progressDialog;
TextEditingController qualitycontroller = TextEditingController();
String quality;
int len;
String result;
var qualityvalue;
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Image Picker Demo'),

    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final ImagePicker _imagePicker = ImagePickerChannel();

  File _imageFile;

  Future<void> captureImage(ImageSource imageSource) async {
    try {
//


//
    final imageFile= await ImagePicker.pickImage(source: imageSource);
     setState(() {
       _imageFile = imageFile;
       _showAlertDialog(_imageFile);


      });
    } catch (e) {
      print(e);
    }
  }

  
  

  upload(File imageFile) async {
    // open a bytestream
    File varimage;
    File compressedsFile;
    final bytes = Io.File(imageFile.path).readAsBytesSync();
    //ImageLib.Image image = ImageLib.decodeImage(imageFile.readAsBytesSync());

    //varimage = new File(imageFile.path)..writeAsBytesSync(ImageLib.encodeJpg(image,quality: 50));
   // List<int> imageBytes = varimage.readAsBytesSync();
    compressedsFile = await FlutterNativeImage.compressImage(imageFile.path,
        quality: qualityvalue, percentage: 100);
     List<int> imageBytes = compressedsFile.readAsBytesSync();

    String img64 = base64Encode(imageBytes);
    try {
      http.Response response = await http.post(
          Uri.encodeFull("http://busyfcm.btmp.in/FCMServices.ashx"),
          headers: {
            "BDEPCode" : "1002",
            "SC" : "31",
            "FileName" :  result + ".jpg",
          },
        body: img64,

      );

      if (response.body == "T") {
       success();
       // return Text('upload', style: TextStyle(fontSize: 18.0));


      } else {
        String ErrDesc = response.headers['description'];
       // Toast.("Access Denied", ErrDesc);
      }
    } catch (e) {
      //_failuredialog("Access Denied", "Error Description : $e");
    }
  }
  Widget _buildImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile);
    } else {
      return Text('Take an image to start', style: TextStyle(fontSize: 18.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildImage())),


          _buildButtons(),
        ],

      ),

    );
  }

  Widget _buildButtons() {
    return ConstrainedBox(
        constraints: BoxConstraints.expand(height: 80.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                key: Key('retake'),
                text: 'Photos',
                onPressed: () => captureImage(ImageSource.gallery),

              ),
              _buildActionButton(
                key: Key('upload'),
                text: 'Camera',
                onPressed: () => captureImage(ImageSource.camera),
              ),
            ]

        ));

  }

  Widget _buildActionButton({Key key, String text, Function onPressed}) {
    return Expanded(
      child: FlatButton(
          key: key,
          child: Text(text, style: TextStyle(fontSize: 20.0)),
          shape: RoundedRectangleBorder(),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: onPressed),
    );
  }

  void _showAlertDialog(File imageFile) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Check Image Quality"),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
TextFormField(
  controller: qualitycontroller,

  decoration: InputDecoration(
    hintText: ' Enter quality',

    isDense: true,
    // Added this
    contentPadding: EdgeInsets.all(11),
    labelStyle:
    TextStyle(fontSize: 16.0,
    color: Colors.black,
    height: 1.0,
    fontWeight: FontWeight.bold),
    errorStyle: TextStyle(
    color: Colors.red, fontSize: 15.0),
    border: new OutlineInputBorder(

    borderRadius: new BorderRadius.circular(07.0),
    ),
          ),
          ),

            ]

    ),),
          actions: <Widget>[
            FlatButton(
              child: Text('SUBMIT'),
              onPressed: () {
                Random random = new Random();
                int randomNumber = random.nextInt(100);
result = randomNumber.toString();
             var quality = qualitycontroller.text.toString();
               qualityvalue = int.parse(quality);
                upload(imageFile);
                Navigator.pop(context);

              },
            ),
          ],
        ),);}



  void success() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("upload success"),
        content: SingleChildScrollView(
          child: ListBody(
              children: <Widget>[
                TextField(

                ),

              ]

          ),),
        actions: <Widget>[
    FlatButton(
    child: Text('ok'),
    onPressed: () {
      Navigator.pop(context);

    })
        ],
      ),);}





}


