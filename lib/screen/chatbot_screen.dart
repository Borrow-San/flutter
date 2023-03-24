import 'package:bs_flutter/const/constant.dart';
import 'package:bs_flutter/widget/logout_button.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ChatbotScreen extends StatefulWidget {
  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  final List<bool> _isUser = [];

  void _sendMessage(String message) async {
    setState(
          () {
        _messages.insert(0, message);
        _isUser.insert(0, true);
      },
    );
    _controller.clear();
    final response = await sendMessageToChatbot(message);
    if (response.statusCode == 200) {
      final jsonString = utf8.decode(response.bodyBytes);
      final responseBody = jsonDecode(jsonString);
      final chatbotMessage = responseBody['response'];
      setState(
            () {
          _messages.insert(0, chatbotMessage);
          _isUser.insert(0, false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot Screen'),
        actions: [
          logoutButton(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = _isUser[index];
                  if (isUser) {
                    return ListTile(
                      title: Text(
                        message,
                        textAlign: TextAlign.end,
                      ),
                      trailing: Icon(Icons.person),
                    );
                  } else {
                    return ListTile(
                      title: Text(
                        message,
                        textAlign: TextAlign.start,
                      ),
                      leading: Icon(Icons.computer),
                    );
                  }
                },
              ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Send a message',
                filled: true,
                fillColor: Colors.grey.shade200,
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Future<http.Response> sendMessageToChatbot(String message) async {
  final response = await http.post(
    Uri.parse('$API_DOMAIN/chatbot/gpt3'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'message': message,
    }),
  );
  return response;
}
