import 'package:flutter/material.dart';

import '../core/audio_manager.dart';
import '../core/storage.dart';

Color lighten(Color c, double f) => Color.lerp(c, Colors.white, f)!;
Color darken(Color c, double f) => Color.lerp(c, Colors.black, f)!;

class OutlinedText extends StatelessWidget {
  final String text;
  final double size;
  final List<Color> gradient;
  final double letterSpacing;
  final Color glow;

  const OutlinedText({
    super.key,
    required this.text,
    required this.size,
    this.gradient = const <Color>[Color(0xFFFFF3B0), Color(0xFFFFB020)],
    this.letterSpacing = 2,
    this.glow = const Color(0xAAFFA726),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            letterSpacing: letterSpacing,
            height: 1.0,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.17
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFF0B1020),
            shadows: <Shadow>[
              Shadow(color: glow, blurRadius: size * 0.35),
              Shadow(color: const Color(0xAA000000), blurRadius: size * 0.1, offset: Offset(0, size * 0.08)),
            ],
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect r) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ).createShader(r),
          child: Text(
            text,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: letterSpacing,
              height: 1.0,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class RealClashLogo extends StatelessWidget {
  final double size;
  const RealClashLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OutlinedText(
          text: 'REAL',
          size: size * 0.62,
          letterSpacing: size * 0.18,
          gradient: const <Color>[Color(0xFFBFF0FF), Color(0xFF2E8BFF)],
          glow: const Color(0xAA3FA9FF),
        ),
        SizedBox(height: size * 0.02),
        OutlinedText(
          text: 'CLASH',
          size: size,
          letterSpacing: size * 0.04,
          gradient: const <Color>[Color(0xFFFFF3B0), Color(0xFFFFA726), Color(0xFFE53935)],
        ),
      ],
    );
  }
}

class GameButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  final double width;
  final double height;
  final IconData? icon;
  final double fontSize;
  final bool enabled;

  const GameButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color = const Color(0xFF2E8BFF),
    this.width = 200,
    this.height = 54,
    this.icon,
    this.fontSize = 20,
    this.enabled = true,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final col = widget.enabled ? widget.color : const Color(0xFF5A5F6B);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        if (widget.enabled) {
          AudioManager.I.sfx('click');
          widget.onTap();
        }
      },
      child: AnimatedScale(
        scale: _down ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[lighten(col, 0.35), col, darken(col, 0.35)],
              stops: const <double>[0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(widget.height * 0.3),
            border: Border.all(color: const Color(0xFF101522), width: 3),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0xAA000000), blurRadius: 8, offset: Offset(0, 5)),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.icon != null) ...<Widget>[
                    Icon(widget.icon, color: Colors.white, size: widget.fontSize * 1.2),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: const <Shadow>[Shadow(color: Color(0xFF000000), blurRadius: 4, offset: Offset(0, 2))],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoundIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 46,
    this.color = const Color(0xFF1E2A4A),
  });

  @override
  State<RoundIconButton> createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<RoundIconButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        AudioManager.I.sfx('click');
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 80),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[lighten(widget.color, 0.3), widget.color, darken(widget.color, 0.3)],
            ),
            border: Border.all(color: const Color(0xFFBFD4FF), width: 2),
            boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x99000000), blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.55),
        ),
      ),
    );
  }
}

class SoundButton extends StatefulWidget {
  final double size;
  const SoundButton({super.key, this.size = 46});

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> {
  @override
  Widget build(BuildContext context) {
    final d = SaveData.instance;
    return RoundIconButton(
      size: widget.size,
      icon: d.muteAll ? Icons.volume_off : Icons.volume_up,
      onTap: () {
        d.muteAll = !d.muteAll;
        AudioManager.I.applyVolume();
        d.save();
        setState(() {});
      },
    );
  }
}

class HoldButton extends StatefulWidget {
  final IconData icon;
  final double size;
  final void Function(bool down) onChange;
  final Color color;

  const HoldButton({
    super.key,
    required this.icon,
    required this.onChange,
    this.size = 76,
    this.color = const Color(0xFF2E8BFF),
  });

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down == v) return;
    setState(() => _down = v);
    widget.onChange(v);
  }

  @override
  void dispose() {
    if (_down) widget.onChange(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.color;
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 1.0,
            colors: _down
                ? <Color>[col, darken(col, 0.45)]
                : <Color>[lighten(col, 0.45), col, darken(col, 0.4)],
          ),
          border: Border.all(color: const Color(0xFF0E1426), width: 3),
          boxShadow: <BoxShadow>[
            BoxShadow(color: const Color(0xAA000000), blurRadius: _down ? 3 : 9, offset: Offset(0, _down ? 2 : 6)),
          ],
        ),
        child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.55),
      ),
    );
  }
}

class CoinPill extends StatelessWidget {
  final int value;
  const CoinPill({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xCC10162A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC94A), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFFFFF3A0), Color(0xFFFFB400)],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xEE1B2748), Color(0xEE0D1428)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF6FA8FF), width: 2.5),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0xCC000000), blurRadius: 20, offset: Offset(0, 10))],
      ),
      child: child,
    );
  }
}

class HeartsRow extends StatelessWidget {
  final int hearts;
  final double size;
  const HeartsRow({super.key, required this.hearts, this.size = 30});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(3, (int i) {
        final on = i < hearts;
        return Padding(
          padding: const EdgeInsets.only(right: 3),
          child: AnimatedScale(
            scale: on ? 1.0 : 0.8,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.favorite,
              size: size,
              color: on ? const Color(0xFFFF3B4A) : const Color(0xFF3A2F3A),
              shadows: const <Shadow>[Shadow(color: Color(0xFF000000), blurRadius: 4, offset: Offset(0, 2))],
            ),
          ),
        );
      }),
    );
  }
}
