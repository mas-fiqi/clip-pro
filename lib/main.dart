import 'package:flutter/material.dart';
import 'core/services/project_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/project_manager/views/project_manager_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProjectStorageService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuickClip Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const ProjectManagerScreen(),
    );
  }
}
