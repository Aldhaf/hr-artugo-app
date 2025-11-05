// lib/module/onboarding/view/onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controller/onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white, // Latar belakang utama
        body: SizedBox.expand(
          child: Stack(
            children: [
              // LAPISAN 1: GAMBAR LATAR BELAKANG YANG BISA DIGESER
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: controller.pages.length,
                itemBuilder: (context, index) {
                  return Container(
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      controller.pages[index]["image"]!,
                      // Tingkatkan tinggi sedikit agar lebih fleksibel di berbagai layar
                      height: MediaQuery.of(context).size.height * 0.8,
                      width: double.infinity,
                      fit: BoxFit
                          .cover, // BoxFit.cover akan memotong "ruang bernapas"
                    ),
                  );
                },
              ),

              // LAPISAN 2: PANEL KONTEN PUTIH DI BAGIAN BAWAH
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height *
                      0.45, // Panel mengisi 45% layar bawah
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 30.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Obx(
                    () => Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // KONTEN TEKS
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            // INDIKATOR HALAMAN
                            SmoothPageIndicator(
                              controller: controller.pageController,
                              count: controller.pages.length,
                              effect: WormEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                spacing: 12,
                                activeDotColor: primaryColor,
                                dotColor: Colors.grey.shade300,
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Judul yang berubah sesuai halaman
                            Text(
                              controller
                                      .pages[controller.currentPageIndex.value]
                                  ["title"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26, // Ukuran font lebih besar
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Deskripsi yang berubah sesuai halaman
                            Text(
                              controller
                                      .pages[controller.currentPageIndex.value]
                                  ["description"]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),

                        // KONTEN NAVIGASI (INDIKATOR & TOMBOL)
                        SizedBox(
                          width: double.infinity, // Tombol selebar layar
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0, // Menghilangkan bayangan bawaan
                            ),
                            onPressed: controller.nextPage,
                            child: Text(
                              controller.currentPageIndex.value ==
                                      controller.pages.length - 1
                                  ? "Mulai"
                                  : "Lanjut",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
