import 'package:femovil/presentation/clients/clients_details.dart';
import 'package:femovil/presentation/clients/clients_screen.dart';
import 'package:flutter/material.dart';


class SuccessClientModal {
  static Future<void> show(
    BuildContext context,
    dynamic client, {
    bool goBack = false,
    String? title,
    String? message,
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
            title?.isNotEmpty == true ? title! : 'Registro con éxito',
            style: const TextStyle(
              fontFamily: 'Poppins Bold',
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          // envolvemos el contenido para forzar el ancho y centrarlo
          content: ConstrainedBox(
            constraints: BoxConstraints(
              // toma 82% del ancho de la pantalla pero no más de maxDialogWidth
              minWidth: 280,
              maxWidth: dialogWidth.clamp(0, maxDialogWidth),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // NOTA: los botones usan double.infinity, así ocuparán el ancho del ConstrainedBox
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                   Text(
                  message?.isNotEmpty == true
                      ? message!
                      : '¿Qué desea realizar?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppins Regular'),
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
                  label: 'Gestionar Cliente Registrado',
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientDetailsScreen(client: client),
                      ),
                    );
                  },
                ),

                _buildFullWidthButton(
                  label: 'Clientes',
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Clients()),
                    );
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

class WarningClientModal {
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    bool goBack = false,
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
            title?.isNotEmpty == true
                ? title!
                : 'Registro con éxito',
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
                  message?.isNotEmpty == true
                      ? message!
                      : '¿Qué desea realizar?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Poppins Regular'),
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
                  label: 'Clientes',
                  icon: Icons.person,
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Clients()),
                    );
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
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}