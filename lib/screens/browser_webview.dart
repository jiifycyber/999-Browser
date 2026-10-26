import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BrowserWebView extends StatefulWidget {
  final String url;
  const BrowserWebView({super.key, required this.url});

  @override
  State<BrowserWebView> createState() => _BrowserWebViewState();
}

class _BrowserWebViewState extends State<BrowserWebView> {
  late final WebViewController controller;
  final address = TextEditingController();
  bool loading = true;

  @override
  void initState() {
    super.initState();
    address.text = widget.url;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          if (mounted) setState(() { loading = true; address.text = url; });
        },
        onPageFinished: (url) {
          if (mounted) setState(() { loading = false; address.text = url; });
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  void visit() {
    final value = address.text.trim();
    if (value.isEmpty) return;
    final uri = Uri.tryParse(value.startsWith('http') ? value : 'https://\$value');
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty) {
      controller.loadRequest(uri);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: TextField(
        controller: address,
        keyboardType: TextInputType.url,
        textInputAction: TextInputAction.go,
        onSubmitted: (_) => visit(),
        decoration: const InputDecoration(border: InputBorder.none, hintText: 'Website address'),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.arrow_back), onPressed: () async { if (await controller.canGoBack()) controller.goBack(); }),
        IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () async { if (await controller.canGoForward()) controller.goForward(); }),
        IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.reload()),
      ],
    ),
    body: Column(children: [
      if (loading) const LinearProgressIndicator(),
      Expanded(child: WebViewWidget(controller: controller)),
    ]),
  );
}
