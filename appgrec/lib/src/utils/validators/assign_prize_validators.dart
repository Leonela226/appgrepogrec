// Esta función verifica si un premio ya fue asignado localmente.
// Recibe una lista que representan los premios asignados y un ID de premio.
// Devuelve true si el ID del premio ya se encuentra en la lista, indicando que ya fue asignado.
bool isPrizeAlreadyAssignedLocally(List<Map<String, dynamic>> assignedPrizes, int idPrize) {
  return assignedPrizes.any((prize) => prize['premio_id'] == idPrize);
}

// Esta función calcula el siguiente orden disponible para asignar un premio.
// Si la lista está vacía, devuelve 1 como el primer orden.
// Si ya hay premios asignados, obtiene todos los valores de 'orden', los ordena y devuelve el siguiente valor disponible.
int getNextAvailableOrder(List<Map<String, dynamic>> assignedPrizes) {
  if (assignedPrizes.isEmpty) return 1;

  final usedOrders = assignedPrizes.map((p) => p['orden'] as int).toList()..sort();
  return usedOrders.last + 1;
}

// Esta función determina si ya se alcanzó el número máximo de premios permitidos.
// Recibe la cantidad de premios ya asignados en la base de datos, la cantidad asignada localmente y el máximo permitido.
// Devuelve true si la suma de ambos alcanza o supera el límite establecido.
bool hasReachedMaxPrizes(int assignedDb, int assignedLocal, int maxAllowed) {
  return (assignedDb + assignedLocal) >= maxAllowed;
}
