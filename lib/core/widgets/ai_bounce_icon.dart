import 'package:flutter/material.dart';

/// Ainya ya Kodisha AI ikiruka juu na chini kwa kimo kidogo
/// (small up-and-down bounce animation).
class AiBounceIcon extends StatefulWidget {
  const AiBounceIcon({
    super.key,
    this.size = 28,
    this.bounceHeight = 4,
    this.duration = const Duration(milliseconds: 1100),
  });

  /// Ukubwa wa picha.
  final double size;

  /// Kimo kidogo cha kuruka (default 4px).
  final double bounceHeight;

  /// Muda wa mzunguko mmoja wa kuruka.
  final Duration duration;

  @override
  State<AiBounceIcon> createState() => _AiBounceIconState();
}

class _AiBounceIconState extends State<AiBounceIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _offset = Tween<double>(begin: 0, end: -widget.bounceHeight).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    final cacheSize = (widget.size * devicePixelRatio).round();

    return Semantics(
      label: 'Kodisha AI',
      image: true,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _offset.value),
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/ai.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
