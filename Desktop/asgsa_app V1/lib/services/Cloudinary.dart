import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  final String cloudName = 'dsveonbhj'; // Remplace avec ton Cloud Name
  final String apiKey = '597896353741765'; // Remplace avec ta clé API
  final String apiSecret = '<i0fOPK49y197cQUi3CoWM_ayawY>'; // Remplace avec ton secret API

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'ml_default' // Si tu utilises un preset
      ..fields['api_key'] = apiKey
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse['secure_url']; // URL de l'image uploadée
    } else {
      print('Échec de l’upload : ${response.statusCode}');
      return null;
    }
  }
}
