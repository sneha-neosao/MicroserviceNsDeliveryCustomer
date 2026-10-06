import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/utils/logger.dart';

part 'splash_event.dart';
part 'splash_state.dart';

/// Handles state management for the splash screen.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInitialState()) {
    on<SplashInitEvent>(_onInit);
  }

  Future<void> _onInit(SplashInitEvent event, Emitter<SplashState> emit) async {
    emit(SplashLoadingState());
    // Smooth display duration allowing full blur-to-clear and shimmer sequence to complete
    await Future.delayed(const Duration(milliseconds: 3200));

    final isLoggedIn = await SessionManager.isLoggedIn();
    if (isLoggedIn) {
      emit(SplashAuthenticatedState());
    } else {
      emit(SplashUnauthenticatedState());
    }
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE SplashBloc =====");
    return super.close();
  }
}
