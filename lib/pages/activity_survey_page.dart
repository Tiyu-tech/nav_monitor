import 'package:flutter/material.dart';
import 'package:flutter_survey/flutter_survey.dart';
import 'package:nav_monitor/constants/fonts.dart';
import 'package:nav_monitor/services/sqlite_service.dart';

class SurveyPage extends StatefulWidget {
  final String activityId;
  const SurveyPage({super.key, required this.activityId});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  List<Question> questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final dbQuestions = await DatabaseService().getQuestions();
    final filtered = dbQuestions
        .where((q) => q['activity_id'] == widget.activityId)
        .toList();

    setState(() {
      questions = _convertToSurveyQuestions(filtered);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Survey",
          style: headline1,
        ),
        centerTitle: true,
        elevation: 10,
      ),
      body: questions.isEmpty
          ? Center(child: Text("No questions to be answered"))
          : Column(
              children: [
                Expanded(
                  child: Survey(
                    initialData: questions,
                    onNext: (questionResults) {
                      print(questionResults);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(); // Closes the survey page
                      },
                      icon: Icon(Icons.check, color: Colors.green),
                      label: Text("Close Survey",
                          style: bodyText1.copyWith(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  List<Question> _convertToSurveyQuestions(List<Map<String, dynamic>> raw) {
    return raw.map((q) {
      final String type = q['question_ans_type']?.toLowerCase() ?? 'text';
      final String text = q['question'] ?? '';
      // You may need to adjust the Question constructor according to your model
      if (type == "yesno") {
        return Question(
            question: text,
            singleChoice: true,
            isMandatory: true,
            answerChoices: {'Yes': null, 'No': null});
      }
      if (type == "date") {
        return Question(
          question: text,
          isMandatory: true,
          properties: {'input_type': 'date'}, // 👈 mark this as date
        );
      }

      return Question(
        question: text,
      );
    }).toList();
  }
}
