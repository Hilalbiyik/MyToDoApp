import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_to_do_app/constants/colors.dart';
import 'package:my_to_do_app/src/models/to_do_model.dart';
import '../../services/hive_service.dart';

class PageHiveTest extends StatefulWidget {
  const PageHiveTest({super.key});

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
            SizedBox(height: 100,),
            Form(
              key: formKey,
              child: Column(
                children: [
                  TextFormField(
                    onChanged: (e) => todoModel.title = e,
                    validator: (e) =>
                        (e?.length ?? 0) < 2 ? 'Ismin 2 harf olmalı' : null,
                  ),
                  TextFormField(
                    onChanged: (e) => todoModel.description = e,
                    validator: (e) =>
                        (e?.length ?? 0) < 2 ? 'Ismin 2 harf olmalı' : null,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        await HiveService.addToBox(box, todoModel);
                        todoModel = TodoModel.empty();
                      }
                    },
                    child: const Text('Gönder'),
                  ),
                  if (boxLoaded)
                    Container(
                      child: ValueListenableBuilder(
                        valueListenable: box.listenable(),
                        builder: (context, box, child) {
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: box.values.length,
                            itemBuilder: (context, index) {
                              final element = box.values.elementAt(index);
                              return ListTile(
                                
                                title: Text('${element.title}'),
                                subtitle: Text('${element.description}'),
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

  void _editTask(TodoModel task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _editController =
            TextEditingController(text: task.title);

        return AlertDialog(
          title: Text('Düzenle'),
          content: TextField(
            controller: _editController,
            decoration: InputDecoration(hintText: 'Yeni değeri girin'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _saveChanges(task, _editController.text);
                Navigator.pop(context);
              },
              child: Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

//   void _saveChanges(TodoModel task, String newTitle) {
//   _updateTask(task, newTitle);
//   Navigator.pop(context);
// }
void _updateTask(TodoModel task, String newTitle) {
  setState(() {
    task.title = newTitle;
    // Gerekirse diğer alanları da güncelleyebilirsiniz
    // task.description = yeniAçıklama;
    // task.isDone = yeniDurum;
  });
  HiveService.updateTask(box, box.values.toList().indexOf(task), task);
}

// void _saveChanges(TodoModel task, String newTitle) async {
//   // Burada gerekli güncelleme işlemlerini gerçekleştir
//   _updateTask(task, newTitle);

//   // Örnek olarak, herhangi bir hata durumu kontrolü
//   bool saveSuccessful = await _performSaveOperation();

//   // Kaydetme başarılıysa pop işlemi gerçekleştir
//   if (saveSuccessful) {
//     Navigator.pop(context);
//   } else {
//     // Hata durumu için kullanıcıya uyarı göster
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Kaydetme sırasında bir hata oluştu.'),
//       ),
//     );
//   }
// }

Future<bool> _performSaveOperation() async {
  // Burada asenkron olarak kaydetme işlemini gerçekleştir
  // Eğer başarılıysa true, aksi takdirde false döndür
  try {
    // Örneğin, bir API çağrısı veya başka bir asenkron işlem yapabilirsiniz.
    // await apiService.saveTask(task);
    return true;
  } catch (e) {
    // Hata durumu için gerekli işlemleri yapabilirsiniz.
    print('Kaydetme hatası: $e');
    return false;
  }
}

void _saveChanges(TodoModel task, String newTitle) async {
  // Burada gerekli güncelleme işlemlerini gerçekleştir
  _updateTask(task, newTitle);

  // Bekleme süresini belirleyebilirsiniz, örneğin 500 milisaniye
  await Future.delayed(Duration(milliseconds: 500));

  // Ekranı yeniden yükleme işlemi
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => PageHiveTest()),
  );
}






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