import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:unicons/unicons.dart';
import 'package:mandm/data/remote/url_api.dart';
import 'package:mandm/models/message_model.dart';
import 'package:mandm/widgets/bottom_nav_bar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/local/cache_helper.dart';
import '../models/ride_model.dart';
import '../providers/home_provider.dart';

class ChatUtoUPage extends StatefulWidget {
  final Ride mRide;

  const ChatUtoUPage({required this.mRide, Key? key}) : super(key: key);

  @override
  _ChatUtoUPageState createState() => _ChatUtoUPageState();
}

class _ChatUtoUPageState extends State<ChatUtoUPage> {
  late Ride ride;
  late HomeProvider mProvider;
  final List<MessageModel> _messages = [];
  final TextEditingController _controller = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    ride = widget.mRide;
  }

  void startPollingMessages() {

    print('Xaaaaaaaaaa receiver_id: ${ride.userId}');
    print('Xaaaaaaaaaa ride_id: ${ride.id}');
    print('Xaaaaaaaaaa message: ${_messages.last.id}');
    _timer = Timer.periodic(Duration(seconds: 10), (_) async {
      final response = await Dio().get(
        '$getLastChatMessages/${ride.id}/${ride.userId}/${_messages.last.id}',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        if (response.data != null) {
          MessageModel messageModel = MessageModel.fromJson(response.data['message']);
          if(messageModel.id > _messages.last.id) {
            _messages.add(messageModel);
          }

          // showToastApp(text: 'Error: Try again later.', color: Colors.green);
        }

        // showToastApp(
        //   text: 'Error: Try again later.',
        //   color: Colors.greenAccent,
        // );
      } else {
        // showToastApp(text: 'Error: Try again later.', color: Colors.red);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        print('aaaaaaaaaa receiver_id: ${ride.userId}');
        print('aaaaaaaaaa ride_id: ${ride.id}');
        print('aaaaaaaaaa message: ${text}');
        // return;
        var data = json.encode({
          'receiver_id': ride.userId,
          'ride_id': ride.id,
          'message': text,
        });

        var response = await Dio().post(
          sendChatMessage,
          data: data,
          options: Options(
            headers: {
              'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
            },
          ),
        );
        if (response.statusCode == 200) {
          // debugPrint('FormData as String:\n${response.toString()}');

          print('aaaaaaabbbbbb receiver_id: ${response.data['message']['id']}');

          MessageModel userModel = MessageModel.fromJson(response.data['message']);

          setState(() {
            _messages.add(userModel);
          });
          _controller.clear();

          // showToastApp(text: 'account created successfully', color: Colors.green);
        } else {
          // showToastApp(text: 'Error: Try again later.', color: Colors.red);
        }
      } catch (e) {
        if (e is DioException && e.error is SocketException) {
          print('errrrrrr DioException: ${e}');
          // showToastApp(text: 'No Internet connection.${e}', color: Colors.red);
        } else {
          print('errrrrrr: ${e}');
          // showToastApp(
          //   text: 'Error: Try again later please.${e}',
          //   color: Colors.red,
          // );
        }
      }
      // // Simulate driver response (optional)
      // Future.delayed(Duration(seconds: 1), () {
      //   setState(() {
      //     _messages.add({"text": "Noted 👍", "isUser": false});
      //   });
      // });
    }
  }

  Widget _buildMessage(MessageModel message) {
    final isUser = message.senderId == CacheHelper.getData(key: 'id');
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.message,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadMessagesInitData(ride.id, ride.userId),
      child: Scaffold(
        // appBar: AppBar(title: Text("Register Your Car")),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0), //appbar size
          child: AppBar(
            bottomOpacity: 0.0,
            elevation: 0.0,
            shadowColor: Colors.transparent,
            backgroundColor: themeData.scaffoldBackgroundColor,
            leading: Padding(
              padding: EdgeInsets.only(left: size.width * 0.05),
              child: SizedBox(
                height: size.width * 0.1,
                width: size.width * 0.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: themeData.scaffoldBackgroundColor.withAlpha(
                      (0.03 * 255).toInt(),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Icon(
                    UniconsLine.bars,
                    color: themeData.secondaryHeaderColor,
                    size: size.height * 0.025,
                  ),
                ),
              ),
            ),
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            leadingWidth: size.width * 0.15,
            title: Image.asset(
              'assets/icons/wheely_colored.png', //logo
              height: size.height * 0.06,
              width: size.width * 0.35,
            ),
            centerTitle: true,
            actions: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: size.width * 0.05),
                child: SizedBox(
                  height: size.width * 0.1,
                  width: size.width * 0.1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeData.scaffoldBackgroundColor.withAlpha(
                        (0.03 * 255).toInt(),
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Icon(
                      UniconsLine.search,
                      color: themeData.secondaryHeaderColor,
                      size: size.height * 0.025,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        extendBody: true,
        extendBodyBehindAppBar: true,
        bottomNavigationBar: buildBottomNavBar(2, size, themeData),
        // backgroundColor: themeData.scaffoldBackgroundColor,
        body: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            mProvider = provider;
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // return Center(child: Text(provider.driver!.message.name));

            if (provider.errorMessage.isNotEmpty) {


              return Center(child: Text(provider.errorMessage));
            }

            if(_messages.isEmpty) {
              _messages.addAll(provider.messages!.message);
            }

            startPollingMessages();
            return SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      itemCount: _messages.length,
                      itemBuilder: (_, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
                  ),
                  Divider(height: 1),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Type your message...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
