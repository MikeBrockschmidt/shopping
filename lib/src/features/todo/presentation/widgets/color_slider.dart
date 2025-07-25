import 'package:flutter/material.dart';

class ColorSlider extends StatefulWidget {
  final void Function(Color) onColorSelected;

  final Color? initialColor;
  final double height;
  final ShapeBorder? shape;
  final List<Color>? gradientColors;
  final bool showColorPreview;
  final double colorPreviewSize;
  final ColorPreviewPosition colorPreviewPosition;

  const ColorSlider({
    super.key,
    required this.onColorSelected,
    this.initialColor,
    this.height = 8.0,
    this.shape,
    this.gradientColors,
    this.showColorPreview = false,
    this.colorPreviewSize = 30.0,
    this.colorPreviewPosition = ColorPreviewPosition.end,
  });

  @override
  State<ColorSlider> createState() => _ColorSliderState();
}

enum ColorPreviewPosition { start, end }

class _ColorSliderState extends State<ColorSlider> {
  late double _hue;
  static const List<Color> _defaultColors = [
    Color(0xFFFF0000),
    Color(0xFFFFFF00),
    Color(0xFF00FF00),
    Color(0xFF00FFFF),
    Color(0xFF0000FF),
    Color(0xFFFF00FF),
    Color(0xFFFF0000),
  ];

  @override
  void initState() {
    super.initState();
    _hue = widget.initialColor != null
        ? HSVColor.fromColor(widget.initialColor!).hue
        : 0.0;
  }

  @override
  void didUpdateWidget(ColorSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialColor != oldWidget.initialColor &&
        widget.initialColor != null) {
      _hue = HSVColor.fromColor(widget.initialColor!).hue;
    }
  }

  void _updateHue(double value) {
    setState(() {
      _hue = value;
    });
    final selectedColor = HSVColor.fromAHSV(1, _hue, 1, 1).toColor();
    widget.onColorSelected(selectedColor);
  }

  Color get _selectedColor => HSVColor.fromAHSV(1, _hue, 1, 1).toColor();

  @override
  Widget build(BuildContext context) {
    return widget.showColorPreview ? _buildWithColorPreview() : _buildSlider();
  }

  Widget _buildWithColorPreview() {
    final previewBox = Container(
      width: widget.colorPreviewSize,
      height: widget.colorPreviewSize,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: _selectedColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .5),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Row(
      children: [
        if (widget.colorPreviewPosition == ColorPreviewPosition.start)
          previewBox,
        Expanded(child: _buildSlider()),
        if (widget.colorPreviewPosition == ColorPreviewPosition.end) previewBox,
      ],
    );
  }

  Widget _buildSlider() {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          height: widget.height,
          decoration: ShapeDecoration(
            shape:
                widget.shape ??
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            gradient: LinearGradient(
              colors: widget.gradientColors ?? _defaultColors,
            ),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 0,
            thumbShape: OutlinedThumbShape(
              borderRadius: 4,
              thumbWidth: 6.0,
              sliderHeight: widget.height + 4,
              borderWidth: 1,
              borderColor: Theme.of(context).colorScheme.onSurface,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
            thumbColor: _selectedColor,
            overlayColor: Colors.transparent,
            inactiveTrackColor: Colors.transparent,
            activeTrackColor: Colors.transparent,
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 0,
            ),
          ),
          child: Slider(value: _hue, min: 0, max: 360, onChanged: _updateHue),
        ),
      ],
    );
  }
}

class OutlinedThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final double sliderHeight;
  final double borderWidth;
  final Color borderColor;
  final double borderRadius;

  const OutlinedThumbShape({
    this.thumbWidth = 4.0,
    this.sliderHeight = 20.0,
    this.borderWidth = 1.5,
    this.borderColor = Colors.white,
    this.borderRadius = 0.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(
      thumbWidth + (borderWidth * 2),
      sliderHeight * 2 + (borderWidth * 2),
    );
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final double lineHeight = sliderHeight * 2;
    final Rect rect = Rect.fromCenter(
      center: center,
      width: thumbWidth,
      height: lineHeight,
    );

    if (borderRadius > 0) {
      final RRect rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(borderRadius),
      );

      canvas.drawRRect(rrect, fillPaint);
      canvas.drawRRect(rrect, outlinePaint);
    } else {
      canvas.drawRect(rect, fillPaint);
      canvas.drawRect(rect, outlinePaint);
    }
  }
}
