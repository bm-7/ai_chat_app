import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final Gemini gemini = Gemini.instance;

ChatUser user = ChatUser(id: "0", firstName: "MyChat");
ChatUser geminiuser = ChatUser(
    id: "1",
    firstName: "GEMINI",
    profileImage:
    "https://imgs.search.brave.com/ckSOROE1T4dKp2JH1h0VP6rGF_f2pjC7Pu-OphB-uVE/rs:fit:500:0:0/g:ce/aHR0cHM6Ly9sb2dv/d2lrLmNvbS9jb250/ZW50L3VwbG9hZHMv/aW1hZ2VzL2dvb2ds/ZS1haS1nZW1pbmk5/MTIxNi5sb2dvd2lr/LmNvbS53ZWJw");
List<ChatMessage> messages = [];

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Changed background color
      appBar: AppBar(
        backgroundColor: Colors.green, // Changed app bar color
        title: Text("Gemini Chat"),
        centerTitle: true,
      ),
      body: BuildUI(),
    );
  }

  Widget BuildUI() {
    return DashChat(
      inputOptions: InputOptions(
        trailing: [
          IconButton(onPressed: imagePicker, icon: Icon(Icons.image))
        ],
      ),
      currentUser: user,
      onSend: _sendmessage,
      messages: messages, // Pass the messages list here
    );
  }

  void _sendmessage(ChatMessage chatmsg) {
    setState(() {
      messages = [chatmsg, ...messages];
    });
    try {
      String question = chatmsg.text;
      gemini.streamGenerateContent(question).listen((event) {
        // Process Gemini response
        String response = event.content?.parts?.fold<String>("", (previousValue, current) => '$previousValue${current.text}' ?? "") ?? "";

        // Create a new ChatMessage with the Gemini response
        ChatMessage message = ChatMessage(
          user: geminiuser,
          createdAt: DateTime.now(),
          text: response,
        );

        // Update the state with the new message
        setState(() {
          messages = [message, ...messages];
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> imagePicker() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(
        source: ImageSource.gallery); // Corrected method name
    if (file != null) {
      ChatMessage message = ChatMessage(
          user: user,
          text: 'Describes this picture?',
          createdAt: DateTime.now(),
          medias: [
            ChatMedia(
                url: file.path, fileName: '', type: MediaType.image)
          ]);
      _sendmessage(message);
    }
  }
}
