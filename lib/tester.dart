import 'package:flutter/material.dart';
import 'package:input_history_text_field/input_history_text_field.dart';

class TextHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Input History Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const InputHistoryScreen(),
    );
  }
}

class InputHistoryScreen extends StatefulWidget {
  const InputHistoryScreen({super.key});

  @override
  State<InputHistoryScreen> createState() => _InputHistoryScreenState();
}

class _InputHistoryScreenState extends State<InputHistoryScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input History TextField'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Basic usage
            InputHistoryTextField(
              historyKey: "search_history", // Unique key for storing history
              // controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Enter text (basic)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Customized example with a badge style and locked items
            InputHistoryTextField(
              historyKey: "tags_history", // Another unique key
              listStyle: ListStyle.Badge, // Display history as badges
              lockItems: const ['Flutter', 'Dart', 'Widgets'], // Fixed items
              showHistoryIcon: false, // Hide the history icon
              backgroundColor: Colors.deepPurple,
              textColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Enter tags (customized)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
