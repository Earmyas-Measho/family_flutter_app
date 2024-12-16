import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Photo Gallery',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PhotoGallery(),
    );
  }
}

class PhotoGallery extends StatefulWidget {
  const PhotoGallery({super.key});

  @override
  State<PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<PhotoGallery> {
  List<String> uploadedImages = [];
  final String cloudName = 'dwyfyfnwa'; // Your cloud name
  final String uploadPreset = 'familyapp'; // Your upload preset name

  Future<void> _uploadFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        final file = result.files.first;
        
        // Show loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );

        // Create form data
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/dwyfyfnwa/image/upload'),
        );

        // Generate signature
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final paramsToSign = {
          'timestamp': timestamp.toString(),
          'upload_preset': 'familyapp',
        };
        
        // Add fields
        request.fields.addAll({
          'api_key': '513997152711328',
          'timestamp': timestamp.toString(),
          'upload_preset': 'familyapp',
        });

        // Add file
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );

        try {
          // Send request
          var response = await request.send();
          var responseData = await response.stream.toBytes();
          var responseString = String.fromCharCodes(responseData);
          print('Response: $responseString'); // Debug line
          
          if (response.statusCode == 200) {
            var jsonData = jsonDecode(responseString);
            setState(() {
              uploadedImages.add(jsonData['secure_url']);
            });
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploaded successfully!')),
            );
          } else {
            throw Exception('Upload failed with status: ${response.statusCode}');
          }
        } catch (e) {
          print('Error details: $e'); // Debug line
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: $e')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Photos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: uploadedImages.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            child: Column(
              children: [
                Expanded(
                  child: Image.network(
                    uploadedImages[index],
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Photo ${index + 1}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        tooltip: 'Upload Photo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
