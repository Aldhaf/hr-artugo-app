// Titik masuk untuk lingkungan Development
import 'package:hr_artugo_app/config/env_dev.dart';
import 'package:hr_artugo_app/main.dart' as App;

void main() async {
  await App.runSharedApp(configDev); 
}