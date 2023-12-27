import 'package:hive_flutter/hive_flutter.dart';

import '../models/to_do_model.dart';

class HiveService {
  static Future<bool> initService() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoModelAdapter());
    return true;
  }

  static Future<Box<T>> openBox<T>() async {
    if (Hive.isBoxOpen('$T')) {
      return Hive.box<T>('$T');
    } else {
      return Hive.openBox<T>('$T');
    }
  }

  static Future<int> addToBox<T>(Box<T> box, T data) {
    return box.add(data);
  }

  static Future<void> remove<T>(Box<T> box, int index) {
    return box.deleteAt(index);
  }
  static List<TodoModel>getAllTasks() {
    final result = Hive.box<TodoModel>("todo").values.toList();
    return result;
  }
  static Future<void> updateTask<T>(Box<T> box, int index, T updatedData) async {
    await box.putAt(index, updatedData);
  }
} 


// hive, hive_flutter => deps
// hive_generator, build_runner => dev deps
