import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/tasks_model.dart';
import 'package:todo_app/views/display_completed_tasks_view.dart';

class DisplayTasksView extends StatefulWidget {
  const DisplayTasksView({super.key});

  @override
  State<DisplayTasksView> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<DisplayTasksView> {
  final TextEditingController _controller = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List<Task> tasks = [];

  Future<List<Task>> loadTasks() async {
    final SharedPreferences prefs = await _prefs;
    final List<String> taskList = prefs.getStringList('tasks') ?? [];
    final List<Task> retrievedTasks =
        taskList.map((task) => Task.fromJson(task)).toList();
    return retrievedTasks;
  }

  void saveCompletedTask({required Task task}) async {
    final SharedPreferences prefs = await _prefs;
    final List<String> taskList = prefs.getStringList('completedTasks') ?? [];
    final List<Task> retrievedTasks =
        taskList.map((task) => Task.fromJson(task)).toList();
    retrievedTasks.add(task);
    final List<String> completedTaskList =
        retrievedTasks.map((task) => task.toJson()).toList();
    prefs.setStringList('completedTasks', completedTaskList);
  }

  Future<void> saveTasks() async {
    final SharedPreferences prefs = await _prefs;
    final List<String> taskList = tasks.map((task) => task.toJson()).toList();
    prefs.setStringList('tasks', taskList);
  }

  void toggleTask({required int index, required bool value}) async {
    tasks[index].isCompleted = value;
    if (value) {
      saveCompletedTask(task: tasks[index]);
    }
    setState(() {});
    Future.delayed(const Duration(milliseconds: 500), () async {
      tasks.removeAt(index);
      await saveTasks();

      setState(() {});
    });
  }

  void createTask(Task task) async {
    tasks.add(task);
    _controller.clear();
    await saveTasks();
    setState(() {});
  }

  void deleteTask({required int index}) async {
    tasks[index].isDeleted = true;
    tasks.removeAt(index);
    await saveTasks();
    setState(() {});
  }

  void updateTask({required Task task, required int index}) async {
    tasks[index] = task;
    tasks.removeAt(index);
    tasks.insert(index, task);
    await saveTasks();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadTasks().then((value) {
      setState(() {
        tasks = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: Colors.white),
                  ),
                  IconButton(
                      onPressed: () async {
                        final response = await Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) =>
                                    const CompletedTasksView()));
                        if (response == null) {
                          loadTasks().then((value) {
                            setState(() {
                              tasks = value;
                            });
                          });
                        }
                      },
                      icon: const Icon(
                        Icons.check_box_outlined,
                        size: 30,
                        color: Colors.white,
                      )),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : generateTaskListView(),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0076FF),
        // shape: ShapeBorder.lerp(
        //   const CircleBorder(),
        //   const StadiumBorder(),
        //   0.5,
        // ),
        onPressed: () async {
          await showBottomSheet(
            context,
            false,
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<dynamic> showBottomSheet(
    BuildContext context,
    bool onEdit, {
    int? index,
  }) async {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (context) => Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(height: 5),
                      Container(
                        height: 3,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Task name e.g go home',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                          labelText: 'Task Name',
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                          onPressed: () async {
                            if (onEdit) {
                              updateTask(
                                  task: Task(title: _controller.text),
                                  index: index!);
                            } else {
                              createTask(Task(
                                title: _controller.text,
                              ));
                            }
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0076FF),
                              shape: const StadiumBorder(),
                              fixedSize:
                                  Size(MediaQuery.of(context).size.width, 50)),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                onEdit ? 'Update Task' : 'Add Task',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  color: Colors.white, size: 20)
                            ],
                          )),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget generateTaskListView() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (
        context,
        index,
      ) {
        final task = tasks[index];

        return Padding(
          padding: const EdgeInsets.all(13.0),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {
                    deleteTask(index: index);
                  },
                  icon: Icons.delete,
                  backgroundColor: Colors.black26,
                  label: "Delete",
                ),
              ],
            ),
            child: GestureDetector(
              onLongPress: () async {
                _controller.text = task.title;

                await showBottomSheet(
                  context,
                  true,
                  index: index,
                );
              },
              child: generateTaskWidget(
                  text: task.title,
                  isCompleted: task.isCompleted,
                  isDeleted: task.isDeleted,
                  index: index),
            ),
          ),
        );
      },
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
              onChanged: (value) => toggleTask(index: index, value: value!)),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                color: isCompleted ? Colors.grey.shade600 : Colors.black,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
