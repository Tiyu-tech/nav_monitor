import 'package:flutter_survey/flutter_survey.dart';

List<Question> convertToSurveyQuestions(
  List<Map<String, dynamic>> questionsFromDB,
) {
  return questionsFromDB.map((q) {
    final String type = q['question_ans_type']?.toLowerCase() ?? 'text';
    final String questionText = q['question'] ?? '';

    //  Date type
    if (type == "date") {
      return Question(
        question: questionText,
        properties: {'input_type': 'date'},
      );
    }

    // ✅ Yes/No
    if (type == "yesno" || type == "yes_no") {
      return Question(
        question: questionText,
        singleChoice: true,
        answerChoices: {
          "Yes": null,
          "No": null,
        },
      );
    }

    // ✅ Multiple Choice (checkbox)
    if (type == "checkbox" || type == "multi") {
      final options = q['options'] is List
          ? Map<String, List<Question>?>.fromIterable(
              q['options'],
              key: (e) => e.toString(),
              value: (_) => null,
            )
          : {"Option A": null, "Option B": null};

      return Question(
        question: questionText,
        singleChoice: false,
        answerChoices: options,
      );
    }

    // ✅ Single Choice (radio/select)
    if (type == "radio" || type == "select" || type == "dropdown") {
      final options = q['options'] is List
          ? Map<String, List<Question>?>.fromIterable(
              q['options'],
              key: (e) => e.toString(),
              value: (_) => null,
            )
          : {"Option A": null, "Option B": null};

      return Question(
        question: questionText,
        singleChoice: true,
        answerChoices: options,
      );
    }

    // ✅ Default to text input
    return Question(question: questionText);
  }).toList();
}
