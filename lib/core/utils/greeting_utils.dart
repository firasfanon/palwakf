import 'package:flutter/material.dart';

class GreetingUtils {
  /// Get Arabic greeting based on current time
  static String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'صباح الخير';
    } else if (hour >= 12 && hour < 17) {
      return 'مساء الخير';
    } else if (hour >= 17 && hour < 21) {
      return 'مساء الخير';
    } else {
      return 'مساء الخير'; // Late night
    }
  }

  /// Get English greeting based on current time
  static String getGreetingEn() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  /// Get greeting icon based on time
  static IconData getGreetingIcon() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny; // Morning
    } else if (hour >= 12 && hour < 17) {
      return Icons.wb_sunny_outlined; // Afternoon
    } else if (hour >= 17 && hour < 21) {
      return Icons.wb_twilight; // Evening
    } else {
      return Icons.nightlight_round; // Night
    }
  }

  /// Get greeting color based on time
  static Color getGreetingColor() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return const Color(0xFFFFA726); // Orange for morning
    } else if (hour >= 12 && hour < 17) {
      return const Color(0xFFFFD54F); // Yellow for afternoon
    } else if (hour >= 17 && hour < 21) {
      return const Color(0xFFFF7043); // Deep orange for evening
    } else {
      return const Color(0xFF5C6BC0); // Indigo for night
    }
  }
}