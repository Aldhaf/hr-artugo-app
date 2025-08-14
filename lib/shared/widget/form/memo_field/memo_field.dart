import 'package:flutter/material.dart';

class QMemoField extends StatefulWidget {
  final String label;
  final String? value;
  final String? hint;
  final String? helper;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;
  final Function(String) onChanged;

  const QMemoField({
    Key? key,
    required this.label,
    this.value,
    this.validator,
    this.hint,
    this.helper,
    required this.onChanged,
    this.maxLength,
    this.maxLines,
  }) : super(key: key);

  @override
  State<QMemoField> createState() => _QMemoFieldState();
}

class _QMemoFieldState extends State<QMemoField> {
  FocusNode focusNode = FocusNode();
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        // PERBAIKAN: Pindahkan logika auto-scroll ke dalam listener
        // untuk memastikan dieksekusi pada waktu yang tepat.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Tambahkan pemeriksaan null yang aman di sini
          if (key.currentContext != null) {
            Scrollable.ensureVisible(
              key.currentContext!,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
              duration: const Duration(milliseconds: 300),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hapus logika auto-scroll dari build method untuk mencegah panggilan berulang
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12.0,
      ),
      child: TextFormField(
        key: key,
        initialValue: widget.value,
        focusNode: focusNode,
        validator: widget.validator,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines ?? 6,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: const Icon(
            Icons.text_format,
          ),
          helperText: widget.helper,
          hintText: widget.hint,
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}