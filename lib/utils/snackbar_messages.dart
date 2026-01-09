import 'package:flutter/material.dart';

void showErrorSnackbar(BuildContext context, String message) {
  // Mostrar el Snackbar de advertencia
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white, // Texto blanco
          fontSize: 16,
        ),
      ),
      backgroundColor: Colors.red, // Color de fondo rojo
      duration: Duration(seconds: 3), // Duración de la visualización
      behavior: SnackBarBehavior.floating, // El snackbar flota encima
      margin: EdgeInsets.all(16), // Espaciado desde los bordes
    ),
  );
}

void showSuccesSnackbar(BuildContext context, String message) {
  // Mostrar el Snackbar de advertencia
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.white, // Texto blanco
          fontSize: 16,
        ),
      ),
      backgroundColor: Colors.green, // Color de fondo rojo
      duration: Duration(seconds: 3), // Duración de la visualización
      behavior: SnackBarBehavior.floating, // El snackbar flota encima
      margin: EdgeInsets.all(16), // Espaciado desde los bordes
    ),
  );
}



void showWarningSnackbar(BuildContext context, String message) {
  // Mostrar el Snackbar de advertencia
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: Colors.black, // Texto blanco
          fontSize: 16,
        ),
      ),
      backgroundColor: Colors.amber, // Color de fondo rojo
      duration: Duration(seconds: 2), // Duración de la visualización
      behavior: SnackBarBehavior.floating, // El snackbar flota encima
      margin: EdgeInsets.all(16), // Espaciado desde los bordes
    ),
  );
}
void showWarningSnackbarDisplace(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold, 
        ),
      ),
      backgroundColor: Colors.amber,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.fixed, 
      
    ),
  );
}

void showWarningSnackbarTop(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.black),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}