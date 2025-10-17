import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
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
              "Harap baca Syarat dan Ketentuan Layanan (\"Ketentuan\") ini dengan saksama sebelum menggunakan aplikasi ArtuGo (\"Layanan\") yang dioperasikan oleh PT Artugo (\"Kami\").\n\nAkses Anda ke dan penggunaan Layanan ini mengkondisikan penerimaan dan kepatuhan Anda terhadap Ketentuan ini. Ketentuan ini berlaku untuk semua karyawan, pengguna, dan pihak lain yang mengakses atau menggunakan Layanan.\n\nDengan mengakses atau menggunakan Layanan, Anda setuju untuk terikat oleh Ketentuan ini. Jika Anda tidak setuju dengan bagian mana pun dari ketentuan ini, maka Anda tidak dapat mengakses Layanan.",
              style: GoogleFonts.poppins(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: "1. Deskripsi Layanan",
              content:
                  "ArtuGo adalah aplikasi Sistem Informasi Sumber Daya Manusia (HRIS) internal yang dirancang untuk memfasilitasi dan menyederhanakan proses administrasi karyawan, termasuk namun tidak terbatas pada:\n- Pencatatan kehadiran (check-in dan check-out).\n- Manajemen pengajuan cuti (time off).\n- Melihat riwayat absensi.\n- Menerima notifikasi dan pengumuman internal perusahaan.",
              titleColor: primaryColor,
            ),
            
            _buildSection(
              title: "2. Akun Pengguna",
              content:
                  "Untuk menggunakan Layanan, Anda akan diberikan akun pengguna yang terintegrasi dengan sistem HR pusat (Odoo). Anda bertanggung jawab untuk menjaga kerahasiaan informasi akun Anda, termasuk kata sandi. Anda setuju untuk menerima tanggung jawab penuh atas semua aktivitas yang terjadi di bawah akun Anda.",
              titleColor: primaryColor,
            ),
            
            _buildSection(
              title: "3. Kewajiban Pengguna",
              content: "Sebagai pengguna Layanan, Anda setuju untuk:\n- Memberikan informasi yang akurat, terkini, dan lengkap setiap saat.\n- Menggunakan fitur pencatatan kehadiran (check-in/check-out) hanya pada lokasi dan waktu kerja yang telah ditentukan.\n- Tidak menyalahgunakan Layanan untuk tujuan penipuan atau aktivitas ilegal lainnya.\n- Tidak mencoba merekayasa, memodifikasi, atau mengakses data yang bukan hak Anda.",
              titleColor: primaryColor
            ),
            
            _buildSection(
              title: "4. Penghentian Akses",
              content: "Kami dapat menghentikan atau menangguhkan akses Anda ke Layanan kami dengan segera, tanpa pemberitahuan atau kewajiban sebelumnya, untuk alasan apa pun, termasuk namun tidak terbatas pada pelanggaran Ketentuan ini.",
              titleColor: primaryColor
            ),
            
            _buildSection(
              title: "5. Hukum yang Berlaku",
              content: "Ketentuan ini akan diatur dan ditafsirkan sesuai dengan hukum yang berlaku di Republik Indonesia.",
              titleColor: primaryColor
            ),
            
            _buildSection(
              title: "6. Hubungi Kami",
              content: "Jika Anda memiliki pertanyaan tentang Ketentuan ini, silakan hubungi Departemen HR.",
              titleColor: primaryColor
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content, required Color titleColor}) {
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