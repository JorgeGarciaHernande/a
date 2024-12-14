import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Modelo/Socio.dart';

class SocioControlador {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<int> _obtenerSiguienteId() async {
    QuerySnapshot snapshot = await firestore.collection('socios').get();
    return snapshot.docs.length + 1;
  }

  Future<void> agregarSocio(BuildContext context) async {
    final TextEditingController _nombreController = TextEditingController();
    final TextEditingController _cantidadAccionesController = TextEditingController();
    final TextEditingController _quincenasAhorradasController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Socio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _cantidadAccionesController,
                decoration: InputDecoration(labelText: 'Cantidad de Acciones'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _quincenasAhorradasController,
                decoration: InputDecoration(labelText: 'Quincenas Ahorradas'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String nombre = _nombreController.text;
                int cantidadAcciones = int.parse(_cantidadAccionesController.text);
                int quincenasAhorradas = int.parse(_quincenasAhorradasController.text);
                double rendimiento = calcularRendimiento(cantidadAcciones, quincenasAhorradas);

                int id = await _obtenerSiguienteId();
                Socio nuevoSocio = Socio(
                  id: id.toString(),
                  nombre: nombre,
                  cantidadAcciones: cantidadAcciones,
                  estadoPago: true,
                  quincenasAhorradas: quincenasAhorradas,
                );

                await firestore.collection('socios').doc(id.toString()).set(nuevoSocio.toMap());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Socio agregado correctamente con rendimiento: \$${rendimiento.toStringAsFixed(2)}')),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> eliminarSocio(String id, BuildContext context) async {
    TextEditingController _confirmController = TextEditingController();

    bool confirm = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Socio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Desea eliminar el socio? Escriba "confirmar" para proceder.'),
              TextField(
                controller: _confirmController,
                decoration: InputDecoration(labelText: 'Confirmar'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (_confirmController.text == 'confirmar') {
                  Navigator.of(context).pop(true);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Debe escribir "confirmar" para eliminar.')),
                    );
                  }
                }
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm) {
      try {
        await firestore.collection('socios').doc(id).delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Socio eliminado correctamente')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar socio: $e')),
          );
        }
        print('Error al eliminar socio: $e');
      }
    }
  }

  Future<void> actualizarSocio(Socio socio) async {
    await firestore.collection('socios').doc(socio.id).update(socio.toMap());
  }

  double calcularRendimiento(int cantidadAcciones, int quincenasAhorradas) {
    double costoAccion = 1000.0;
    double valorQuincena = 100.0;
    double rendimiento = (cantidadAcciones * costoAccion + quincenasAhorradas * valorQuincena) * 1.4;
    return rendimiento;
  }

  Future<double> calcularDineroCaja() async {
    QuerySnapshot snapshot = await firestore.collection('socios').get();
    int totalAcciones = 0;
    int totalQuincenas = 0;

    for (var doc in snapshot.docs) {
      Socio socio = Socio.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      totalAcciones += socio.cantidadAcciones;
      totalQuincenas += socio.quincenasAhorradas;
    }

    double dineroCaja = (totalAcciones * 1000) + (totalQuincenas * 100);
    return dineroCaja;
  }
}
