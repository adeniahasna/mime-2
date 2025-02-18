import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/assets_image.dart';
import 'package:flutter_app/resources/pages/bottom_nav_bar_page.dart';
import 'package:flutter_app/config/task.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nylo_framework/nylo_framework.dart';

class DashboardPage extends NyStatefulWidget {
  static RouteView path = ("/dashboard", (_) => DashboardPage());

  DashboardPage({super.key}) : super(child: () => _DashboardPageState());
}

class _DashboardPageState extends NyPage<DashboardPage> {
  DateTime today = DateTime.now();
  Map<String, List<Task>> tasks = {};
  late String todayKey;
  late List<Task> todayTasks;

  @override
  void initState() {
    super.initState();
    todayKey = DateFormat('yyyy-MM-dd').format(today);
    todayTasks = tasks[todayKey] ?? [];
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

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: SizedBox(
                  height: 18,
                  child: Image.asset(AssetImages.logo),
                ),
              ),
            ],
          ),
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
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
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
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 23),
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
                  Expanded(child: _buildTodaySection(todayTasks)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySection(List<Task> todayTasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Today Task",
            style: GoogleFonts.anekDevanagari(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        todayTasks.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "You don't have task today",
                    style: GoogleFonts.anekDevanagari(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            : _buildHorizontalScroll(todayTasks),
      ],
    );
  }

  Widget _buildTaskSection(String title, List<Task> taskList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: GoogleFonts.anekDevanagari(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        _buildHorizontalScroll(taskList),
      ],
    );
  }

  Widget _buildHorizontalScroll(List<Task> taskList) {
    return SizedBox(
      height: 120, // Sesuaikan tinggi item
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: taskList.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(taskList[index]);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      width: 200, // Lebar kotak task
      margin: EdgeInsets.symmetric(horizontal: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            task.name,
            style: GoogleFonts.anekDevanagari(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            task.description,
            style: GoogleFonts.anekDevanagari(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
