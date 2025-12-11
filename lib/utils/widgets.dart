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

