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
      backgroundColor: Colors.yellow, // Color de fondo rojo
      duration: Duration(seconds: 3), // Duración de la visualización
      behavior: SnackBarBehavior.floating, // El snackbar flota encima
      margin: EdgeInsets.all(16), // Espaciado desde los bordes
    ),
  );
}