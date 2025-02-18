import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class EditTaskPage extends NyStatefulWidget {

  static RouteView path = ("/edit-task", (_) => EditTaskPage());
  
  EditTaskPage({super.key}) : super(child: () => _EditTaskPageState());
}

class _EditTaskPageState extends NyPage<EditTaskPage> {

  @override
  get init => () {

  };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Task")
      ),
      body: SafeArea(
         child: Container(),
      ),
    );
  }
}
