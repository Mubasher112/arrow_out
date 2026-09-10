import 'package:flutter/material.dart';
import '../../domain/models/arrow.dart';
import '../../domain/models/arrow_state.dart';
import '../theme/app_theme.dart';
import 'arrow_painter.dart';

class ArrowTileWidget extends StatefulWidget {
  final Arrow? arrow;
  final double tileSize;
  final String? hintArrowId;
  final Function(String arrowId)? onTap;
  final VoidCallback? onExitAnimationComplete;

  const ArrowTileWidget({
    super.key,
    required this.arrow,
    required this.tileSize,
    this.hintArrowId,
    this.onTap,
    this.onExitAnimationComplete,
  });

  @override
  State<ArrowTileWidget> createState() => _ArrowTileWidgetState();
}

class _ArrowTileWidgetState extends State<ArrowTileWidget>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  late AnimationController _exitController;
  late Animation<Offset> _exitAnimation;
  late Animation<double> _fadeAnimation;

  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    // Shake animation for blocked arrows
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 5.0, end: -3.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -3.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    // Exit animation for clear path
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _exitAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.0),
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));

    _exitController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onExitAnimationComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant ArrowTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.arrow != null) {
      // Trigger blocked shake
      if (widget.arrow!.state == ArrowState.blocked &&
          oldWidget.arrow?.state != ArrowState.blocked) {
        _shakeController.forward(from: 0.0);
      }

      // Update exit vector offset based on direction
      if (widget.arrow!.state == ArrowState.animatingExit && !_isExiting) {
        _isExiting = true;
        final dRow = widget.arrow!.direction.dRow.toDouble();
        final dCol = widget.arrow!.direction.dCol.toDouble();

        _exitAnimation = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(dCol * 3.5, dRow * 3.5),
        ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic));

        _exitController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arrow = widget.arrow;

    if (arrow == null || arrow.state == ArrowState.removed) {
      return Container(
        width: widget.tileSize,
        height: widget.tileSize,
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: AppTheme.tileBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.tileBorder, width: 1.5),
        ),
      );
    }

    final semanticLabel =
        'Arrow pointing ${arrow.direction.name}, row ${arrow.row + 1}, column ${arrow.column + 1}';

    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: arrow.state != ArrowState.animatingExit,
      child: Container(
        width: widget.tileSize,
        height: widget.tileSize,
        margin: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: AppTheme.tileBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.tileBorder, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: Listenable.merge([_shakeController, _exitController]),
          builder: (context, child) {
            final shakeVal = _shakeAnimation.value;
            final isHint = widget.hintArrowId == arrow.id;

            return Transform.translate(
              offset: Offset(shakeVal, 0) +
                  Offset(
                    _exitAnimation.value.dx * widget.tileSize,
                    _exitAnimation.value.dy * widget.tileSize,
                  ),
              child: Opacity(
                opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                child: GestureDetector(
                  onTap: () {
                    if (arrow.state != ArrowState.animatingExit) {
                      widget.onTap?.call(arrow.id);
                    }
                  },
                  child: CustomPaint(
                    size: Size(widget.tileSize, widget.tileSize),
                    painter: ArrowPainter(
                      direction: arrow.direction,
                      state: arrow.state,
                      isHighlighted: isHint,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
