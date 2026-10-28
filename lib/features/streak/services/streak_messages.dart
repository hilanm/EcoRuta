/// Mensaje motivacional según el estado real de la racha.
String motivationalMessage(
    {required int current, required int best, required bool activeToday}) {
  final dias = current == 1 ? 'día' : 'días';
  if (best == 0) return 'Registra tu primer reciclaje y enciende tu racha.';
  if (current == 0) return 'Tu racha se reinició. Cada día nuevo cuenta: empieza hoy.';
  if (!activeToday) return 'Llevas $current $dias. Registra hoy para mantenerla.';
  if (current >= best && current >= 3) return '¡Estás en tu mejor racha! Sigue así.';
  if (current >= 7) return '¡Una semana o más! Estás creando un hábito.';
  return '¡Bien hecho! Vuelve mañana para seguir sumando.';
}
