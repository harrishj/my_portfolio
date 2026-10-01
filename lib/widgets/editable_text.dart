import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

class EditableTextWidget extends ConsumerStatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Function(String) onSave;

  const EditableTextWidget({
    super.key,
    required this.text,
    required this.onSave,
    this.style,
    this.textAlign,
  });

  @override
  ConsumerState<EditableTextWidget> createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends ConsumerState<EditableTextWidget> {
  bool _isEditing = false;
  bool _isHovered = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant EditableTextWidget oldWidget) {
    if (oldWidget.text != widget.text && !_isEditing) {
      _controller.text = widget.text;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    if (!isAdmin) {
      return Text(widget.text, style: widget.style, textAlign: widget.textAlign);
    }

    if (_isEditing) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 140, maxWidth: 640),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: AppColors.amber, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: _controller,
                  style: widget.style ?? GoogleFonts.interTight(color: Colors.white),
                  maxLines: null,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  setState(() => _isEditing = false);
                  widget.onSave(_controller.text);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: const Text(
                    'SAVE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  setState(() {
                    _isEditing = false;
                    _controller.text = widget.text;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 14, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _isEditing = true),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: _isHovered ? AppColors.amber : AppColors.amber.withValues(alpha: 0.35),
            strokeWidth: 1,
            gap: 4,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  widget.text.isEmpty ? 'Empty Field' : widget.text,
                  style: widget.style,
                  textAlign: widget.textAlign,
                ),
              ),
              if (_isHovered)
                Positioned(
                  top: -9,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.amber,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'EDIT',
                      style: GoogleFonts.interTight(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final length = draw ? gap : gap;
        if (draw) {
          final extract = metric.extractPath(distance, distance + length);
          canvas.drawPath(extract, paint);
        }
        distance += length;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
