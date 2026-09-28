class ClinicalMath {
  const ClinicalMath._();

  static double bmi({required double weightKg, required double heightCm}) {
    if (weightKg <= 0 || heightCm <= 0) throw ArgumentError('Peso e altura devem ser positivos.');
    final meters = heightCm / 100;
    return weightKg / (meters * meters);
  }

  static double doseFromVolume({required double concentration, required double volumeMl}) {
    if (concentration < 0 || volumeMl < 0) throw ArgumentError('Valores não podem ser negativos.');
    return concentration * volumeMl;
  }

  static double volumeFromDose({required double dose, required double concentration}) {
    if (dose < 0 || concentration <= 0) throw ArgumentError('Concentração deve ser maior que zero.');
    return dose / concentration;
  }

  static PiebResult pieb({
    required double volumeMl,
    required int intervalMinutes,
    required double localMgMl,
    required double opioidMcgMl,
  }) {
    if (volumeMl < 0 || intervalMinutes <= 0 || localMgMl < 0 || opioidMcgMl < 0) {
      throw ArgumentError('Parâmetros PIEB inválidos.');
    }
    final cyclesPerHour = 60 / intervalMinutes;
    return PiebResult(
      localMgPerBolus: volumeMl * localMgMl,
      opioidMcgPerBolus: volumeMl * opioidMcgMl,
      averageMlPerHour: volumeMl * cyclesPerHour,
      averageLocalMgPerHour: volumeMl * localMgMl * cyclesPerHour,
    );
  }

  static PceaResult pcea({
    required double demandVolumeMl,
    required int lockoutMinutes,
    required double localMgMl,
    required double opioidMcgMl,
  }) {
    if (demandVolumeMl < 0 || lockoutMinutes <= 0 || localMgMl < 0 || opioidMcgMl < 0) {
      throw ArgumentError('Parâmetros PCEA inválidos.');
    }
    final maxDemands = 60 ~/ lockoutMinutes;
    return PceaResult(
      maxDemandsPerHour: maxDemands,
      maximumMlPerHour: demandVolumeMl * maxDemands,
      maximumLocalMgPerHour: demandVolumeMl * localMgMl * maxDemands,
      maximumOpioidMcgPerHour: demandVolumeMl * opioidMcgMl * maxDemands,
    );
  }
}

class PiebResult {
  const PiebResult({
    required this.localMgPerBolus,
    required this.opioidMcgPerBolus,
    required this.averageMlPerHour,
    required this.averageLocalMgPerHour,
  });
  final double localMgPerBolus;
  final double opioidMcgPerBolus;
  final double averageMlPerHour;
  final double averageLocalMgPerHour;
}

class PceaResult {
  const PceaResult({
    required this.maxDemandsPerHour,
    required this.maximumMlPerHour,
    required this.maximumLocalMgPerHour,
    required this.maximumOpioidMcgPerHour,
  });
  final int maxDemandsPerHour;
  final double maximumMlPerHour;
  final double maximumLocalMgPerHour;
  final double maximumOpioidMcgPerHour;
}
