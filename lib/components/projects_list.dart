import 'package:flutter/material.dart';
import 'package:nav_monitor/pages/activities_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_monitor/constants/fonts.dart';
import 'package:nav_monitor/services/get_activity.dart';
import 'package:nav_monitor/services/get_project.dart';
import 'package:nav_monitor/services/get_questions.dart';
import 'package:nav_monitor/services/sqlite_service.dart';

class ProjectsList extends StatefulWidget {
  const ProjectsList({super.key});

  @override
  State<ProjectsList> createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  late Future<List<Map<String, dynamic>>> _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = DatabaseService().getAllProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _projectFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                return NoProjectsFound(onReload: () => _loadFromCloud(context));
              }

              final projects = snapshot.data!;
              return ListView.builder(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return ProjectTile(project: project);
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _loadFromCloud(context),
            icon: const Icon(
              Icons.sync,
              color: Colors.white,
            ),
            label: Text("Sync with Cloud",
                style: bodyText1.copyWith(color: Colors.white, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 17),
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _loadFromCloud(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Syncing with cloud...")),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final orgId = prefs.getString("org_id");
      if (orgId == null) throw Exception("Organization ID not found");

      final fetchedProjects = await fetchProject();
      final fetchedActivities = await fetchActivity();
      print("[fetchedActivities] $fetchedActivities");
      final fetchedQuestions = await fetchQuestions();
      print("[fetchedQuestions] $fetchedQuestions");

      /// PROJECTS
      final localProjects = await DatabaseService().getAllProjects();
      final localProjectIds = localProjects.map((p) => p['project_id']).toSet();
      final newProjects = fetchedProjects
          .where((p) => !localProjectIds.contains(p['project_id']))
          .toList();
      print('New projects to insert: ${newProjects.length}');
      if (newProjects.isNotEmpty) {
        await DatabaseService().insertProject(newProjects);
      }

      /// ACTIVITIES
      final localActivities = await DatabaseService().getActivities();
      final localActivityIds =
          localActivities.map((a) => a['activity_id']).toSet();
      final newActivities = fetchedActivities
          .where((a) => !localActivityIds.contains(a['activity_id']))
          .toList();
      print('New activities to insert: ${newActivities.length}');
      if (newActivities.isNotEmpty) {
        await DatabaseService().insertActivity(newActivities);
      }

      /// QUESTIONS
      final localQuestions = await DatabaseService().getQuestions();
      final localQuestionIds =
          localQuestions.map((q) => q['question_id']).toSet();
      final newQuestions = fetchedQuestions
          .where((q) => !localQuestionIds.contains(q['question_id']))
          .toList();
      print('New questions to insert: ${newQuestions.length}');
      if (newQuestions.isNotEmpty) {
        await DatabaseService().insertQuestion(newQuestions);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sync successful")),
      );

      // Force refresh of UI
      setState(() {
        _projectFuture = Future.value([]); // Clear
      });
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _projectFuture = DatabaseService().getAllProjects(); // Reload
      });
    } catch (e) {
      print("Sync error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sync failed: ${e.toString()}")),
      );
    }
  }
}

class ProjectTile extends StatelessWidget {
  final Map<String, dynamic> project;

  const ProjectTile({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(project['project_name'].toString(),
            style: bodyText1.copyWith(
                color: Colors.black, fontWeight: FontWeight.bold)),
        subtitle: Text("End Date: ${project['end_date']}",
            style: bodyText1.copyWith()),
        leading: const Icon(Icons.book),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivitiesPage(
                  projectId: project['project_id'].trim().toString()),
            ),
          );
        },
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.navigate_next),
        ),
        tileColor: const Color.fromARGB(255, 94, 181, 243),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // You can also set selectedTileColor, hoverColor, etc. if needed
      ),
    );
  }
}

class NoProjectsFound extends StatelessWidget {
  final VoidCallback onReload;

  const NoProjectsFound({super.key, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Current Surveys",
                style: headline1.copyWith(
                    fontSize: 24, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            const Icon(Icons.warning, color: Colors.red, size: 80),
            const SizedBox(height: 16),
            Text("No surveys found", style: bodyText1),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onReload,
              icon: const Icon(Icons.cloud_download, color: Colors.white),
              label: Text("Load from cloud",
                  style: bodyText1.copyWith(color: Colors.white)),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
