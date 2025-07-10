import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:mandm/data/local/cache_helper.dart';
import 'package:mandm/models/quiz_model.dart';
import 'package:mandm/pages/quiz_page.dart';

class QuizzesPage extends StatefulWidget {
  final int challengeId;
  final int challengeTimer;

  const QuizzesPage({Key? key, required this.challengeId, required this.challengeTimer}) : super(key: key);

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  List<Quiz> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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
      const SnackBar(content: Text("فشل في تحميل الأسئلة")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأسئلة'), backgroundColor: Color(0xff562f41)),
      backgroundColor: Color(0xfff29520),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizzes.isEmpty
          ? const Center(child: Text('لا توجد أسئلة'))
          : ListView.builder(
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          final answers = quiz.answers.split(',');

          return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuizPage(challengeId: widget.challengeId, challengeTimer: widget.challengeTimer),
              ),
            );
            print('تم الضغط على الكويز رقم ${quiz.id}');
          },
          child: Card(
            color: Color(0xffffe5bc),
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(quiz.question),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('النقاط: ${quiz.points}'),
                  const SizedBox(height: 8),
                  Text('الإجابات المتاحة: ${answers.join(' | ')}'),
                ],
              ),
            ),
          ),
          );

        },
      ),
    );
  }
}
