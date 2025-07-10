import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mandm/data/local/cache_helper.dart';
import 'package:mandm/data/local/dbTablesHelpers/ChallengeDb.dart';
import 'package:mandm/pages/quizzes_page.dart';
import 'dart:convert';

import '../models/challenge_model.dart';

class ChallengesPage extends StatefulWidget {
  final int activityId;

  const ChallengesPage({Key? key, required this.activityId}) : super(key: key);

  @override
  State<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends State<ChallengesPage> with WidgetsBindingObserver {
  List<Challenge> challenges = [];
  bool isLoading = true;
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    fetchChallenges();
    getUserLocation();
  }


  /*Future<void> fetchChallenges() async {
    final dio = Dio();
    final token = "Bearer ${CacheHelper.getData(key: 'token')}"; // ضع التوكن الصحيح هنا
    final url = "https://koshycoding.com/mandm/api/activities/${widget.activityId}/challenges";

    setState(() {
      isLoading = true;
    });

    try {
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': token,
            // 'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // final List<dynamic> data = response.data['message'];
        print('---vvvvv---> ${response.data['message']}');
        setState(() {
          // challenges = data.map((json) => Challenge.fromJson(json)).toList();
          // challenges = data.map((json) => Challenge.fromJson(json)).toList();
          challenges = (response.data['message'] as List).map((e) => Challenge.fromJson(e)).toList();
          // print("vvvvvvvvv ${challenges.length.toString()}");
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل في تحميل التحديات")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء الاتصال بالخادم")),
      );
      print(e);
    }
  }*/
  Future<void> fetchChallenges() async {
    setState(() {
      isLoading = true;
    });

    final db = ChallengeDbHelper();
    final localData = await db.getChallengesByActivity(widget.activityId);

    if (localData.isNotEmpty) {
      print("Loading from local DB...");
      setState(() {
        challenges = localData;
        isLoading = false;
      });
      return;
    }

    // If no local data, fetch from API
    final dio = Dio();
    final token = "Bearer ${CacheHelper.getData(key: 'token')}";
    final url = "https://koshycoding.com/mandm/api/activities/${widget.activityId}/challenges";

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['message'];
        final List<Challenge> fetched = data.map((e) => Challenge.fromJson(e)).toList();

        // Save to DB
        for (int i = 0; i < fetched.length; i++) {
          Challenge c = fetched[i];
          await db.insertChallenge(c.copyWith(
            isUnlocked: i == 0 ? 1 : 0, // unlock only the first
          ));
        }

        final saved = await db.getChallengesByActivity(widget.activityId);
        setState(() {
          challenges = saved;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load from API');
      }
    } catch (e) {
      print("Error fetching challenges: $e");
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء الاتصال بالخادم")),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("التحديات"), backgroundColor: Color(0xff562f41)),
      backgroundColor: Color(0xfff29520),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userPosition == null
          ? const Center(child: Text("جارٍ تحديد موقعك..."))
          : challenges.isEmpty
          ? const Center(child: Text("لا توجد تحديات متاحة"))
          : ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          final distance = calculateDistance(challenge.lat, challenge.lng);

          return Card(
            color: challenge.isCompleted == 1
                ? Colors.green.shade100
                : challenge.isUnlocked == 1
                ? Colors.orange.shade100
                : Colors.grey.shade300,
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (challenge.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      "https://koshycoding.com/mandm/storage/app/public/${challenge.image!}",
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          challenge.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (challenge.isCompleted == 1)
                        Icon(Icons.check_circle, color: Colors.green)
                      else if (challenge.isUnlocked == 1)
                        Icon(Icons.lock_open, color: Colors.orange)
                      else
                        Icon(Icons.lock, color: Colors.grey),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("المسافة: ${distance.toStringAsFixed(2)} متر"),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: LinearProgressIndicator(
                    value: (challenge.timeSpent / challenge.timer).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrange),
                  ),
                ),
                const SizedBox(height: 8),
                if (challenge.isUnlocked == 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "أكمل التحدي السابق لفتح هذا",
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Chip(
                        label: Text("النقاط: ${challenge.userPoints}"),
                        backgroundColor: Colors.blue.shade100,
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text("الوقت: ${challenge.timer}s"),
                        backgroundColor: Colors.orange.shade100,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.play_arrow),
                    label: Text("ابدأ التحدي"),
                    onPressed: challenge.isUnlocked == 1 && distance <= challenge.radius
                        ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizzesPage(
                            challengeId: challenge.id,
                            challengeTimer: challenge.timer,
                          ),
                        ),
                      );
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: challenge.isUnlocked == 1 ? Color(0xff562f41) : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }


  Future<void> getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition();
    print('locc: $position');
    setState(() {
      userPosition = position;
    });
  }

  double calculateDistance(double lat, double lng) {
    if (userPosition == null) return double.infinity;
    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      lat,
      lng,
    );
  }

  Future<void> completeChallenge(Challenge current, int timeSpent, int points) async {
    final updated = current.copyWith(
      isCompleted: 1,
      timeSpent: timeSpent,
      userPoints: points,
    );
    await ChallengeDbHelper().updateChallenge(updated);
    await ChallengeDbHelper().unlockNextChallenge(current.order ?? 0, current.activityId);

    // Update the list in memory too (optional)
    int index = challenges.indexWhere((c) => c.id == current.id);
    if (index != -1) {
      challenges[index] = updated;
      setState(() {});
    }
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      saveProgressToDb();
    }
  }

  Future<void> saveProgressToDb() async {
    for (var challenge in challenges) {
      await ChallengeDbHelper().updateChallenge(challenge);
    }
  }
}
