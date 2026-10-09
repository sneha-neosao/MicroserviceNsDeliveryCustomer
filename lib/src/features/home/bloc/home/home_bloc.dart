import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/home_response.dart';
import '../../domain/usecases/home_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Handles state management for **Home Screen** API execution.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeUseCase _homeUseCase;

  HomeBloc(this._homeUseCase) : super(HomeInitialState()) {
    on<HomeGetEvent>(_onHomeGet);
  }

  Future<void> _onHomeGet(
    HomeGetEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoadingState());

    final result = await _homeUseCase.call(
      HomeParams(
        offset: event.offset,
        limit: event.limit,
        lat: event.lat,
        lng: event.lng,
      ),
    );

    result.fold(
      (failure) => emit(HomeFailureState(failure.message)),
      (response) => emit(HomeSuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE HomeBloc =====");
    return super.close();
  }
}
