import 'package:flutter/material.dart';

class ScheduleTabBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const ScheduleTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        height: 39,
        decoration: BoxDecoration(
          color: const Color(0xffF8F9FE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTabButton("스케줄 신청", 0),
            const SizedBox(width: 10),
            _buildTabButton("스케줄 확정", 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        width: 120,
        height: 31,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xffF8F9FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color:
                  isSelected
                      ? const Color(0xff1F2024)
                      : const Color(0xff71727A),
            ),
          ),
        ),
      ),
    );
  }
}
