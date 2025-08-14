// File: lib/module/dashboard/widget/animated_checkin_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Enum untuk merepresentasikan semua kemungkinan state dari tombol
enum ButtonState { idle, loading, success, error }

class AnimatedCheckinButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  // Callback ini harus mengembalikan Future, agar kita bisa tahu kapan prosesnya selesai.
  final Future<void> Function() onPressed;

  const AnimatedCheckinButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<AnimatedCheckinButton> createState() => _AnimatedCheckinButtonState();
}

class _AnimatedCheckinButtonState extends State<AnimatedCheckinButton> {
  // State internal untuk mengontrol tampilan tombol
  ButtonState _state = ButtonState.idle;

  // Method yang akan dieksekusi saat tombol ditekan
  void _handlePress() async {
    // Jangan lakukan apa-apa jika sedang dalam proses loading
    if (_state == ButtonState.loading) return;

    // Ubah state menjadi loading
    setState(() {
      _state = ButtonState.loading;
    });

    try {
      // Tunggu hingga proses onPressed selesai
      await widget.onPressed();
      // Jika berhasil, ubah state menjadi success
      setState(() {
        _state = ButtonState.success;
      });
    } catch (e) {
      // Jika gagal, ubah state menjadi error
      setState(() {
        _state = ButtonState.error;
      });
    }

    // Setelah 2 detik (baik sukses atau gagal), kembalikan tombol ke state idle
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _state = ButtonState.idle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan lebar tombol berdasarkan state
    final double width =
        _state == ButtonState.idle ? MediaQuery.of(context).size.width : 60.0;

    // Tentukan warna tombol berdasarkan state
    Color buttonColor() {
      switch (_state) {
        case ButtonState.success:
          return Colors.green.shade600;
        case ButtonState.error:
          return Colors.red.shade600;
        default:
          return widget.color;
      }
    }

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        height: 60,
        child: ElevatedButton(
          onPressed: _handlePress,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor(),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(0),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: _buildButtonChild(),
          ),
        ),
      ) // Penutup AnimatedContainer
          // Rantai animasi ditempelkan langsung ke widget yang ingin dianimasikan
          .animate(target: _state == ButtonState.error ? 1 : 0)
          .shake(hz: 8, duration: 400.ms, curve: Curves.easeInOut),
    ); //
  }

  // Helper method untuk menentukan widget apa yang ditampilkan di dalam tombol
  Widget _buildButtonChild() {
    switch (_state) {
      case ButtonState.loading:
        return const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        );
      case ButtonState.success:
        return const Icon(Icons.check_rounded, color: Colors.white, size: 30);
      case ButtonState.error:
        return const Icon(Icons.close_rounded, color: Colors.white, size: 30);
      case ButtonState.idle:
      default:
        // Cukup bungkus Row dengan FittedBox
        return FittedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
    }
  }
}
