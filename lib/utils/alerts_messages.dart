import 'package:femovil/presentation/clients/clients_details.dart';
import 'package:femovil/presentation/clients/clients_screen.dart';
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


class SuccessClientModalGeneric {
  static Future<void> show(
    BuildContext context,
     {
    bool goBack = false,
    String? title,
   String? messsage,
    bool stayButton = false,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // ancho máximo del dialog (ajustable)
        final double dialogWidth = MediaQuery.of(context).size.width * 0.82; // 82% de la pantalla
        final double maxDialogWidth = 400; // no crecer demasiado en pantallas grandes

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title?.isNotEmpty == true ? title! : 'Registro Enviado de Manera Exitosa',
            style: const TextStyle(
              fontFamily: 'Poppins Bold',
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 280,
              maxWidth: dialogWidth.clamp(0, maxDialogWidth),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                     Text(
                  messsage?.isNotEmpty == true ? messsage! : 'Orden Generadar\n¿Qué desea realizar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins Regular'),
                ),
                const SizedBox(height: 20),

                if (stayButton)
                  _buildFullWidthButton(
                    label: 'Permanecer en la ventana',
                    icon: Icons.hourglass_empty,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                _buildFullWidthButton(
                  label: 'Regresar',
                  icon: Icons.arrow_back,
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (goBack) Navigator.pop(context);
                  },
                ),
                _buildFullWidthButton(
                  label: 'Menú Principal',
                  icon: Icons.home,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildFullWidthButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class WarningClientModalGeneric {
  static Future<void> show(
    BuildContext context,
    {
    bool goBack = false,
    String? title,
    String? messsage,
    bool stayButton = false,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final double dialogWidth = MediaQuery.of(context).size.width * 0.82;
        final double maxDialogWidth = 400; 
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            title?.isNotEmpty == true ? title! : 'Advertencia',
            style: const TextStyle(
              fontFamily: 'Poppins Bold',
              color: Colors.amber,
            ),
            textAlign: TextAlign.center,
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 280,
              maxWidth: dialogWidth.clamp(0, maxDialogWidth),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 Text(
                  messsage?.isNotEmpty == true ? messsage! : 'Registro Realizado,\n¿Qué desea realizar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins Regular'),
                ),
                const SizedBox(height: 20),

                if (stayButton)
                  _buildFullWidthButton(
                    label: 'Permanecer en la ventana',
                    icon: Icons.hourglass_empty,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                _buildFullWidthButton(
                  label: 'Regresar',
                  icon: Icons.arrow_back,
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (goBack) Navigator.pop(context);
                  },
                ),
                _buildFullWidthButton(
                  label: 'Menú Principal',
                  icon: Icons.home,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildFullWidthButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}


