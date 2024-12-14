import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Controlador/SocioControlador.dart';
import '../Modelo/Socio.dart';

class SocioVista extends StatefulWidget {
  @override
  _SocioVistaState createState() => _SocioVistaState();
}

class _SocioVistaState extends State<SocioVista> {
  final SocioControlador _socioControlador = SocioControlador();
  double _dineroCaja = 0.0;

  @override
  void initState() {
    super.initState();
    _actualizarDineroCaja();
  }

  void _actualizarDineroCaja() async {
    double dineroCaja = await _socioControlador.calcularDineroCaja();
    if (mounted) {
      setState(() {
        _dineroCaja = dineroCaja;
      });
    }
  }

  void _mostrarDialogoEdicion(BuildContext context, Socio socio) {
    TextEditingController nombreController = TextEditingController(text: socio.nombre);
    TextEditingController cantidadAccionesController = TextEditingController(text: socio.cantidadAcciones.toString());
    TextEditingController quincenasAhorradasController = TextEditingController(text: socio.quincenasAhorradas.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Socio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: cantidadAccionesController,
                  decoration: InputDecoration(
                    labelText: 'Cantidad de Acciones',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: quincenasAhorradasController,
                        decoration: InputDecoration(
                          labelText: 'Quincenas Ahorradas',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        int quincenas = int.parse(quincenasAhorradasController.text);
                        quincenas++;
                        quincenasAhorradasController.text = quincenas.toString();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Guardar'),
              onPressed: () {
                socio.nombre = nombreController.text;
                socio.cantidadAcciones = int.parse(cantidadAccionesController.text);
                socio.quincenasAhorradas = int.parse(quincenasAhorradasController.text);
                _socioControlador.actualizarSocio(socio);
                _actualizarDineroCaja();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Socios'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('socios').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Nombre')),
                      DataColumn(label: Text('Cantidad de Acciones')),
                      DataColumn(label: Text('Quincenas Ahorradas')),
                      DataColumn(label: Text('Rendimiento')),
                      DataColumn(label: Text('Acciones')),
                    ],
                    rows: snapshot.data!.docs.map((doc) {
                      Socio socio = Socio.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                      double rendimiento = _socioControlador.calcularRendimiento(socio.cantidadAcciones, socio.quincenasAhorradas);
                      return DataRow(
                        cells: [
                          DataCell(Text(socio.id)),
                          DataCell(Text(socio.nombre)),
                          DataCell(Text(socio.cantidadAcciones.toString())),
                          DataCell(Text(socio.quincenasAhorradas.toString())),
                          DataCell(Text('\$${rendimiento.toStringAsFixed(2)}')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    _mostrarDialogoEdicion(context, socio);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await _socioControlador.eliminarSocio(socio.id, context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dinero con el que cuenta la caja: \$${_dineroCaja.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: _actualizarDineroCaja,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                await _socioControlador.agregarSocio(context);
              },
              child: Text('Agregar Socio'),
            ),
          ),
        ],
      ),
    );
  }
}
