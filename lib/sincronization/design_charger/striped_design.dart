import 'package:flutter/material.dart';

class StripedContainer extends StatefulWidget {
  final double syncPercentages;

  const StripedContainer({super.key, required this.syncPercentages});

  @override
  State<StripedContainer> createState() => _StripedContainerState();
}

class _StripedContainerState extends State<StripedContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Controlador para animar el movimiento de las rayas
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isComplete = widget.syncPercentages >= 100;

    return Container(
      // 1. Definimos un ancho fijo o máximo para dibujar la "pista" de fondo
      width: 200, 
      height: 30, // Altura más estilizada
      decoration: BoxDecoration(
        color: Colors.grey[300], // Color de fondo (track)
        borderRadius: BorderRadius.circular(15), // Bordes redondeados
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CustomPaint(
          painter: StripedPainter(
            isComplete: isComplete,
            percentage: widget.syncPercentages,
            animationValue: _controller,
          ),
        ),
      ),
    );
  }
}

class StripedPainter extends CustomPainter {
  final bool isComplete;
  final double percentage;
  final Animation<double> animationValue;

  StripedPainter({
    required this.isComplete,
    required this.percentage,
    required this.animationValue,
  }) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double fillWidth = (size.width * (percentage / 100)).clamp(0.0, size.width);

    Paint paint = Paint()
      ..style = PaintingStyle.fill;

    // Si está completo, dibujamos la barra sólida suavemente
    if (isComplete) {
      paint.color = const Color(0XFF7531FF);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      return;
    }

    paint.color = const Color(0XFF7531FF).withOpacity(0.3); // Base morada clara
    canvas.drawRect(Rect.fromLTWH(0, 0, fillWidth, size.height), paint);


    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, fillWidth, size.height));

    paint.color = const Color(0XFF7531FF).withOpacity(0.6); // Rayas más oscuras
    
    double stripeWidth = 10;
    double gap = 10;
    double totalPatternWidth = stripeWidth + gap;
    
    double shift = animationValue.value * totalPatternWidth;

    for (double i = -totalPatternWidth; i < fillWidth + totalPatternWidth; i += totalPatternWidth) {
      double x = i + shift;
      
      Path path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth - 8, size.height) // Inclinación diagonal (skew)
        ..lineTo(x - 8, size.height)
        ..close();

      canvas.drawPath(path, paint);
    }
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StripedPainter oldDelegate) {
    return oldDelegate.percentage != percentage || 
           oldDelegate.isComplete != isComplete ||
           oldDelegate.animationValue != animationValue;
  }
}

class SyncStatusCard extends StatelessWidget {
  final String title;
  final double percentage;
  final IconData icon;
  final Color primaryColor;

  const SyncStatusCard({
    super.key,
    required this.title,
    required this.percentage,
    this.icon = Icons.sync,
    this.primaryColor = const Color(0XFF7531FF),
  });

  @override
  Widget build(BuildContext context) {
    final double safePercentage = percentage.clamp(0.0, 100.0);
    final bool isComplete = safePercentage >= 100;
    final double progressValue = safePercentage / 100;

    return Container(
      width: 160,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5), // Padding ajustado
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.elasticOut, 
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isComplete
                    ? const Icon(
                        Icons.check_circle,
                        key: ValueKey('done'), // Importante: Clave única para el estado final
                        size: 18,
                        color: Colors.green,
                      )
                    : Icon(
                        icon,
                        key: const ValueKey('loading'), // Importante: Clave única para cargando
                        size: 18,
                        color: Colors.grey[500],
                      ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: progressValue,
                  strokeWidth: 6,
                  backgroundColor: const Color(0xFFF0EBFC),
                  color: isComplete ? Colors.green : primaryColor,
                  strokeCap: StrokeCap.round,
                ),
              ),
              
              // Texto en el centro (También animado)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Text(
                      '${safePercentage.toInt()}%',
                      // Usamos keys para que Flutter sepa que el texto cambió y debe animar
                      key: ValueKey<int>(safePercentage.toInt()), 
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isComplete ? Colors.green : primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}