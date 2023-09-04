import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'model/ChatModel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Hipe Chat Demo'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  bool showEmail = true;
  List<ChatModel> chatList = [];
  final dio = Dio();
  Socket socket = io('http://192.168.1.233:3002', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });

  @override
  void initState() {
    super.initState();
    getPersistMessage();
    initSocket();
  }

  void getPersistMessage() async {
    Response response = await dio.get('http://192.168.1.233:3002/api/chat');
    response.data.forEach((element) {
      chatList.add(ChatModel.fromJson(element));
    });
  }

  void initSocket() {
    print('socket init');

    socket.connect();

    socket.on('recMessage', (data) {
      print("Listen");

      setState(() {
        chatList.add(ChatModel.fromJson(data));
      });
    });
    socket.onDisconnect((_) => print('socket disconnect'));
  }

  void sendMessage() {
    String messageText = messageController.text.trim();
    messageController.text = '';
    print({"email": emailController.text, "text": messageText});
    socket.emit(
        'sendMessage', {"email": "android@mail.com", "text": messageText});
  }

  @override
  void dispose() {
    emailController.dispose();
    messageController.dispose();
    socket.disconnect();
    super.dispose();
  }

  void onEmailAdd() {
    setState(() {
      showEmail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child:

              // showEmail
              //     ? Center(
              //         child: Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: <Widget>[
              //             TextField(
              //               controller: emailController,
              //               decoration:
              //                   const InputDecoration(hintText: "Enter your Email"),
              //             ),
              //             Padding(
              //               padding: const EdgeInsets.only(top: 8.0),
              //               child: ElevatedButton(
              //                   onPressed: onEmailAdd, child: const Text("Submit")),
              //             )
              //           ],
              //         ),
              //       )
              //     :

              Column(
            children: [
              Expanded(
                  child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: chatList.length,
                      itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "${chatList[index].email} : ${chatList[index].text}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ))),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      decoration:
                          const InputDecoration(hintText: "Type Message . . ."),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                        onPressed: sendMessage, child: const Text("Send")),
                  )
                ],
              )
            ],
          )),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
