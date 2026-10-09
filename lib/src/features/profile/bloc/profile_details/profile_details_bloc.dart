import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/profile_response.dart';
import '../../domain/usecases/profile_usecase.dart';

part 'profile_details_event.dart';
part 'profile_details_state.dart';

/// Handles state management for **Profile Details** API execution.
class ProfileDetailsBloc
    extends Bloc<ProfileDetailsEvent, ProfileDetailsState> {
  final ProfileDetailsUseCase _profileDetailsUseCase;

  ProfileDetailsBloc(this._profileDetailsUseCase)
      : super(ProfileDetailsInitialState()) {
    on<ProfileDetailsGetEvent>(_onProfileDetailsGet);
  }

  Future<void> _onProfileDetailsGet(
    ProfileDetailsGetEvent event,
    Emitter<ProfileDetailsState> emit,
  ) async {
    emit(ProfileDetailsLoadingState());

    final result = await _profileDetailsUseCase.call(NoParams());

    result.fold(
      (failure) => emit(ProfileDetailsFailureState(failure.message)),
      (response) => emit(ProfileDetailsSuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE ProfileDetailsBloc =====");
    return super.close();
  }
}
