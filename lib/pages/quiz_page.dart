import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/local/cache_helper.dart';
import '../models/quiz_model.dart';

class QuizPage extends StatefulWidget {
  final int challengeId;
  final int challengeTimer; // الوقت بالثواني

  const QuizPage({
    Key? key,
    required this.challengeId,
    required this.challengeTimer,
  }) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Quiz> quizzes = [];
  int currentIndex = 0;
  int remainingTime = 0;
  Timer? timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.challengeTimer;
    fetchQuizzes();
  }

  Future<void> fetchQuizzes() async {
    final dio = Dio();
    try {
      final response = await dio.get(
        // "https://koshycoding.com/mandm/api/quizzes/${widget.challengeId}",
        "https://koshycoding.com/mandm/api/quizzes/2",
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('---qqqqq---> ${response.data['message']}');
        // final List<dynamic> data = response.data['messages'];
        setState(() {
          // quizzes = data.map((json) => Quiz.fromJson(json)).toList();
          quizzes = (response.data['message'] as List).map((e) => Quiz.fromJson(e)).toList();
          isLoading = false;
        });
        startTimer();
      } else {
        showError();
      }
    } catch (e) {
      showError();
    }
  }

  void showError() {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("فشل في تحميل الكويزات")),
    );
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingTime <= 0) {
        t.cancel();
        finishChallenge();
      } else {
        setState(() {
          remainingTime--;
        });
      }
    });
  }

  void finishChallenge() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("انتهى الوقت!")),
    );
    Navigator.pop(context); // ارجع للخلف أو روح لصفحة معينة حسب اللوجيك
  }

  void nextQuiz() {
    if (currentIndex < quizzes.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      finishChallenge();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (quizzes.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("لا توجد أسئلة")),
      );
    }

    final quiz = quizzes[currentIndex];
    final answers = quiz.answers.split(',');

    return Scaffold(
      appBar: AppBar(
        title: const Text("التحدي"),
          backgroundColor: Color(0xff562f41),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text("الوقت المتبقي: $remainingTime ثانية")),
          ),
        ],
      ),
      backgroundColor: Color(0xfff29520),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "السؤال ${currentIndex + 1} من ${quizzes.length}",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              quiz.question,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...answers.map(
                  (answer) => Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Color(0xffffe5bc),),
                  onPressed: nextQuiz,
                  child: Text(answer.trim()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
