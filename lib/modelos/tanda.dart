import 'participante.dart';

class Tanda {
  final List<Participante> participantes;
  final List<String> ordenTurnos;
  final double montoAportacion;

  int turnoActual = 0;

  final Set<String> aportacionesRondaActual = {};

  Tanda({
    required this.participantes,
    required this.ordenTurnos,
    required this.montoAportacion,
  });
}
