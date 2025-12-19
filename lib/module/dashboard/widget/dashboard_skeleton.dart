import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Kerangka untuk UserInfoHeader
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                const CircleAvatar(radius: 26, backgroundColor: Colors.white),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 20, color: Colors.white, margin: const EdgeInsets.only(bottom: 4)),
                    Container(width: 100, height: 16, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          
          // Kerangka untuk TodayAttendanceCard
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          
          // Kerangka untuk Summary Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 36.0, 16.0, 12.0),
            child: Row(
              children: List.generate(3, (index) => Expanded(
                child: Container(
                  height: 80,
                  margin: index != 2 ? const EdgeInsets.only(right: 12) : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )),
            ),
          ),
          
          // Kerangka untuk Chart
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}