import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/config/assets_image.dart';
import 'package:flutter_app/resources/pages/add_task_page.dart';
import 'package:flutter_app/resources/pages/dashboard_page.dart';
import 'package:flutter_app/resources/pages/task_list_page.dart';
import 'package:flutter_app/config/task.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BottomNavBarPage extends NyStatefulWidget {
  static RouteView path = ("/bottom-nav-bar", (_) => BottomNavBarPage());

  BottomNavBarPage({super.key}) : super(child: () => _BottomNavBarPageState());

  static void navigateToPage(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_BottomNavBarPageState>();
    if (state != null) {
      state._handleNavigation(index);
    }
  }
}

class _BottomNavBarPageState extends NyPage<BottomNavBarPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, List<Task>> tasks = {};
  int currentIndex = 0;

  void _addTaskToList(Task task) {
    for (DateTime date = task.startDate;
        !date.isAfter(task.endDate);
        date = date.add(Duration(days: 1))) {
      String key = DateFormat('yyyy-MM-dd').format(date);
      if (!tasks.containsKey(key)) {
        tasks[key] = [];
      }
      tasks[key]!.add(task);
    }
    _saveTasks();
    setState(() {});
  }

  void _handleNavigation(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  final List<Widget> pages = [
    DashboardPage(),
    TaskListPage(),
  ];

  final List<String> iconPaths = [
    AssetImages.homeOff,
    AssetImages.listOff,
  ];

  final List<String> activeIconPaths = [
    AssetImages.homeOn,
    AssetImages.listOn,
  ];

  void onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      String? storedTasks = await NyStorage.read('tasks');
      if (storedTasks != null) {
        Map<String, dynamic> tasksMap = jsonDecode(storedTasks);

        tasksMap.forEach((date, tasksList) {
          List<dynamic> tasksForDate = tasksList;
          tasks[date] = tasksForDate
              .map(
                  (taskMap) => Task.fromMap(Map<String, dynamic>.from(taskMap)))
              .toList();
        });
        setState(() {});
      }
    } catch (e) {
      print("Error loading tasks: $e");
    }
  }

  Future<void> _saveTasks() async {
    try {
      Map<String, List<Map<String, dynamic>>> tasksForStorage = {};
      tasks.forEach((date, tasksList) {
        tasksForStorage[date] = tasksList.map((task) => task.toMap()).toList();
      });

      await NyStorage.save('tasks', jsonEncode(tasksForStorage));
    } catch (e) {
      print("Error saving tasks: $e");
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(),
        backgroundColor: const Color(0xFF4413d2),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF4F0FE),
                Color(0xFFE1C0FF),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BottomAppBar(
            notchMargin: 6.0,
            shape: CircularNotchedRectangle(),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildNavBarItem(0),
                const SizedBox(width: 20),
                buildNavBarItem(1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToAddTask() async {
    Task? newTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(initialDate: selectedDate),
      ),
    );

    if (newTask != null) {
      _addTaskToList(newTask);
    }
  }

  Widget buildNavBarItem(int index) {
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Color.fromARGB(174, 200, 178, 250)
                      : const Color.fromARGB(0, 0, 0, 0),
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(10),
                    right: Radius.circular(10),
                  ),
                ),
                child: Image.asset(
                  currentIndex == index
                      ? activeIconPaths[index]
                      : iconPaths[index],
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
