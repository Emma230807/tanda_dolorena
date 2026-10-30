import 'package:flutter/material.dart';

import '../modelos/participante.dart';
import '../modelos/tanda.dart';
import '../logica/resultado_cierre.dart';
import '../logica/servicio_tanda.dart';

class TandaScreen extends StatefulWidget {
  const TandaScreen({super.key});

  @override
  State<TandaScreen> createState() => _TandaScreenState();
}

class _TandaScreenState extends State<TandaScreen> {
  late final Tanda _tanda;
  late final ServicioTanda _servicio;

  @override
  void initState() {
    super.initState();

    // CREAR TANDA DE PRUEBA
    _tanda = Tanda(
      participantes: [
        Participante(id: 'p1', nombre: 'Ana'),
        Participante(id: 'p2', nombre: 'Beto'),
        Participante(id: 'p3', nombre: 'Carla'),
        Participante(id: 'p4', nombre: 'Diego'),
      ],
      ordenTurnos: ['p1', 'p2', 'p3', 'p4'],
      montoAportacion: 200,
    );

    _servicio = ServicioTanda(_tanda);
  }

  // REGISTRAR APORTACIONES
  void _aportar(String idParticipante) {
    setState(() {
      _servicio.registrarAportacion(idParticipante);
    });
  }

  // CERRAR RONDA
  void _cerrarRonda() {
    if (_servicio.haTerminado()) {
      return;
    }

    final cierre = _servicio.cerrarRondaYAvanzar();

    // VERIFICAR APORTACIONES PENDIENTES
    if (cierre.resultado == ResultadoCierre.faltanAportaciones) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todavía faltan vecinos por aportar.')),
      );
      return;
    }

    if (cierre.resultado != ResultadoCierre.rondaCerrada ||
        cierre.beneficiario == null) {
      return;
    }

    setState(() {});

    final nombreBeneficiario = cierre.beneficiario!.nombre;

    // MOSTRAR ANIMACION DEL BENEFICIARIO
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Beneficiario',
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(
            opacity: anim1,
            child: AlertDialog(
              title: const Text('Turno entregado'),
              content: Text('¡Le tocó a $nombreBeneficiario esta ronda!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final terminada = _servicio.haTerminado();

    final totalAportado = _tanda.aportacionesRondaActual.length;
    final totalParticipantes = _tanda.participantes.length;

    final rondaMostrada = terminada
        ? _tanda.ordenTurnos.length
        : _tanda.turnoActual + 1;

    final progreso = terminada
        ? 1.0
        : totalParticipantes == 0
        ? 0.0
        : totalAportado / totalParticipantes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanda Doloreña'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TITULO DE LA RONDA
          Text(
            terminada
                ? 'Tanda finalizada'
                : 'Ronda actual: $rondaMostrada de ${_tanda.ordenTurnos.length}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // BARRA DE PROGRESO ANIMADA
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progreso),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (context, valor, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(value: valor, minHeight: 10),
              );
            },
          ),

          const SizedBox(height: 8),

          Text(
            terminada
                ? 'Todos los vecinos recibieron su turno.'
                : '$totalAportado de $totalParticipantes vecinos ya aportaron',
          ),

          const SizedBox(height: 20),

          // LISTA DE PARTICIPANTES
          ..._tanda.participantes.asMap().entries.map((entry) {
            final participante = entry.value;

            // EVITAR ACCEDER A UN TURNO INEXISTENTE
            final esTurnoActual =
                !terminada &&
                _tanda.ordenTurnos[_tanda.turnoActual] == participante.id;

            final yaAporto = _tanda.aportacionesRondaActual.contains(
              participante.id,
            );

            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: esTurnoActual
                    ? Colors.amber.shade100
                    : Colors.grey.shade100,
                border: Border.all(
                  color: esTurnoActual ? Colors.amber : Colors.grey.shade300,
                  width: esTurnoActual ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // ICONO DEL PARTICIPANTE
                  Icon(
                    participante.yaRecibioTurno
                        ? Icons.check_circle
                        : Icons.person,
                    color: participante.yaRecibioTurno
                        ? Colors.green
                        : Colors.indigo,
                  ),

                  const SizedBox(width: 10),

                  // NOMBRE
                  Expanded(
                    child: Text(
                      participante.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),

                  // INDICADOR DEL TURNO ACTUAL
                  if (esTurnoActual)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Text(
                        'Turno actual',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                        ),
                      ),
                    ),

                  // BOTON APORTAR
                  OutlinedButton(
                    onPressed: yaAporto || terminada
                        ? null
                        : () => _aportar(participante.id),
                    child: Text(yaAporto ? 'Aportó' : 'Aportar'),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // BOTON CERRAR RONDA
          ElevatedButton.icon(
            onPressed: terminada ? null : _cerrarRonda,
            icon: const Icon(Icons.emoji_events),
            label: Text(
              terminada ? 'Tanda finalizada' : 'Cerrar ronda y entregar turno',
            ),
          ),
        ],
      ),
    );
  }
}
