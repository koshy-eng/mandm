import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String? paymentKey;
  final String? iframeId;

  const PaymentWebViewPage({required this.paymentKey, required this.iframeId, Key? key}) : super(key: key);

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;

  String get paymentUrl =>
      "https://accept.paymob.com/api/acceptance/iframes/${widget.iframeId}?payment_token=${widget.paymentKey}";

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ConsoleLog',
        onMessageReceived: (JavaScriptMessage message) {
          print('🟡 رسالة من الصفحة: ${message.message}');
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('✅ بدأ تحميل: $url');
          },
          onPageFinished: (url) {
            print('✅ انتهى تحميل: $url');

            // تفعيل console.log داخل الصفحة لو ممكن
            _controller.runJavaScript("""
              (function() {
                const oldLog = console.log;
                console.log = function(message) {
                  ConsoleLog.postMessage(message);
                  oldLog(message);
                }
              })();
            """);
          },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('myapp://payment_success')) {
                Uri uri = Uri.parse(request.url);
                String success = uri.queryParameters['success'] ?? 'false';
                String orderId = uri.queryParameters['order'] ?? '';
                String amount = uri.queryParameters['amount_cents'] ?? '';

                if (success == 'true') {
                  Navigator.pop(context, {'status': 'success', 'orderId': orderId, 'amount': amount});
                } else {
                  Navigator.pop(context, {'status': 'failed', 'orderId': orderId});
                }

                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            }

          /*onNavigationRequest: (NavigationRequest request) {
            print('➡️ محاولة الذهاب إلى: ${request.url}');
            if (request.url.startsWith('myapp://payment_success')) {
              print('🎉 اكتملت عملية الدفع، العودة للتطبيق');
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }
            print('🎉 اكتملت عملية الدفع، العودة للتطبيق');
            return NavigationDecision.navigate;
          },*/
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إتمام الدفع')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
