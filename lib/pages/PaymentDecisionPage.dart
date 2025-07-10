import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mandm/pages/challenges_page.dart';
import 'package:mandm/pages/home_page.dart';
import 'package:path/path.dart' as dateString;
import 'package:unicons/unicons.dart';

import '../data/local/cache_helper.dart';
import '../models/activity_model.dart';
import 'PaymentWebViewPage.dart';

class PaymentDecisionPage extends StatefulWidget {
  final Activity? activity;
  final double amount;

  const PaymentDecisionPage({
    Key? key,
    required this.activity,
    required this.amount,
  }) : super(key: key);

  @override
  _PaymentDecisionPageState createState() => _PaymentDecisionPageState();
}

class _PaymentDecisionPageState extends State<PaymentDecisionPage> {
  bool isLoading = false;
  bool isPaid = false;
  int bookingId = 0;
  late Activity activity;
  late DateTime activityStartTime; // لازم الوقت يكون بصيغة DateTime
  late Duration remainingTime;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    activity = widget.activity!;
    String dateString = activity.date;
    String timeString = activity.time;

// استخراج التاريخ فقط
    String onlyDate = dateString.split(" ")[0];

// تركيب التاريخ والوقت بشكل صحيح
    String fullDateTime = "$onlyDate $timeString:00";

// التحويل إلى DateTime
    DateTime activityDateTime = DateTime.parse(fullDateTime);

