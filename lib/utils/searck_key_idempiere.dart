dynamic searchKey(dynamic json, String key) {
  if (json is Map) {
    if (json.containsKey(key)) {
      return json[key];
    }
    for (var value in json.values) {
      var result = searchKey(value, key);
      if (result != null) return result;
    }
  } else if (json is List) {
    for (var element in json) {
      var result = searchKey(element, key);
      if (result != null) return result;
    }
  }
  return null;
}

dynamic findValueByColumn(dynamic json, String columnName) {
  if (json is Map) {
    // Si el nodo actual es un campo tipo {"@column": "DocumentNo", "@value": "123"}
    if (json["@column"] == columnName) {
      return json["@value"];
    }

    // Recorrer recursivamente hijos
    for (var value in json.values) {
      final result = findValueByColumn(value, columnName);
      if (result != null) return result;
    }
  }

  if (json is List) {
    for (var element in json) {
      final result = findValueByColumn(element, columnName);
      if (result != null) return result;
    }
  }

  return null;
}

dynamic findIsError(dynamic json) {
  if (json is Map) {
    // Si encontramos la propiedad "@IsError", la retornamos
    if (json.containsKey("@IsError")) {
      // Convertimos a booleano por si viene como string o bool
      final value = json["@IsError"];
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    // Recorrer recursivamente hijos
    for (var value in json.values) {
      final result = findIsError(value);
      if (result != null) return result;
    }
  }

  if (json is List) {
    for (var element in json) {
      final result = findIsError(element);
      if (result != null) return result;
    }
  }

  return null;
}