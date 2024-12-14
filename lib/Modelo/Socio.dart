class Socio {
  String id;
  String nombre;
  int cantidadAcciones;
  bool estadoPago;
  int quincenasAhorradas;

  Socio({
    required this.id,
    required this.nombre,
    required this.cantidadAcciones,
    required this.estadoPago,
    required this.quincenasAhorradas,
  });

  factory Socio.fromMap(Map<String, dynamic> data, String documentId) {
    return Socio(
      id: documentId,
      nombre: data['nombre'] ?? '',
      cantidadAcciones: data['cantidadAcciones'] ?? 0,
      estadoPago: data['estadoPago'] ?? false,
      quincenasAhorradas: data['quincenasAhorradas'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'cantidadAcciones': cantidadAcciones,
      'estadoPago': estadoPago,
      'quincenasAhorradas': quincenasAhorradas,
    };
  }
}
