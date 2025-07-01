import 'package:flutter/material.dart';
import 'package:nav_monitor/constants/fonts.dart';
import 'package:nav_monitor/pages/activity_survey_page.dart';
import 'package:nav_monitor/pages/question_form_page.dart';
import 'package:nav_monitor/services/sqlite_service.dart';

class ActivitiesPage extends StatelessWidget {
  final String projectId;

  const ActivitiesPage({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Activities")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getProjectActivities(projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No activities found"));
          }

          final activities = snapshot.data!;
          return ListView.builder(
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  tileColor: Colors.blue.shade100,
                  title: Text(activity['activity_name'] ?? 'Unnamed',
                      style: bodyText1.copyWith(color: Colors.black)),
                  subtitle: Text(
                      "Start: ${activity['start_date']} - End: ${activity['end_date']}",
                      style: bodyText1.copyWith(fontSize: 12)),
                  leading: const Icon(Icons.task),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SurveyPage(activityId: activity['activity_id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getProjectActivities(
      String projectId) async {
    final allActivities = await DatabaseService().getActivities();
    final filtered = allActivities
        .where((activity) => activity['project_id'] == projectId)
        .toList();
    print("[getProjectActivities]: $filtered");
    return filtered;
  }
}
