import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Efektif per: 26 September 2025",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              "PT Artugo (\"Kami\") mengoperasikan aplikasi Arttend (\"Layanan\"). Kebijakan Privasi ini memberi tahu Anda tentang kebijakan kami mengenai pengumpulan, penggunaan, dan pengungkapan data pribadi saat Anda menggunakan Layanan kami.\n\nKami menggunakan data Anda untuk menyediakan dan meningkatkan Layanan. Dengan menggunakan Layanan, Anda menyetujui pengumpulan dan penggunaan informasi sesuai dengan kebijakan ini.",
              style: GoogleFonts.poppins(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: "1. Pengumpulan dan Penggunaan Informasi",
              content:
                  "Kami mengumpulkan beberapa jenis informasi untuk berbagai tujuan guna menyediakan dan meningkatkan Layanan kami kepada Anda.\n\nJenis Data yang Dikumpulkan:\n- Data Identifikasi Pribadi: Nama Lengkap, ID Karyawan, dan Jabatan.\n- Data Lokasi (Geolocation): Koordinat GPS Anda saat Anda melakukan aksi check-in dan check-out.\n- Data Perangkat: FCM Token untuk tujuan pengiriman notifikasi push.",
              titleColor: primaryColor,
            ),
            _buildSection(
              title: "2. Penggunaan Data",
              content:
                  "PT Artugo menggunakan data yang dikumpulkan untuk berbagai tujuan:\n- Untuk menyediakan dan memelihara Layanan.\n- Untuk mengelola dan memverifikasi data kehadiran karyawan.\n- Untuk mengirimkan notifikasi dan komunikasi penting terkait pekerjaan.",
              titleColor: primaryColor,
            ),
            _buildSection(
                title: "3. Keamanan Data",
                content:
                    "Keamanan data Anda penting bagi kami. Kami berusaha untuk menggunakan cara yang dapat diterima secara komersial untuk melindungi Data Pribadi Anda. Namun, harap diingat bahwa tidak ada metode transmisi melalui Internet atau metode penyimpanan elektronik yang 100% aman.",
                titleColor: primaryColor),
            _buildSection(
                title: "4. Penyedia Layanan Pihak Ketiga",
                content:
                    "Kami dapat menggunakan penyedia layanan pihak ketiga untuk memfasilitasi Layanan kami (\"Penyedia Layanan\"), seperti:\n- Google Firebase: Untuk layanan notifikasi push (Firebase Cloud Messaging).\n- OpenStreetMap: Untuk layanan pemetaan dan konversi koordinat menjadi alamat.",
                titleColor: primaryColor),
            _buildSection(
                title: "5. Hubungi Kami",
                content:
                    "Jika Anda memiliki pertanyaan tentang Kebijakan Privasi ini, silakan hubungi Departemen HR.",
                titleColor: primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      {required String title,
      required String content,
      required Color titleColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
