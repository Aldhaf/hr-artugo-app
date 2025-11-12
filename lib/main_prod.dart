// Titik masuk untuk lingkungan Production
import 'package:hr_artugo_app/config/env_prod.dart';
import 'package:hr_artugo_app/main.dart' as App;

void main() async {
  await App.runSharedApp(configProd); 
}