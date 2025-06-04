import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'background_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  await Workmanager().registerPeriodicTask(
    "1", // benzersiz ID
    fetchPrayerTask,
    frequency: const Duration(hours: 1),
    initialDelay: const Duration(minutes: 1),
    constraints: Constraints(networkType: NetworkType.connected),
  );
  runApp(const MyApp());
}
