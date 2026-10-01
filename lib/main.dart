import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/tas_database.dart';
import 'data/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final directory = await getApplicationSupportDirectory();
    final database = TasDatabase.file(File(p.join(directory.path, 'tas.sqlite')));
    final repository = TaskRepository(database);
    await repository.init();
    runApp(TasApp(repository: repository));
  } catch (error) {
    runApp(TasErrorApp(detail: '$error'));
  }
}
