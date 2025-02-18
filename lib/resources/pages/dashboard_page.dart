import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/assets_image.dart';
import 'package:flutter_app/resources/pages/bottom_nav_bar_page.dart';
import 'package:flutter_app/config/task.dart';
import 'package:flutter_app/resources/pages/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DashboardPage extends NyStatefulWidget {
  static RouteView path = ("/dashboard", (_) => DashboardPage());

  DashboardPage({super.key}) : super(child: () => _DashboardPageState());
}

class _DashboardPageState extends NyPage<DashboardPage> {
  DateTime today = DateTime.now();
  DateTime upcoming = DateTime.now().add(Duration(days: 1));
  DateTime delayed = DateTime.now().subtract(Duration(days: 1));
  Map<String, List<Task>> tasks = {};
  late String todayKey;
  late List<Task> todayTasks;
  late String upcomingKey;
  late List<Task> upcomingTasks;
  late String delayedKey;
  late List<Task> delayedTasks;

  @override
  void initState() {
    super.initState();
    todayKey = DateFormat('yyyy-MM-dd').format(today);
    delayedKey = DateFormat('yyyy-MM-dd').format(delayed);
    upcomingKey = DateFormat('yyyy-MM-dd').format(upcoming);
    todayTasks = tasks[todayKey] ?? [];
    upcomingTasks = tasks[upcomingKey] ?? [];
    delayedTasks = tasks[delayedKey] ?? [];
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in!");
      return;
    }

