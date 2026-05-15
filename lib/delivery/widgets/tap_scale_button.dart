import 'package:flutter/material.dart';

class TapScaleButton extends StatefulWidget {
  final Color color;
  final Color? disabledColor;
  final Widget child;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;

  const TapScaleButton({
    super.key,
    required this.color,
    required this.child,
    this.onPressed,
    this.disabledColor,
    this.height = 56,
    this.borderRadius = 16,
  });

  @override
  State<TapScaleButton> createState() => _TapScaleButtonState();
}

class _TapScaleButtonState extends State<TapScaleButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled
          ? (_) {
              setState(() => _pressed = false);
              widget.onPressed!();
            }
          : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      child: AnimatedScale(
        scale: (_pressed && _enabled) ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: _enabled
                ? widget.color
                : (widget.disabledColor ?? widget.color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
