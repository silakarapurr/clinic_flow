import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/config/env_config.dart';

/// Custom BlocObserver auditing state transitions without leaking patient data.
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (EnvConfig.isDevelopment) {
      developer.log(
        'BLOC CHANGE [${bloc.runtimeType}]: ${change.currentState.runtimeType} -> ${change.nextState.runtimeType}',
        name: 'ClinicFlow',
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    developer.log(
      'BLOC ERROR [${bloc.runtimeType}]: $error',
      name: 'ClinicFlow',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
