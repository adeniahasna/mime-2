import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/assets_image.dart';
import 'package:flutter_app/config/task.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends NyStatefulWidget {
  static RouteView path =
      ("/add-task", (_) => AddTaskPage(initialDate: DateTime.now()));

  final DateTime initialDate;

  AddTaskPage({Key? key, required this.initialDate})
      : super(key: key, child: () => _AddTaskPageState());
}

class _AddTaskPageState extends NyPage<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late DateTime _startDate;
  late TimeOfDay _startTime;
  late DateTime _endDate;
  late TimeOfDay _endTime;
  String _status = "Open";
  String _priority = "Low";
  String _selectedIcon = "personal";
  String _group = "Personal";

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate;
    _endDate = widget.initialDate;
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Stack(
          children: [
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: 25),
                child: Text(
                  "Add New Task",
                  style: GoogleFonts.anekDevanagari(),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Positioned(
              top: 13,
              left: 0,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Image.asset(
                  AssetImages.backButton,
                  width: 20,
                  height: 20,
                ),
              ),
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
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Center(
                      child: GestureDetector(
                        onTap: ShowIconSelection,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withAlpha(3),
                                spreadRadius: 1,
                                blurRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            getIconPath(_selectedIcon),
                            width: 40,
                            height: 40,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 80),
                      child: TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.transparent,
                          alignLabelWithHint: true,
                        ),
                        textAlign: TextAlign.center,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              child: Text(
                                DateFormat('MM/dd/yyyy').format(_startDate),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(true),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Time',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              child: Text(_startTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              child: Text(
                                DateFormat('MM/dd/yyyy').format(_endDate),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(false),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Time',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              child: Text(_endTime.format(context)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _status,
                      items: ["Open", "In Progress", "Done"].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: _priority,
                      items: ["Low", "Medium", "High"].map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                            print(
                                "Priority changed to: $_priority"); // Debugging
                          });
                        }
                      },
                    ),
                    SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4413D2),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Save Task',
                          style: GoogleFonts.anekDevanagari(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void ShowIconSelection() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Task Icon'),
          content: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildIconOption('personal', AssetImages.personal),
                buildIconOption('exercise', AssetImages.exercise),
                buildIconOption('work', AssetImages.work),
                buildIconOption('study', AssetImages.study),
              ],
            ),
          ),
        );
      },
    );
  }

  String getIconPath(String icon) {
    switch (icon) {
      case 'personal':
        return AssetImages.personal;
      case 'exercise':
        return AssetImages.exercise;
      case 'study':
        return AssetImages.study;
      case 'work':
        return AssetImages.work;
      default:
        return AssetImages.personal;
    }
  }

  Widget buildIconOption(String value, String iconPath) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIcon = value;
          _group = value.capitalize();
          print("icon changed to: $_selectedIcon");
          print("group changed to: $_group");
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              _selectedIcon == value ? Color(0xFFE1C0FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Image.asset(iconPath, width: 50, height: 50),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      User? user =
          FirebaseAuth.instance.currentUser; // Dapatkan User yang sedang login

      if (user == null) {
        print("User not logged in!");
        return;
      }

      String uid = user.uid; // Ambil UID user
      Task newTask = Task(
        name: _titleController.text,
        description: _descriptionController.text,
        startDate: _startDate,
        startTime: _startTime,
        endDate: _endDate,
        endTime: _endTime,
        status: _status,
        priority: _priority,
        icon: _selectedIcon,
        group: _group,
        deleted: false,
      );

      // Simpan ke Firestore berdasarkan UID user
      try {
        await FirebaseFirestore.instance
            .collection("tasks")
            .doc(uid)
            .collection("userTasks")
            .add(newTask.toMap());

        print("Task berhasil disimpan!");

        Navigator.pop(context, newTask);
      } catch (e) {
        print("Error menyimpan task: $e");
      }
    }
  }
}
