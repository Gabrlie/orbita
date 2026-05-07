enum AppLockMode { never, onExit, afterDuration }

class AppSecurityState {
  final bool hasPassword;
  final bool biometricEnabled;
  final bool isUnlocked;
  final AppLockMode lockMode;
  final int lockAfterMinutes;

  const AppSecurityState({
    required this.hasPassword,
    required this.biometricEnabled,
    required this.isUnlocked,
    required this.lockMode,
    required this.lockAfterMinutes,
  });

  factory AppSecurityState.initial() {
    return const AppSecurityState(
      hasPassword: false,
      biometricEnabled: false,
      isUnlocked: true,
      lockMode: AppLockMode.never,
      lockAfterMinutes: 5,
    );
  }

  AppSecurityState copyWith({
    bool? hasPassword,
    bool? biometricEnabled,
    bool? isUnlocked,
    AppLockMode? lockMode,
    int? lockAfterMinutes,
  }) {
    return AppSecurityState(
      hasPassword: hasPassword ?? this.hasPassword,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      lockMode: lockMode ?? this.lockMode,
      lockAfterMinutes: lockAfterMinutes ?? this.lockAfterMinutes,
    );
  }
}