    activityStartTime = activityDateTime;
    remainingTime = activityStartTime.difference(DateTime.now());
    checkOrCreateBooking();
  }

  Future<void> checkOrCreateBooking() async {
    setState(() {
      isLoading = true;
    });

    final dio = Dio();
    final token = CacheHelper.getData(key: 'token');

    try {
      final response = await dio.post(
        'https://koshycoding.com/mandm/api/bookings/check-status',
        data: {'activity_id': widget.activity?.id},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['status'] == 'not_booked') {
        bookingId = 0;
        // await createBooking();
      } else {
        bookingId = response.data['booking_id'];

        if (response.data['status'] == 'paid') {
          setState(() {
            isPaid = true;
          });
        }
        if(bookingId != 0 && isPaid){
//           String dateString = "2025-06-22 00:00:00";
//           String timeString = "22:00";
//
// // استخراج التاريخ فقط
//           String onlyDate = dateString.split(" ")[0];
//
// // تركيب التاريخ والوقت بشكل صحيح
//           String fullDateTime = "$onlyDate $timeString:00";
//
// // التحويل إلى DateTime
//           DateTime activityDateTime = DateTime.parse(fullDateTime);

          // print(activityDateTime);

          startCountdown();
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 /* Future<void> createBooking() async {
    final dio = Dio();
    final token = CacheHelper.getData(key: 'token');

    final response = await dio.post(
      'https://koshycoding.com/mandm/api/bookings/create',
      data: {
        'activity_id': widget.activity?.id,
        'amount': widget.amount,
      },
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    bookingId = response.data['booking_id'].toString();
  }*/

  Future<void> startPayment() async {
    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في الحجز')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final dio = Dio();
      final token = CacheHelper.getData(key: 'token');

      final response = await dio.post(
        'https://your-backend.com/api/paymob/initiate-booking-payment',
        data: {
          'booking_id': bookingId,
          'amount': widget.amount,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewPage(
            paymentKey: response.data['payment_key'],
            iframeId: response.data['iframe_id'],
            // bookingId: bookingId!,
          ),
        ),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل بدء عملية الدفع')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    ThemeData themeData = Theme.of(context);
    final imageUrl = activity.image != null
        ? activity.image!.startsWith('http')
        ? activity.image!
        : 'https://koshycoding.com/mandm/storage/app/public/${activity.image}'
        : 'https://via.placeholder.com/300x200?text=No+Image';
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0), //appbar size
        child: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          // backgroundColor: themeData.scaffoldBackgroundColor,
          backgroundColor: Color(0xff562f41),
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
            'assets/icons/mandm_logo.png', //logo
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

      backgroundColor: Color(0xfff29520),
      body:  Container(
        clipBehavior: Clip.none,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main-bg.png'),
            // Your background image path
            fit:
            BoxFit
                .cover, // Or BoxFit.fill / BoxFit.fitHeight etc.
          ),
        ),
        child: Column(
        children: [
          // صورة النشاط
          Image.network(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    activity.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.date_range, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('${activity.date} - ${activity.time}'),
                    ],
                  ),

                  SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.people, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('المقاعد المتاحة: ${activity.seats}'),
                    ],
                  ),

                  SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.monetization_on, size: 20, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('السعر: ${activity.price ?? 0} جنيه'),
                    ],
                  ),

                  // if (bookingId == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        bookingId == 0 ? 'لم يتم الحجز بعد'
                            :isPaid ? 'برجاء إنتظار حتى يبدأ التفاعل' : 'لم يتم دفع الرسوم بعد' ,
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                    ),
                  Text(
                    remainingTime.isNegative
                        ? 'النشاط بدأ'
                        : '${remainingTime.inHours.toString().padLeft(2, '0')}:${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'booking_id${bookingId} : ispaid ${isPaid}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                    ),

                  if (activity.advice != null && activity.advice!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'نصيحة: ${activity.advice}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: remainingTime.isNegative /*&& DateTime.now().isBefore(activityStartTime.add(Duration(hours: 3)))*/
                        ? () {
                      goToChallengesPage();
                    }
                        : null,
                    child: Text('ابدأ النشاط'),
                  )


                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {

                  applyForActivity(activity);

              },
              child: Text(
                  bookingId == 0 ? 'الحجز والدفع'
                      :isPaid ? 'برجاء إنتظار حتى يبدأ التفاعل' : 'الدفع' ,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
  Widget buildContent() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (isPaid) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 16),
            Text('تم الدفع بنجاح، انتظر وقت النشاط لبدء اللعبة.'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ترجع للصفحة الرئيسية أو أي صفحة
              },
              child: Text('رجوع'),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('قيمة الحجز: ${widget.amount} جنيه'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: startPayment,
            child: Text('ادفع الآن'),
          ),
        ],
      ),
    );
  }

  Future<void> applyForActivity(Activity? activity) async {
    if(activity != null) {
      try {

        if(bookingId == 0) {
          bookingId = await createBooking(activity.id, activity.price);
        }
        final paymentData = await initiatePayment(bookingId, activity.price);

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentWebViewPage(
              paymentKey: paymentData['paymentKey'],
              iframeId: paymentData['iframeId'],
            ),
          ),
        );

        if (result != null && result['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الدفع بنجاح')),
          );
          checkOrCreateBooking();
          // ممكن تنتقل لصفحة شكر أو تحدث الشاشة
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم تكتمل عملية الدفع')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }
  Future<int> createBooking(int activityId, double? price) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        'https://koshycoding.com/mandm/api/bookings/create',
        data: {
          'activity_id': activityId,
          'amount': price,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
            // 'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['booking_id'];
      } else {
        throw Exception('فشل في إنشاء الحجز: ${response.data['message']}');
      }
    } catch (e) {
      throw Exception('خطأ في الحجز: $e');
    }
  }

  Future<Map<String, String>> initiatePayment(int bookingId, double? amount) async {
    final dio = Dio();

    try {
      final response = await dio.post(
        'https://koshycoding.com/mandm/api/paymob/initiate-booking-payment',
        data: {
          'booking_id': bookingId,
          'amount': amount,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${CacheHelper.getData(key: 'token')}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'paymentKey': response.data['payment_key'],
          'iframeId': response.data['iframe_id'].toString(),
        };
      } else {
        throw Exception('فشل في بدء عملية الدفع');
      }
    } catch (e) {
      throw Exception('خطأ في بدء الدفع: $e');
    }
  }
  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = activityStartTime.difference(DateTime.now());

        // لو الوقت عدى وداخل فترة السماح
        if (remainingTime.isNegative && DateTime.now().isBefore(activityStartTime.add(Duration(hours: 3)))) {
          countdownTimer?.cancel();
          goToChallengesPage();
        }

        // لو الوقت عدى اكتر من 3 ساعات
        if (DateTime.now().isAfter(activityStartTime.add(Duration(hours: 3)))) {
          countdownTimer?.cancel();
          // الوقت انتهى، ممكن تظهر رسالة انتهاء الصلاحية
        }
      });
    });
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void goToChallengesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengesPage(activityId: activity.id,),
      ),
    );
  }

}
