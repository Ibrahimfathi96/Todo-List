import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/my_database/task_db.dart';
import 'package:todo_app/utils/date_utils.dart';

class MyDatabase {
  static CollectionReference<TaskMD> getTasksCollection() {
    var tasksCollection = FirebaseFirestore.instance
        .collection('tasks')
        .withConverter(
            fromFirestore: (snapshot, options) =>
                TaskMD.fromFireStore(snapshot.data()!),
            toFirestore: (task, options) => task.toFireStore());
    return tasksCollection;
  }

  static Future<void> insertTasks(TaskMD task) {
    var taskCollection = getTasksCollection();
    // taskCollection.add(task);
    //handle id of the task //AutoGenerated id like in the firestore console
    var doc = taskCollection.doc();
    task.id = doc.id;
    task.dateTime = task.dateTime.extractDateOnly();
    return doc.set(task);
  }

  static Future<void> editTasks (TaskMD taskMD) async {
    var taskCollection = getTasksCollection();
    return await taskCollection.doc(taskMD.id).update({
      'id': taskMD.id,
      'title': taskMD.title,
      'description': taskMD.description,
      'dateTime': taskMD.dateTime.millisecondsSinceEpoch,
      'isDone': taskMD.isDone
    });
  }

  static Future<void> markAsDone (TaskMD taskMD) async {
    var taskCollection = getTasksCollection();
    return await taskCollection.doc(taskMD.id).update({
      'isDone': taskMD.isDone ? false : true
    });
  }

  static Future<List<TaskMD>> getTasksList(DateTime dateTime) async {
    var querySnapShot = await getTasksCollection()
        .where('dateTime',
            isEqualTo: dateTime.extractDateOnly().millisecondsSinceEpoch)
        .get();
    var tasksList = querySnapShot.docs.map((e) => e.data()).toList();
    return tasksList;
  }

  static Future<QuerySnapshot<TaskMD>> getTasksFuture(DateTime dateTime) {
    return getTasksCollection()
        .where('dateTime',
            isEqualTo: dateTime.extractDateOnly().millisecondsSinceEpoch)
        .get();
  }

  static Stream<QuerySnapshot<TaskMD>> getTasksRealTimeUpdates(
      DateTime dateTime) {
    return getTasksCollection()
        .where('dateTime',
            isEqualTo: dateTime.extractDateOnly().millisecondsSinceEpoch)
        .snapshots();
  }

  static Future<void> deleteTask(TaskMD task) {
    var taskDoc = getTasksCollection().doc(task.id);
    return taskDoc.delete();
  }
}
