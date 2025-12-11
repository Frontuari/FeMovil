import 'package:flutter/material.dart';
//Ejemplo de Mostrar un mensaje de error
//WarningMessages.showWarningMessagesDialog(context, 'Este es un mensaje de advertencia.');
//El context es el context de la vista en la que te encuentras actualmente

class ErrorMessage {
  static Future<void> showErrorMessageDialog(BuildContext context, String message, {bool goBack = false}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo al tocar fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'Poppins Bold',
              color: Colors.red, // Color de advertencia
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins Regular',
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // Centra el botón
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo

                   if (goBack) {
                  Navigator.of(context).pop(); // Regresa a la pantalla anterior solo si goBack es true
                }
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  fontFamily: 'Poppins Bold',
                  color: Colors.red, // Color del botón
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SuccesMessages {
  static Future<void> showSuccesMessagesDialog(BuildContext context, String message, {bool goBack = false}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo al tocar fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Exitoso',
            style: TextStyle(
              fontFamily: 'Poppins Bold',
              color: Colors.green, // Color de advertencia
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins Regular',
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // Centra el botón
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                if (goBack) {
                  Navigator.of(context).pop(); 
                }
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  fontFamily: 'Poppins Bold',
                  color: Colors.green, // Color del botón
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class WarningMessages {
  static Future<void> showWarningMessagesDialog(BuildContext context, String message,{bool goBack = false}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo al tocar fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Advertencia',
            style: TextStyle(
              fontFamily: 'Poppins Bold',
              color: Colors.yellow, // Color de advertencia
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins Regular',
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // Centra el botón
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo

                  if (goBack) {
                  Navigator.of(context).pop(); // Regresa a la pantalla anterior solo si goBack es true
                }
              },
              
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  fontFamily: 'Poppins Bold',
                  color: Colors.yellow, // Color del botón
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

void showLoadingDialog(BuildContext context, {String message = "Cargando..."}) {
  showDialog(
    context: context,
    barrierDismissible: false, // Evita que se cierre tocando fuera
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      );
    },
  );
}


Future<bool?> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmText = "Aceptar",
  String cancelText = "Cancelar",
  Color confirmColor = Colors.blue,
  Color cancelColor = Colors.grey,
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Esquinas redondeadas
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Devuelve false al cancelar
            },
            style: TextButton.styleFrom(foregroundColor: cancelColor),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Devuelve true al aceptar
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}


class ErrorMessageList {
  static Future<void> showErrorMessageDialog(BuildContext context, String message, {bool goBack = false, List<Map<String, dynamic>>? productsNotUpdated}) async {
    // Si la lista de productos no es nula, la formateamos
    String productListText = '';
   if (productsNotUpdated != null && productsNotUpdated.isNotEmpty) {
          productListText = ''; // Reiniciamos el texto

          // Iteramos sobre la lista de productos
          for (var product in productsNotUpdated) {
            // Asignamos el nombre como el título principal seguido de un salto de línea
            productListText += '${product['name']}\n'; // Nombre como título
            // Añadimos el precio con un salto de línea
            productListText += 'Precio Mínimo: \$${product['Precio_Minimo']}\n\n'; // Precio del producto
          }
        }
    // Agregar el texto de productos al mensaje
    String fullMessage = message + productListText;
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // Evita cerrar el diálogo al tocar fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Error',
            style: TextStyle(
              fontFamily: 'Poppins Bold',
              color: Colors.red, // Color de error
            ),
          ),
          content: Text(
            fullMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins Regular',
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // Centra el botón
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                if (goBack) {
                  Navigator.of(context).pop(); // Hace pop hacia atrás
                }
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  fontFamily: 'Poppins Bold',
                  color: Colors.red, // Color del botón de error
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}