import 'package:flutter/material.dart';

Widget buildInfoRow(String label, String value, {Color? valueColor}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 1),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.grey.withOpacity(0.3), // borde con opacidad
          width: 1.0,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontFamily: 'Poppins SemiBold',
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins Regular',
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    ),
  );
}

Widget buildPerfilRow(BuildContext context, IconData icon, String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    ],
  );
}



Widget infoRow(String label, dynamic value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(fontFamily: "Poppins SemiBold"),
        ),
        Expanded(
          child: Text(
            "$value",
            style: const TextStyle(fontFamily: "Poppins Regular"),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

// Esto hace que el código sea mantenible y responsivo
Widget buildDataRow(String label, String value) {
  return Padding(
    // 1. Padding vertical interno reducido para compactar la lista visualmente
    padding: const EdgeInsets.symmetric(vertical: 4.0), 
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea arriba si el texto es largo
      children: [
        // Lado Izquierdo (Etiqueta):
        // Eliminé el SizedBox. Ahora solo ocupa el ancho de su texto.
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins SemiBold',
            fontSize: 13, // 2. Reducido para ganar espacio
            color: Colors.black54,
          ),
        ),
        
        const SizedBox(width: 10), // Separación mínima segura entre etiqueta y valor

        // Lado Derecho (Valor):
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins Regular',
              fontSize: 13, // Mismo tamaño para consistencia
              color: Colors.black87,
              height: 1.2, // 3. Altura de línea ajustada para que no se vea muy separado si hay 2 líneas
            ),
            textAlign: TextAlign.right, 
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    ),
  );
}

Widget buildCompactRow(String label, String value) {
  return RichText(
    overflow: TextOverflow.ellipsis,
    text: TextSpan(
      style: const TextStyle(fontSize: 12, fontFamily: 'Poppins Regular', color: Colors.black),
      children: [
        TextSpan(
          text: '$label ', // La etiqueta
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            color: Colors.black54
          ),
        ),
        TextSpan(
          text: value, // El valor
          style: const TextStyle(
            color: Colors.black87
          ),
        ),
      ],
    ),
  );
}

Widget buildTextRow(String label, String value) {
  return RichText(
    overflow: TextOverflow.ellipsis,
    text: TextSpan(
      style: const TextStyle(
        fontSize: 13, 
        fontFamily: 'Poppins Regular', 
        color: Colors.black87
      ),
      children: [
        TextSpan(
          text: '$label ', 
          style: const TextStyle(fontWeight: FontWeight.bold) // La etiqueta en negrita
        ),
        TextSpan(text: value),
      ],
    ),
  );
}
