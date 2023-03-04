import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/tasks_model.dart';

class CompletedTasksView extends StatefulWidget {
  const CompletedTasksView({super.key});

  @override
  State<CompletedTasksView> createState() => _CompletedTasksViewState();
}

class _CompletedTasksViewState extends State<CompletedTasksView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<Task> completedTasks = [];

  Future<List<Task>> loadTasks() async {
    final SharedPreferences prefs = await _prefs;
    final List<String> taskList = prefs.getStringList('completedTasks') ?? [];
    final List<Task> retrievedTasks =
        taskList.map((task) => Task.fromJson(task)).toList().reversed.toList();
    return retrievedTasks;
  }

  void toggleTaskCompletion({required int index, required bool value}) async {
    final SharedPreferences prefs = await _prefs;
    final List<String> taskList = prefs.getStringList('tasks') ?? [];
    final List<Task> retrievedTasks =
        taskList.map((task) => Task.fromJson(task)).toList();
    completedTasks[index].isCompleted = value;
    setState(() {});
    retrievedTasks.insert(0, completedTasks[index]);
    Future.delayed(const Duration(milliseconds: 500), () async {
      completedTasks.removeAt(index);
      await prefs.setStringList(
          'completedTasks',
          completedTasks
              .map((task) => task.toJson())
              .toList()
              .reversed
              .toList());
      // await saveTasks();

      await prefs.setStringList(
          'tasks', retrievedTasks.map((task) => task.toJson()).toList());

      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    loadTasks().then((value) {
      setState(() {
        completedTasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: completedTasks.isEmpty
                ? const Center(
                    child: Text(
                      'No completed tasks',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : generateTaskListView(),
          )
        ],
      ),
    );
  }

  Widget generateTaskWidget(
      {required String text,
      required bool isCompleted,
      bool? isDeleted,
      required int index}) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Checkbox(
              value: isCompleted,
              onChanged: (value) =>
                  toggleTaskCompletion(index: index, value: value!)),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                color: isCompleted ? Colors.grey.shade600 : Colors.black,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
                decorationColor: Colors.black,
                decorationThickness: 1.5,
                decorationStyle: TextDecorationStyle.solid,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget generateTaskListView() {
    return ListView.builder(
      // reverse: true,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: completedTasks.length,
      itemBuilder: (
        context,
        index,
      ) {
        final task = completedTasks[index];

        return Padding(
          padding: const EdgeInsets.all(13.0),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    // deleteTask(index: index);
                  },
                  icon: Icons.delete,
                  backgroundColor: Colors.black26,
                  label: "Delete",
                ),
              ],
            ),
            child: generateTaskWidget(
                text: task.title,
                isCompleted: task.isCompleted,
                isDeleted: task.isDeleted,
                index: index),
          ),
        );
      },
    );
  }
}
