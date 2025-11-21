import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Scaffold(
      body: SingleChildScrollView(
        // Menggunakan SafeArea agar tidak tertimpa status bar
        child: Container(
          padding: const EdgeInsets.all(30.0),
          width: double.infinity,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Meratakan teks ke kiri
            children: [
              const SizedBox(height: 50.0),

              // --- Bagian Header ---
              Image.asset(
                "assets/icon/icon_login_view.png",
                width: 80.0,
              ),
              const SizedBox(height: 20.0),
              FittedBox(
                fit: BoxFit.scaleDown, // Hanya kecilkan jika tidak muat
                child: RichText(
                  text: TextSpan(
                    text: 'login_welcome_back'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'ArtuGo',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'login_subtitle'.tr,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40.0),

              // --- Bagian Form ---
              TextField(
                controller: controller.emailController,
                decoration: InputDecoration(labelText: 'login_email_label'.tr),
              ),
              const SizedBox(height: 16.0),
              Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.isPasswordObscured.value,
                    decoration: InputDecoration(
                      labelText: 'login_password_label'.tr,
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordObscured.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => controller.togglePasswordVisibility(),
                      ),
                    ),
                  )),
              // Checkbox "Remember Me"
              Obx(() => CheckboxListTile(
                    title: Text('login_remember_me'.tr),
                    value: controller.rememberMe.value,
                    onChanged: (newValue) {
                      controller.rememberMe.value = newValue ?? false;
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  )),
              const SizedBox(height: 10.0),

              // --- Tombol Login ---
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => controller.doLogin(),
                  child: Text(
                    'login_btn'.tr,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}
