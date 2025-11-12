// Titik masuk untuk lingkungan Development
import 'package:hr_artugo_app/config/env_dev.dart';
import 'package:hr_artugo_app/main.dart' as App; // Impor main.dart asli Anda

void main() async {
  await App.runSharedApp(configDev); 
}