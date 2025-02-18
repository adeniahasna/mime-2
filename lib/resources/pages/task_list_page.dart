import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/assets_image.dart';
import 'package:flutter_app/config/task.dart';
import 'package:flutter_app/resources/pages/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';

class TaskListPage extends NyStatefulWidget {
  static RouteView path = ("/task-list", (_) => TaskListPage());

  TaskListPage({super.key}) : super(child: () => _TaskListPageState());
}

class _TaskListPageState extends NyPage<TaskListPage> {
  ScrollController scrollController = ScrollController();
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  Map<String, List<Task>> tasks = {};
  String selectedStatus = "All";
  final List<String> statuses = ["All", "Open", "In Progress", "Done"];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToDate();
    });
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
      for (var doc in snapshot.docs) {
        Task task = Task.fromMap(doc.data());
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
      });
    });
  }

  void scrollToDate() {
    DateTime now = DateTime.now();
    int targetDay;

    if (currentMonth.year == now.year && currentMonth.month == now.month) {
      targetDay = now.day;
    } else {
      targetDay = 1;
    }

    setState(() {
      selectedDate = DateTime(currentMonth.year, currentMonth.month, targetDay);
    });

    int targetIndex = targetDay - 1;
    double scrollPosition = targetIndex * 50.0;

    scrollController.animateTo(
      scrollPosition,
      duration: Duration(milliseconds: 700),
      curve: Curves.easeInOut,
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      currentMonth =
          DateTime(currentMonth.year, currentMonth.month + offset, 1);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToDate();
      });

      if (selectedDate.month != currentMonth.month ||
          selectedDate.year != currentMonth.year) {
        selectedDate = DateTime(currentMonth.year, currentMonth.month, 1);
      }
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AssetImages.appBg),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 10),
              buildMonthSelector(),
              buildCalendar(),
              SizedBox(height: 5),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Task List",
                    style: GoogleFonts.anekDevanagari(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 5),
              buildStatusFilter(),
              SizedBox(height: 10),
              Expanded(child: _buildTaskList()),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, size: 18),
          onPressed: () => _changeMonth(-1),
        ),
        Text(
          DateFormat('MMMM yyyy').format(currentMonth),
          style: GoogleFonts.anekDevanagari(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward, size: 18),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget buildStatusFilter() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedStatus == statuses[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedStatus = statuses[index];
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 7),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF4413D2) : Color(0xFFEEE9FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  statuses[index],
                  style: GoogleFonts.anekDevanagari(
                    color: isSelected ? Colors.white : Color(0xFF4413D2),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCalendar() {
    int daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    return Container(
      height: 100,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          DateTime date =
              DateTime(currentMonth.year, currentMonth.month, index + 1);
          bool isSelected = selectedDate.day == date.day &&
              selectedDate.month == currentMonth.month &&
              selectedDate.year == currentMonth.year;
          bool hasTask =
              tasks.containsKey(DateFormat('yyyy-MM-dd').format(date));
          String dayName = DateFormat('E').format(date).substring(0, 2);
          return GestureDetector(
            onTap: () => _selectDate(date),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 7),
                      padding: isSelected
                          ? EdgeInsets.symmetric(horizontal: 18, vertical: 17)
                          : EdgeInsets.symmetric(horizontal: 14, vertical: 17),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Color(0xFF4413D2) : Color(0xFFEEE9FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.anekDevanagari(
                            color:
                                isSelected ? Colors.white : Color(0xFF4413D2),
                            fontSize: 25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 4,
                      child: Text(
                        dayName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.anekDevanagari(
                          color: isSelected ? Colors.white : Color(0xFF4413D2),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    if (hasTask && !isSelected)
                      Positioned(
                        top: 0,
                        right: 3,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Color(0xFF4413D2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList() {
    if (selectedDate.month != currentMonth.month ||
        selectedDate.year != currentMonth.year) {
      return Center(child: Text("Select a date to view tasks."));
    }

    String key = DateFormat('yyyy-MM-dd').format(selectedDate);
    List<Task> taskList = tasks[key] ?? [];

    // Filter by status if needed
    if (selectedStatus != "All") {
      taskList =
          taskList.where((task) => task.status == selectedStatus).toList();
    }

    if (taskList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_note, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("No tasks for this day",
                style: GoogleFonts.anekDevanagari(
                  fontSize: 16,
                  color: Colors.grey,
                )),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: taskList.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        Task task = taskList[index];
        print('Task: ${task.name}, Priority: ${task.priority}'); // Debug print
        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              task.name,
              style: GoogleFonts.anekDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  "${task.startTime.format(context)} - ${task.endTime.format(context)}",
                  style: TextStyle(color: Colors.grey[700]),
                ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status).withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      color: _getStatusColor(task.status),
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority).withAlpha(50),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      color: _getPriorityColor(task.priority),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (String value) {
                if (value == 'change_status') {
                  _showChangeStatusDialog(task);
                } else if (value == 'delete_task') {
                  _showDeleteConfirmDialog(task);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'change_status',
                  child: Text('Change Status'),
                ),
                PopupMenuItem<String>(
                  value: 'delete_task',
                  child: Text('Delete Task'),
                ),
              ],
            ),
            children: [
              if (task.description.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(task.description),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open':
        return Colors.blue;
      case 'In Progress':
        return Colors.green;
      case 'Done':
        return Colors.grey;
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

  void _showChangeStatusDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Status"),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: statuses.length - 1,
              itemBuilder: (BuildContext context, int index) {
                final status = statuses[index + 1];
                return ListTile(
                  title: Text(status),
                  onTap: () async {
                    task.status = status;
                    await _updateTaskInFirestore(task);
                    setState(() {});
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteTask(task);
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateTaskInFirestore(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in!");
      return;
    }

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection("tasks")
          .doc(user.uid)
          .collection("userTasks")
          .where("name", isEqualTo: task.name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("Task not found!");
        return;
      }

      for (var doc in querySnapshot.docs) {
        await doc.reference.update(task.toMap());
      }

      print("Task updated successfully!");
    } catch (e) {
      print("Error updating task in Firestore: $e");
    }
  }

  void _deleteTask(Task task) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in!");
      return;
    }

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection("tasks")
          .doc(user.uid)
          .collection("userTasks")
          .where("name", isEqualTo: task.name)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("Task not found!");
        return;
      }

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'deleted': true});
      }

      setState(() {
        for (DateTime date = task.startDate;
            !date.isAfter(task.endDate);
            date = date.add(Duration(days: 1))) {
          String key = DateFormat('yyyy-MM-dd').format(date);
          tasks[key]?.remove(task);
          if (tasks[key]?.isEmpty ?? false) {
            tasks.remove(key);
          }
        }
      });

      print("Task marked as deleted successfully!");
    } catch (e) {
      print("Error marking task as deleted in Firestore: $e");
    }
  }
}
