import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_to_do_app/constants/colors.dart';
import 'package:my_to_do_app/src/models/to_do_model.dart';
import 'package:my_to_do_app/src/services/hive_service.dart';

class PageHiveTest extends StatefulWidget {
  const PageHiveTest({Key? key}) : super(key: key);

  @override
  State<PageHiveTest> createState() => _PageHiveTestState();
}

class _PageHiveTestState extends State<PageHiveTest> {
  final formKey = GlobalKey<FormState>();
  var todoModel = TodoModel.empty();
  late final Box<TodoModel> box;
  bool boxLoaded = false;

  initLocalDb() async {
    final result = await HiveService.initService();
    print(result);
    box = await HiveService.openBox<TodoModel>();
    setState(() {
      boxLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    initLocalDb();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBar(),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 100),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (e) => todoModel.title = e,
                    validator: (e) =>
                        (e?.length ?? 0) < 2 ? 'Title must be at least 2 characters' : null,
                  ),
                  TextFormField(
                    onChanged: (e) => todoModel.description = e,
                    validator: (e) =>
                        (e?.length ?? 0) < 2 ? 'Description must be at least 2 characters' : null,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await HiveService.addToBox(box, todoModel);
                        todoModel = TodoModel.empty();
                      }
                    },
                    child: const Text('Add Todo'),
                  ),
                  if (boxLoaded)
Container(
  child: StreamBuilder<BoxEvent>(
    stream: box.watch(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator(); // İsteğe bağlı: Veri yüklenene kadar bekleme göster
      }

      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      return ListView.builder(
        shrinkWrap: true,
        itemCount: box.length,
        itemBuilder: (context, index) {
          final element = box.getAt(index);
          return ListTile(
            title: Text('${element?.title ?? ""}'),
            subtitle: Text('${element?.description ?? ""}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    HiveService.remove(box, index);
                  },
                  icon: const Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    _editTask(element);
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
          );
        },
      );
    },
  ),
),





                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _editTask(TodoModel? task) {
    if (task != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final TextEditingController _editController =
              TextEditingController(text: task.title);

          return AlertDialog(
            title: Text('Edit Todo'),
            content: TextField(
              controller: _editController,
              decoration: InputDecoration(hintText: 'Enter the new value'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _saveChanges(task, _editController.text);
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  void _updateTask(TodoModel task, String newTitle) {
    setState(() {
      task.title = newTitle;
    });
    HiveService.updateTask(box, box.values.toList().indexOf(task), task);
  }

  Future<void> _saveChanges(TodoModel task, String newTitle) async {
    _updateTask(task, newTitle);
    await Future.delayed(Duration(milliseconds: 500));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PageHiveTest()),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: tdBGColor,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            Icons.menu,
            color: tdBlack,
            size: 30,
          ),
          Text("Todo List"),
          Icon(
            Icons.table_chart,
            color: tdBlack,
            size: 30,
          ),
        ],
      ),
    );
  }
}
