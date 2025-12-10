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