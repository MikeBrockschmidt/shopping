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
  late int _colorIndex;
  static const List<Color> _defaultColors = [
    Color(0xFFFF0000), // Rot
    Color(0xFFFF6B6B), // Hellrot
    Color(0xFF8B0000), // Dunkelrot
    Color(0xFFFF8C00), // Orange
    Color(0xFFFFD700), // Gold
    Color(0xFFFFFF00), // Gelb
    Color(0xFFFFF44F), // Hellgelb
    Color(0xFF9ACD32), // Gelbgrün
    Color(0xFF00FF00), // Grün
    Color(0xFF32CD32), // Limonengrün
    Color(0xFF006400), // Dunkelgrün
    Color(0xFF00CED1), // Türkis
    Color(0xFF00FFFF), // Cyan
    Color(0xFF87CEEB), // Himmelblau
    Color(0xFF0000FF), // Blau
    Color(0xFF4169E1), // Königsblau
    Color(0xFF000080), // Dunkelblau
    Color(0xFF8A2BE2), // Blauviolett
    Color(0xFFFF00FF), // Magenta
    Color(0xFFFF69B4), // Helles Pink
    Color(0xFFFFB6C1), // Zartes Pink
    Color(0xFFFFC0CB), // Helles zartes Pink
    Color(0xFFDB7093), // Mittleres Violettrot
    Color(0xFFC71585), // Dunkles Violettrot
    Color(0xFFFF1493), // Tiefes Pink
    Color(0xFFDA70D6), // Zartes Orchidee
    Color(0xFFEE82EE), // Veilchen
    Color(0xFFDDA0DD), // Pflaume
    Color(0xFFD8BFD8), // Distel
    Color(0xFFE6D8F0), // Zartes Lila-Pink
    Color(0xFFF0E6F0), // Sehr zartes Lila
    Color(0xFF800080), // Lila
    Color(0xFF4B0082), // Indigo
    Color(0xFFA52A2A), // Braun
    Color(0xFFD2B48C), // Tan
    Color(0xFF808080), // Grau
    Color(0xFFC0C0C0), // Silber
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialColor != null) {
      _colorIndex = _findClosestColorIndex(widget.initialColor!);
    } else {
      _colorIndex = 0;
    }
  }

  @override
  void didUpdateWidget(ColorSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialColor != oldWidget.initialColor &&
        widget.initialColor != null) {
      _colorIndex = _findClosestColorIndex(widget.initialColor!);
    }
  }

  int _findClosestColorIndex(Color color) {
    int closestIndex = 0;
    double minDistance = double.infinity;
    
    for (int i = 0; i < _defaultColors.length; i++) {
      final distance = _colorDistance(color, _defaultColors[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }
    
    return closestIndex;
  }

  double _colorDistance(Color c1, Color c2) {
    final r = (c1.red - c2.red).toDouble();
    final g = (c1.green - c2.green).toDouble();
    final b = (c1.blue - c2.blue).toDouble();
    final a = (c1.alpha - c2.alpha).toDouble();
    return (r * r + g * g + b * b + a * a).toDouble();
  }

  void _updateColor(double value) {
    final newIndex = value.round();
    if (newIndex != _colorIndex) {
      setState(() {
        _colorIndex = newIndex;
      });
      widget.onColorSelected(_defaultColors[_colorIndex]);
    }
  }

  Color get _selectedColor => _defaultColors[_colorIndex];

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
              colors: _defaultColors,
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
          child: Slider(
            value: _colorIndex.toDouble(),
            min: 0,
            max: (_defaultColors.length - 1).toDouble(),
            divisions: _defaultColors.length - 1,
            onChanged: _updateColor,
          ),
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
