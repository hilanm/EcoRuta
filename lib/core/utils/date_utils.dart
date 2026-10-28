/// Utilidades de fechas por día calendario LOCAL.
///
/// Un "día" se representa como DateTime.utc(año, mes, día) construido con los
/// componentes locales. Así la diferencia entre días es exacta (24 h) y no se
/// ve afectada por cambios de horario (DST) ni por conversiones a UTC.
DateTime dayOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

int daysBetween(DateTime a, DateTime b) =>
    dayOnly(b).difference(dayOnly(a)).inDays;

/// Clave estable "yyyy-MM-dd" para persistencia (sin hora ni zona).
String dayKey(DateTime d) {
  final x = dayOnly(d);
  return '${x.year.toString().padLeft(4, '0')}-'
      '${x.month.toString().padLeft(2, '0')}-'
      '${x.day.toString().padLeft(2, '0')}';
}

DateTime parseDayKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime.utc(p[0], p[1], p[2]);
}
