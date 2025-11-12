// Titik masuk untuk lingkungan Staging
import 'package:hr_artugo_app/config/env_staging.dart';
import 'package:hr_artugo_app/main.dart' as App;

void main() async {
  await App.runSharedApp(configStaging);
}