import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

void main() {
  runApp(MyApp());
}

class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;

  Question(this.questionText, this.options, this.correctOptionIndex);
}

class MyApp extends StatelessWidget {
  final List<Question> questions = [
    Question(
      'What is the capital of France?',
      ['Berlin', 'Madrid', 'Paris', 'Rome'],
      2,
    ),
    Question(
      'Which planet is known as the Red Planet?',
      ['Mars', 'Venus', 'Jupiter', 'Saturn'],
      0,
    ),
    Question(
      'What is the largest mammal?',
      ['Elephant', 'Giraffe', 'Blue Whale', 'Hippopotamus'],
      2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('MCQ Quiz'),
        ),
        body: QuestionPage(questions),
      ),
    );
  }
}

class QuestionPage extends StatefulWidget {
  final List<Question> questions;

  QuestionPage(this.questions);

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = List<int?>.filled(3, null);

  void selectOption(int optionIndex) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = optionIndex;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    }
  }

  void submitQuiz() {
    // Calculate the user's score based on selected answers
    int score = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (selectedAnswers[i] == widget.questions[i].correctOptionIndex) {
        score++;
      }
    }

    // Show the result dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Quiz Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your Score: $score / ${widget.questions.length}'),
              Container(
                height: 200,
                child: charts.PieChart(
                  _createChartData(score, widget.questions.length - score),
                  animate: true,
                  defaultRenderer: charts.ArcRendererConfig(
                    arcWidth: 40,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<charts.Series<AnswerData, String>> _createChartData(
      int correctCount, int incorrectCount) {
    final data = [
      AnswerData('Correct', correctCount),
      AnswerData('Incorrect', incorrectCount),
    ];

    return [
      charts.Series<AnswerData, String>(
        id: 'QuizResult',
        domainFn: (AnswerData data, _) => data.answer,
        measureFn: (AnswerData data, _) => data.count,
        data: data,
        labelAccessorFn: (AnswerData data, _) =>
            '${data.answer}: ${data.count}',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = widget.questions[currentQuestionIndex];

    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${currentQuestionIndex + 1}: ${currentQuestion.questionText}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Column(
            children: currentQuestion.options.asMap().entries.map((entry) {
              int optionIndex = entry.key;
              String optionText = entry.value;
              return ListTile(
                leading: Radio(
                  value: optionIndex,
                  groupValue: selectedAnswers[currentQuestionIndex],
                  onChanged: (value) => selectOption(value!),
                ),
                title: Text(optionText),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (currentQuestionIndex < widget.questions.length - 1) {
                nextQuestion();
              } else {
                submitQuiz();
              }
            },
            child: Text(currentQuestionIndex < widget.questions.length - 1
                ? 'Next Question'
                : 'Submit'),
          ),
        ],
      ),
    );
  }
}

class AnswerData {
  final String answer;
  final int count;

  AnswerData(this.answer, this.count);
}
