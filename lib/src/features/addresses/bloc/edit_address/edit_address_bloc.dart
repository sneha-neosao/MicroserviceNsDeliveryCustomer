import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/update_address_response.dart';
import '../../domain/usecases/edit_address_usecase.dart';

part 'edit_address_event.dart';
part 'edit_address_state.dart';

/// Handles state management for **Edit Address** API execution.
class EditAddressBloc extends Bloc<EditAddressEvent, EditAddressState> {
  final EditAddressUseCase _editAddressUseCase;

  EditAddressBloc(this._editAddressUseCase) : super(EditAddressInitialState()) {
    on<EditAddressSubmitEvent>(_onEditAddressSubmit);
  }

  Future<void> _onEditAddressSubmit(
    EditAddressSubmitEvent event,
    Emitter<EditAddressState> emit,
  ) async {
    emit(EditAddressLoadingState());

    final result = await _editAddressUseCase.call(event.params);

    result.fold(
      (failure) => emit(EditAddressFailureState(failure.message)),
      (response) => emit(EditAddressSuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE EditAddressBloc =====");
    return super.close();
  }
}
