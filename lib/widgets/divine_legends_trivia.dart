import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DivineLegendsTrivia extends StatefulWidget {
  const DivineLegendsTrivia({super.key});
  @override
  State<DivineLegendsTrivia> createState() => _DivineLegendsTriviaState();
}

class _DivineLegendsTriviaState extends State<DivineLegendsTrivia> {
  List<dynamic> questions = [];
  List<int> order = [];
  List<int> choices = [];
  int position = 0;
  int selected = -1;
  int score = 0;
  String? error;
  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final raw = await rootBundle.loadString(
        'assets/trivia/divine_legends_questions_1000.json',
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final loaded = decoded['questions'] as List<dynamic>;
      if (loaded.length != 1000) {
        throw StateError('Expected 1000 questions, found ${loaded.length}');
      }
      if (!mounted) return;
      setState(() {
        questions = loaded;
        order = List.generate(questions.length, (i) => i)..shuffle();
        position = 0;
        score = 0;
        selected = -1;
        choices = [0, 1, 2, 3]..shuffle();
      });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  void nextQuestion() {
    setState(() {
      if (position + 1 == order.length) {
        order.shuffle();
        position = 0;
        score = 0;
      } else {
        position++;
      }
      selected = -1;
      choices = [0, 1, 2, 3]..shuffle();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Text('Trivia unavailable: $error');
    }
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final item = questions[order[position]] as Map<String, dynamic>;
    final options = (item['options'] as List).cast<String>();
    final correct = item['correct_index'] as int;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANCIENT GODS & GODDESSES',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Question ${position + 1}/${questions.length}   Score: $score',
            style: const TextStyle(fontSize: 11),
          ),
          const SizedBox(height: 5),
          Text(
            '${item["civilization"]} - ${item["difficulty"]}',
            style: const TextStyle(fontSize: 10, color: Colors.amber),
          ),
          const SizedBox(height: 7),
          Text(
            item['question'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 7),
          for (final originalIndex in choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: selected >= 0
                      ? null
                      : () => setState(() {
                          selected = originalIndex;
                          if (originalIndex == correct) score++;
                        }),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      options[originalIndex],
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ),
            ),
          if (selected >= 0) ...[
            Text(
              selected == correct ? 'Correct!' : 'Incorrect',
              style: const TextStyle(color: Colors.amber),
            ),
            Text(
              item['explanation'] as String,
              style: const TextStyle(fontSize: 10),
            ),
            TextButton(
              onPressed: nextQuestion,
              child: Text(
                position == order.length - 1 ? 'Play Again' : 'Next Question',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
