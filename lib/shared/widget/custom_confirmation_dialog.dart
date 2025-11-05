import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hr_artugo_app/core.dart' hide Get;

class CustomConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final String confirmText;
  final String cancelText;
  final Color confirmButtonColor;

  const CustomConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmText = "Ya",
    this.cancelText = "Tidak",
    // Ambil warna primer dari tema secara default
    this.confirmButtonColor = const Color(0xFFA27BFF),
  });

  @override
  @override
  Widget build(BuildContext context) {
    // Gunakan warna primer dari tema saat ini jika tidak dispesifikkan
    final Color primaryColor = Get.theme.primaryColor;

    return Dialog(
      backgroundColor: Colors.white, // Latar belakang dialog
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0), // Sudut lebih membulat
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Agar tinggi dialog pas
          children: [
            // Judul Dialog
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // Warna teks judul
              ),
            ),
            const SizedBox(height: 16),

            // Pesan Dialog
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600, // Warna teks pesan
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Tombol Konfirmasi (ElevatedButton)
            SizedBox(
              width: double.infinity, // Lebar penuh
              height: 50,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmButtonColor, // Warna primer
                  foregroundColor: Colors.white, // Teks putih
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0), // Sudut tombol
                  ),
                  elevation: 0, // Hilangkan bayangan jika perlu
                ),
                child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12), // Jarak antar tombol

            // Tombol Batal (OutlinedButton)
            SizedBox(
              width: double.infinity, // Lebar penuh
              height: 50,
              child: OutlinedButton(
                onPressed: () => Get.back(), // Tutup dialog
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor, // Warna teks = warna primer
                  side: BorderSide(color: primaryColor, width: 1.5), // Border warna primer
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0), // Sudut tombol
                  ),
                ),
                child: Text(cancelText, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
