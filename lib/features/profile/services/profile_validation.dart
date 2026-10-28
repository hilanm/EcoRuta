String? validateAlias(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Escribe un alias.';
  if (t.length < 2) return 'Usa al menos 2 caracteres.';
  if (t.length > 24) return 'Máximo 24 caracteres.';
  return null;
}
