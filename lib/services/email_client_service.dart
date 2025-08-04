import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'user_data.dart';
import '../config/environment.dart';

class EmailClientService {
  static String get _baseUrl => Environment.apiBaseUrl;

  static Future<bool> sendPdfEmail({
    required UserData userData,
    required Uint8List pdfBytes,
    required String emailType, // 'pdf', 'quote', 'comparison'
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/send-pdf-email');
      
      final requestBody = {
        'userData': {
          'firstName': userData.firstName,
          'lastName': userData.lastName,
          'email': userData.email,
          'address': userData.address,
          'city': userData.city,
          'country': userData.country,
          'company': userData.company,
          'phone': userData.phone,
          'projectName': userData.projectName,
          'assembly': userData.assembly,
          'application': userData.application,
        },
        'pdfBytes': base64Encode(pdfBytes),
        'emailType': emailType,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['success'] == true;
      } else {
        print('Email service error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  static Future<bool> sendQuoteEmail({
    required UserData userData,
    required Uint8List pdfBytes,
  }) async {
    return sendPdfEmail(
      userData: userData,
      pdfBytes: pdfBytes,
      emailType: 'quote',
    );
  }

  static Future<bool> sendComparisonEmail({
    required UserData userData,
    required Uint8List pdfBytes,
  }) async {
    return sendPdfEmail(
      userData: userData,
      pdfBytes: pdfBytes,
      emailType: 'comparison',
    );
  }
} 