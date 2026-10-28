/// Celdas de un mes con semana de lunes a domingo.
/// null = celda vacía de relleno. Los días son DateTime.utc(a, m, d).
List<DateTime?> monthGrid(int year, int month) {
  final first = DateTime.utc(year, month, 1);
  final daysInMonth = DateTime.utc(year, month + 1, 0).day;
  final cells = <DateTime?>[
    for (var i = 0; i < first.weekday - 1; i++) null,
    for (var d = 1; d <= daysInMonth; d++) DateTime.utc(year, month, d),
  ];
  while (cells.length % 7 != 0) {
    cells.add(null);
  }
  return cells;
}
