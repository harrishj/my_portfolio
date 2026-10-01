import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailSendResult {
  final bool success;
  final String message;

  const EmailSendResult({required this.success, required this.message});
}

class EmailContactService {
  final SupabaseClient? _client;

  EmailContactService([this._client]);

  SupabaseClient get _supabase {
    if (_client != null) return _client;
    return Supabase.instance.client;
  }

  /// Sends the message directly to the recipient's email address via FormSubmit AJAX service
  Future<EmailSendResult> sendMessage({
    required String recipientEmail,
    required String senderName,
    required String senderEmail,
    required String messageContent,
    String? subject,
  }) async {
    final cleanRecipient = recipientEmail.trim().isNotEmpty
        ? recipientEmail.trim()
        : 'harrishcsbs@gmail.com';

    final emailSubject = (subject != null && subject.trim().isNotEmpty)
        ? subject.trim()
        : 'Portfolio Inquiry from $senderName';

    // 1. Try sending via FormSubmit API
    try {
      final response = await http.post(
        Uri.parse('https://formsubmit.co/ajax/$cleanRecipient'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': senderName.trim(),
          'email': senderEmail.trim(),
          '_replyto': senderEmail.trim(),
          '_subject': emailSubject,
          'message': messageContent.trim(),
          '_template': 'table',
        }),
      ).timeout(const Duration(seconds: 12));

      // Asynchronously attempt to log to Supabase in the background
      _logMessageToSupabase(
        recipientEmail: cleanRecipient,
        senderName: senderName,
        senderEmail: senderEmail,
        message: messageContent,
      ).ignore();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const EmailSendResult(
          success: true,
          message: 'Message delivered directly to inbox! Thank you for reaching out.',
        );
      } else {
        final body = response.body;
        return EmailSendResult(
          success: false,
          message: 'Delivery service responded with status ${response.statusCode}: $body',
        );
      }
    } catch (e) {
      return EmailSendResult(
        success: false,
        message: 'Could not connect to email server: ${e.toString().split(']').last.trim()}',
      );
    }
  }

  Future<void> _logMessageToSupabase({
    required String recipientEmail,
    required String senderName,
    required String senderEmail,
    required String message,
  }) async {
    try {
      await _supabase.from('contact_messages').insert({
        'recipient': recipientEmail,
        'sender_name': senderName,
        'sender_email': senderEmail,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
      // Table may not exist or require auth; non-critical
    }
  }
}
