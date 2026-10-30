import '../modelos/tanda.dart';
import '../modelos/cierre_ronda.dart';
import 'resultado_aportacion.dart';
import 'resultado_cierre.dart';

class ServicioTanda {
  final Tanda tanda;

  ServicioTanda(this.tanda);

  // VERIFICAR SI LA TANDA TERMINO
  bool haTerminado() {
    return tanda.turnoActual >= tanda.ordenTurnos.length;
  }

  // REGISTRAR APORTACION
  ResultadoAportacion registrarAportacion(String idParticipante) {
    if (haTerminado()) {
      return ResultadoAportacion.tandaTerminada;
    }

    final esParticipante = tanda.participantes.any(
      (p) => p.id == idParticipante,
    );

    if (!esParticipante) {
      return ResultadoAportacion.participanteInvalido;
    }

    final yaAporto = tanda.aportacionesRondaActual.contains(idParticipante);

    if (yaAporto) {
      return ResultadoAportacion.yaAporto;
    }

    tanda.aportacionesRondaActual.add(idParticipante);

    return ResultadoAportacion.registrada;
  }

  // VERIFICAR SI TODOS APORTARON
  bool puedeCerrarRonda() {
    return tanda.participantes.every(
      (p) => tanda.aportacionesRondaActual.contains(p.id),
    );
  }

  // CERRAR RONDA Y AVANZAR
  CierreRonda cerrarRondaYAvanzar() {
    if (!puedeCerrarRonda()) {
      return CierreRonda(ResultadoCierre.faltanAportaciones, null);
    }

    final idBeneficiario = tanda.ordenTurnos[tanda.turnoActual];

    final beneficiario = tanda.participantes.firstWhere(
      (p) => p.id == idBeneficiario,
    );

    beneficiario.yaRecibioTurno = true;

    tanda.aportacionesRondaActual.clear();

    tanda.turnoActual++;

    return CierreRonda(ResultadoCierre.rondaCerrada, beneficiario);
  }
}
