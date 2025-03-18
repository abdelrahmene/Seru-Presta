import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:asgsa_app/services/Cloudinary.dart';
import 'package:flutter/services.dart';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _imageUrl;
  String? _imageName;

  Future<void> _pickAndUploadImage() async {
    print("📸 Début du processus de sélection et d'upload d'image...");

    try {
      // Vérification des permissions pour la galerie
      var status = await Permission.storage.status;
      print("🔍 État initial de la permission stockage : $status");

      if (!status.isGranted) {
        print("🛑 Permission non accordée, demande en cours...");
        status = await Permission.storage.request();
        print("📢 Nouvelle état de la permission : $status");
      }

      if (status.isGranted) {
        print("✅ Permission accordée ! Ouverture de la galerie...");
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
            _imageName = pickedFile.name; // Récupération du nom du fichier
          });
          print("📂 Image sélectionnée : $_imageName (${pickedFile.path})");

          // Upload de l'image
          print("📤 Upload en cours...");
          String? imageUrl = await CloudinaryService().uploadImage(_image!);

          if (imageUrl != null) {
            setState(() {
              _imageUrl = imageUrl;
            });
            print("✅ Image uploadée avec succès : $_imageUrl");
          } else {
            print("❌ Échec de l'upload.");
          }
        } else {
          print("⚠️ Aucune image sélectionnée.");
        }
      } else {
        print("❌ Permission refusée !");
      }
    } catch (e, stacktrace) {
      print("❌ ERREUR : $e");
      print(stacktrace);
    }
  }

  void _copyToClipboard() {
    if (_imageUrl != null) {
      Clipboard.setData(ClipboardData(text: _imageUrl!));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("📋 URL copiée dans le presse-papier !"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Image')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Column(
              children: [
                Image.file(_image!, height: 150),
                SizedBox(height: 10),
                Text("📄 Nom du fichier : $_imageName", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            )
                : Icon(Icons.photo_library, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickAndUploadImage,
              child: Text('Sélectionner une image'),
            ),
            if (_imageUrl != null) ...[
              Padding(
                padding: EdgeInsets.all(10),
                child: SelectableText("🔗 URL : $_imageUrl", style: TextStyle(color: Colors.blue)),
              ),
              ElevatedButton(
                onPressed: _copyToClipboard,
                child: Text('📋 Copier l’URL'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
