import 'package:flutter/material.dart';

import 'app.dart';
import 'services/app_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppScope(notifier: AppState(), child: const ObstetricApp()));
}
