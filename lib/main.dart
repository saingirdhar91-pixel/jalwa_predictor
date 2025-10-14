import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const JalwaApp());
}

class JalwaApp extends StatelessWidget {
  const JalwaApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jalwa Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WebViewController _controller;
  String predicted = '---';
  double confidence = 0;
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    // start simulation timer
    Timer.periodic(const Duration(seconds: 60), (_) => _simulate());
  }

  Future<void> _loadHistory() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      history = p.getStringList('history') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList('history', history);
  }

  void _simulate() {
    final rand = Random();
    final colors = ['Red', 'Green', 'Violet'];
    final pick = colors[rand.nextInt(colors.length)];
    final conf = 60 + rand.nextInt(36);
    setState(() {
      predicted = pick;
      confidence = conf.toDouble();
      history.insert(0, pick);
      if (history.length > 10) history = history.sublist(0, 10);
    });
    _saveHistory();
  }

  void _openLive() {
    final url = Uri.parse('https://www.jalwagame.com/#/saasLottery/WinGo?gameCode=WinGo_60S&lottery=WinGo');
    _controller.loadRequest(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JP - Jalwa Predictor'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // WebView area
          Expanded(
            flex: 2,
            child: WebViewWidget(
              controller: _controller = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadRequest(Uri.parse('https://www.jalwagame.com/#/saasLottery/WinGo?gameCode=WinGo_60S&lottery=WinGo')),
            ),
          ),
          // Prediction ticker
          Container(
            padding: const EdgeInsets.all(12),
            color: const Color(0xFF0B0B0B),
            child: Column(
              children: [
                Text('Next prediction', style: GoogleFonts.poppins(color: Colors.grey)),
                const SizedBox(height: 6),
                Text(predicted, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: confidence/100),
                const SizedBox(height: 6),
                Text('Confidence: ${confidence.toStringAsFixed(1)}%', style: GoogleFonts.poppins(color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: history.map((h) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: h == 'Red' ? Colors.redAccent : (h == 'Green' ? Colors.greenAccent : Colors.purpleAccent),
                      shape: BoxShape.circle,
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(onPressed: _simulate, child: const Text('Simulate')),
                    ElevatedButton(onPressed: _openLive, child: const Text('Go Live')),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