    FirebaseFirestore.instance
        .collection("tasks")
        .doc(user.uid)
        .collection("userTasks")
        .where('deleted', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      Map<String, List<Task>> loadedTasks = {};
      List<Task> delayedTasksList = [];
      List<Task> todayTasksList = [];
      List<Task> upcomingTasksList = [];

      DateTime now = DateTime.now();
      String todayKey = DateFormat('yyyy-MM-dd').format(now);
      String upcomingKey =
          DateFormat('yyyy-MM-dd').format(now.add(Duration(days: 1)));

      for (var doc in snapshot.docs) {
        Task task = Task.fromMap(doc.data());

        DateTime taskEndDateTime = DateTime(
          task.endDate.year,
          task.endDate.month,
          task.endDate.day,
          task.endTime.hour,
          task.endTime.minute,
        );

        DateTime taskStartDateTime = DateTime(
          task.startDate.year,
          task.startDate.month,
          task.startDate.day,
          task.startTime.hour,
          task.startTime.minute,
        );

        String taskDate = DateFormat('yyyy-MM-dd').format(task.startDate);
        if (taskDate == todayKey && !taskEndDateTime.isBefore(now)) {
          todayTasksList.add(task);
        } else if (taskDate == upcomingKey) {
          upcomingTasksList.add(task);
        } else if (taskEndDateTime.isBefore(now)) {
          delayedTasksList.add(task);
        }

        for (DateTime date = task.startDate;
            !date.isAfter(task.endDate);
            date = date.add(Duration(days: 1))) {
          String key = DateFormat('yyyy-MM-dd').format(date);
          if (!loadedTasks.containsKey(key)) {
            loadedTasks[key] = [];
          }
          loadedTasks[key]!.add(task);
        }
      }

      setState(() {
        tasks = loadedTasks;
        todayTasks = todayTasksList;
        upcomingTasks = upcomingTasksList;
        delayedTasks = delayedTasksList;
      });
    });
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            SizedBox(height: 30),
            Stack(
              children: [
                Center(
                  child: Image.asset(
                    AssetImages.logo,
                    height: 18,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          ProfilePage.path.name,
                        );
                      },
                      child: Image.asset(
                        AssetImages.profileOn,
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(AssetImages.appBg),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      startCard(),
                      SizedBox(height: 25),
                      Align(
                        alignment: Alignment(-0.8, 0),
                        child: Text(
                          "Today Task   (${todayTasks.length})",
                          style: GoogleFonts.anekDevanagari(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: buildTodayList(),
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment(-0.8, 0),
                        child: Text(
                          "Upcoming Task   (${upcomingTasks.length})",
                          style: GoogleFonts.anekDevanagari(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: buildUpcomingList(),
                      ),
                      SizedBox(height: 15),
                      Align(
                        alignment: Alignment(-0.8, 0),
                        child: Text(
                          "Delayed Task   (${delayedTasks.length})",
                          style: GoogleFonts.anekDevanagari(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: buildDelayedList(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget startCard() {
    return Stack(
      children: [
        Column(
          children: [
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 27),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF4413D2),
                  borderRadius: BorderRadius.circular(30),
                  image: DecorationImage(
                    image: AssetImage(AssetImages.circle1),
                    fit: BoxFit.fill,
                  ),
                ),
                height: 170,
              ),
            ),
          ],
        ),
        Positioned(
          left: 50,
          top: 65,
          child: Text(
            "You have task to complete. \n Let's get started!",
            style: GoogleFonts.anekDevanagari(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ),
        Positioned(
          left: 50,
          top: 140,
          child: MaterialButton(
            onPressed: () {
              BottomNavBarPage.navigateToPage(context, 1);
            },
            color: Colors.white,
            textColor: Color(0xFF4413D2),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 23),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "View Task",
              style: GoogleFonts.anekDevanagari(
                  fontSize: 19, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTodayList() {
    List<Task> taskList = todayTasks;

    if (taskList.isEmpty) {
      return Align(
        alignment: Alignment(-0.8, 0),
        child: Container(
          width: 180,
          height: 150,
          margin: EdgeInsets.only(right: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.dnd_forwardslash_rounded,
                    color: Color(0XFF4413D2),
                    size: 30,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "You don't have task to do today.",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    double gridSize = 180;

    return Container(
      padding: EdgeInsets.all(16),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          Task task = taskList[index];
          print('Task: ${task.name}, Priority: ${task.priority}');
          return Container(
            width: gridSize,
            height: gridSize,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: GoogleFonts.anekDevanagari(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${task.startTime.format(context)} - ${task.endTime.format(context)}",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.status,
                            style: TextStyle(
                              color: _getStatusColor(task.status),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                _getPriorityColor(task.priority).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority,
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildUpcomingList() {
    List<Task> taskList = upcomingTasks;

    if (taskList.isEmpty) {
      return Align(
        alignment: Alignment(-0.8, 0),
        child: Container(
          width: 180,
          height: 150,
          margin: EdgeInsets.only(right: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.dnd_forwardslash_rounded,
                    color: Color(0XFF4413D2),
                    size: 30,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "You don't have task to do tomorrow.",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    double gridSize = 180;

    return Container(
      padding: EdgeInsets.all(16),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          Task task = taskList[index];
          print('Task: ${task.name}, Priority: ${task.priority}');
          return Container(
            width: gridSize,
            height: gridSize,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: GoogleFonts.anekDevanagari(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${task.startTime.format(context)} - ${task.endTime.format(context)}",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.status,
                            style: TextStyle(
                              color: _getStatusColor(task.status),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                _getPriorityColor(task.priority).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority,
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildDelayedList() {
    List<Task> taskList = delayedTasks;

    if (taskList.isEmpty) {
      return Align(
        alignment: Alignment(-0.8, 0),
        child: Container(
          width: 180,
          height: 150,
          margin: EdgeInsets.only(right: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.dnd_forwardslash_rounded,
                    color: Color(0XFF4413D2),
                    size: 30,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "You don't have delayed tasks.",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    double gridSize = 180;

    return Container(
      padding: EdgeInsets.all(16),
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          Task task = taskList[index];
          print('Task: ${task.name}, Priority: ${task.priority}');
          return Container(
            width: gridSize,
            height: gridSize,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.name,
                      style: GoogleFonts.anekDevanagari(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "${task.startTime.format(context)} - ${task.endTime.format(context)}",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.status,
                            style: TextStyle(
                              color: _getStatusColor(task.status),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                _getPriorityColor(task.priority).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task.priority,
                            style: TextStyle(
                              color: _getPriorityColor(task.priority),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'In Progress':
        return Colors.orange;
      case 'Done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'High':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
