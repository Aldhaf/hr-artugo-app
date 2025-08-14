// lib/module/dashboard/widget/interactive_swipe_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InteractiveSwipeButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onSwipe;

  const InteractiveSwipeButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onSwipe,
  });

  @override
  State<InteractiveSwipeButton> createState() => _InteractiveSwipeButtonState();
}

class _InteractiveSwipeButtonState extends State<InteractiveSwipeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragPosition = 0;
  bool _isSwiping = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: widget.backgroundColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonWidth = constraints.maxWidth;
          final sliderWidth = 52.0;
          final maxDrag = buttonWidth - sliderWidth - 8;

          return Stack(
            alignment: Alignment.center,
            children: [
              // Latar belakang progresif
              Positioned(
                left: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 50),
                  width: 4 + _dragPosition + sliderWidth,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              // Teks
              AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: 1 - (_dragPosition / maxDrag * 0.8),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.foregroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Slider yang bisa digeser
              Positioned(
                left: 4 + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragStart: (_) {
                    setState(() => _isSwiping = true);
                  },
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (_) async {
                    if (_dragPosition > maxDrag * 0.7) {
                      HapticFeedback.lightImpact();
                      widget.onSwipe();
                    }
                    setState(() {
                      _dragPosition = 0;
                      _isSwiping = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: _isSwiping ? 0 : 300),
                    curve: Curves.easeOut,
                    width: sliderWidth,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Center(
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0)
                            .animate(_animationController),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: widget.backgroundColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
