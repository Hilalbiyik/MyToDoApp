

import 'package:hive/hive.dart';
part 'to_do_model.g.dart';

@HiveType(typeId: 0)
class TodoModel {
  @HiveField(0)
  late int id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late bool isChecked;

  @HiveField(4)
  List<TodoModel> todoList;

  TodoModel({
    required this.id,
    required this.title,
     required this.description,
    required this.isChecked,
    required this.todoList,
  });

  factory TodoModel.empty() => TodoModel(id: 0, title: '', description: '', isChecked: false,todoList: []);
  // TodoModel(required this.title, this.isDone, );
}


// import 'package:hive/hive.dart';
// part 'todo_model.g.dart';

// @HiveType(typeId: 0)
// class TodoModel{

//   @HiveField(0)
//   late int id;

//   @HiveField(1)
//   late String title;

//   @HiveField(2)
//   late String description;

//   @HiveField(3)
//   late bool isDone;

//    @HiveField(4)
//   List<TodoModel> todoList;


//  TodoModel({required this.id, required this.title, required this.description, required this.isDone, required this.todoList});
 
//   // factory PersonModel.empty() => PersonModel(name: '', age: 0, friends: []);
//   // TodoModel(required this.title, this.isDone, );
// }