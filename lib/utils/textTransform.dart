
//Funcion para Transformar Texto a Pascacale por cada espacio que detecte en un array de solo Texto
String capitalizeEachWord(String text) {
  return text
      .toLowerCase() // Convierte todo el texto a minúsculas.
      .split(' ') // Divide el texto por espacios.
      .map((word) => word.isNotEmpty 
          ? '${word[0].toUpperCase()}${word.substring(1)}' 
          : '') // Convierte la primera letra de cada palabra en mayúscula.
      .join(' '); // Une las palabras nuevamente con un espacio.
}

String formatQuantity(dynamic qty) {
  double number = double.tryParse(qty.toString()) ?? 0.0; // Convierte a número, si falla usa 0.0
  
  if (number % 1 == 0) {
    return number.toStringAsFixed(0); // Entero si no tiene decimales
  } else {
    String qtyString = number.toString();
    int decimalCount = qtyString.split('.')[1].length; // Cuenta los decimales
    
    if (decimalCount <= 2) {
      return number.toStringAsFixed(2); // Máximo 2 decimales si tiene hasta 2
    } else {
      return number.toStringAsFixed(4); // Usa 4 decimales si tiene más de 2
    }
  }
}