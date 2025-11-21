import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsView extends StatelessWidget {
  const TermsView({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('terms_title'.tr),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'terms_effective_date'.tr,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'terms_intro'.tr,
              style: GoogleFonts.poppins(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'terms_sec1_title'.tr,
              content: 'terms_sec1_content'.tr,
              titleColor: primaryColor,
            ),
            _buildSection(
              title: 'terms_sec2_title'.tr,
              content: 'terms_sec2_content'.tr,
              titleColor: primaryColor,
            ),
            _buildSection(
                title: 'terms_sec3_title'.tr,
                content: 'terms_sec3_content'.tr,
                titleColor: primaryColor),
            _buildSection(
                title: 'terms_sec4_title'.tr,
                content: 'terms_sec4_content'.tr,
                titleColor: primaryColor),
            _buildSection(
                title: 'terms_sec5_title'.tr,
                content: 'terms_sec5_content'.tr,
                titleColor: primaryColor),
            _buildSection(
                title: 'terms_sec6_title'.tr,
                content: 'terms_sec6_content'.tr,
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
