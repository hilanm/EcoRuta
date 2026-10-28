enum RecyclingMaterial {
  plastic('Plástico'),
  glass('Vidrio'),
  paper('Papel y cartón'),
  metal('Latas y metales'),
  electronic('Residuos electrónicos'),
  batteries('Pilas y baterías'),
  oil('Aceite usado'),
  textile('Ropa y textiles');

  const RecyclingMaterial(this.label);
  final String label;

  static RecyclingMaterial fromName(String name) =>
      RecyclingMaterial.values.firstWhere((m) => m.name == name);
}
