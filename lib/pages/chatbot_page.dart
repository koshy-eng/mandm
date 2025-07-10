import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:mandm/providers/home_provider.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unicons/unicons.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  _ChatbotPageState createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final String _projectId = 'wheely-ce695'; // Replace with your Dialogflow project ID
  final String _sessionId = 'unique-session-id-${DateTime.now().millisecondsSinceEpoch}';
  bool _isTyping = false;
  String? _accessToken;
  late http.Client _httpClient;

  @override
  void initState() {
    super.initState();
    // Create a custom HttpClient that bypasses SSL verification (development only)
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    _httpClient = IOClient(httpClient);
    _initializeAccessToken();
  }

  Future<void> _initializeAccessToken() async {
    try {
      final jsonString = await DefaultAssetBundle.of(context).loadString('assets/dialog_flow_auth.json');
      final serviceAccount = ServiceAccountCredentials.fromJson(jsonString);
      final client = await clientViaServiceAccount(
        serviceAccount,
        ['https://www.googleapis.com/auth/cloud-platform'],
      );
      setState(() {
        _accessToken = client.credentials.accessToken.data;
      });
      client.close();
    } catch (e) {
      setState(() {
        _messages.add({'text': 'Error initializing access token: $e', 'isUserMessage': false});
      });
    }
  }

  Future<Map<String, dynamic>> _queryDialogflow(String query) async {
    if (_accessToken == null) {
      throw Exception('Access token not initialized');
    }
    final url = 'https://dialogflow.googleapis.com/v2/projects/$_projectId/agent/sessions/$_sessionId:detectIntent';
    final response = await _httpClient.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'queryInput': {
          'text': {'text': query, 'languageCode': 'en'},
        },
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to connect to Dialogflow: ${response.statusCode}');
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'text': message, 'isUserMessage': true});
      _isTyping = true;
    });
    _controller.clear();

    try {
      final response = await _queryDialogflow(message);
      final botMessage = response['queryResult']['fulfillmentText'] ?? 'Sorry, I didn\'t understand.';
      final intent = response['queryResult']['intent']['displayName'];

      setState(() {
        _isTyping = false;
        _messages.add({'text': botMessage, 'isUserMessage': false});
      });

      // Handle app-specific actions
      switch (intent) {
        case 'book_ride':
          Navigator.pushNamed(context, '/booking');
          break;
        case 'privacy_policy':
          Navigator.pushNamed(context, '/privacy');
          break;
        case 'logout':
        case 'find_nearest_car':
        case 'find_suitable_ride':
        // Response handled by Dialogflow
          break;
        default:
          break;
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({'text': 'Error: $e', 'isUserMessage': false});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    var w = MediaQuery.of(context).size.width;
    ThemeData themeData = Theme.of(context);
    return ChangeNotifierProvider(
      create: (_) => HomeProvider()..loadHomeData(),
      child: Scaffold(
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
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10),
                      ),
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
        backgroundColor: themeData.scaffoldBackgroundColor,
        body: Consumer<HomeProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage.isNotEmpty) {
              return Center(child: Text(provider.errorMessage));
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue[50]!, Colors.grey[100]!],
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12.0),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isTyping && index == _messages.length) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: const SpinKitThreeBounce(
                                color: Colors.blueAccent,
                                size: 20.0,
                              ),
                            ),
                          );
                        }
                        final isUserMessage = _messages[index]['isUserMessage'];
                        return Container(
                          margin: const EdgeInsets.all(10.0),
                          child: Row(
                            mainAxisAlignment:
                            isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: const Radius.circular(20.0),
                                    topRight: const Radius.circular(20.0),
                                    bottomRight:
                                    Radius.circular(isUserMessage ? 0 : 20.0),
                                    topLeft: Radius.circular(isUserMessage ? 20.0 : 0),
                                  ),
                                  color: isUserMessage ? Colors.blueAccent : Colors.grey[200],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                constraints: BoxConstraints(maxWidth: w * 2 / 3),
                                child: Text(
                                  _messages[index]['text'],
                                  style: TextStyle(
                                    color: isUserMessage ? Colors.white : Colors.black87,
                                    fontSize: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Padding(padding: EdgeInsets.only(top: 10.0)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Ask about rides, logout, or more...',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                            ),
                            onSubmitted: _sendMessage,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () => _sendMessage(_controller.text),
                          ),
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

  @override
  void dispose() {
    _controller.dispose();
    _httpClient.close();
    super.dispose();
  }
}

class PopularPlace {
  final String name;
  final String imageUrl;

  PopularPlace({required this.name, required this.imageUrl});
}