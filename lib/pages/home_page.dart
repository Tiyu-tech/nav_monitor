import 'package:flutter/material.dart';
import 'package:nav_monitor/components/projects_list.dart';
import 'package:nav_monitor/constants/fonts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Current Projects',
              style: headline1.copyWith(color: Colors.white)),
          elevation: 10,
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProjectsList(),
          ),
        ));
  }
}
