import 'package:workmanager/workmanager.dart';

//Libreria para las notificaciones de esto workmanager



void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Simula una tarea de sincronización
   
    // Muestra una notificación al finalizar la sincronización

    return Future.value(true);
  });
}

void initializeWorkManager() {
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true); // Cambia a `false` en producción
}

void startSyncTask() {
  Workmanager().registerOneOffTask(
    'syncTask', // ID único
    'syncOperation', // Nombre de la tarea
    inputData: {"key": "value"}, // Opcional: datos de entrada
  );
}