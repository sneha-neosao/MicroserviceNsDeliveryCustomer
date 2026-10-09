import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/add_address_response.dart';
import '../../domain/usecases/add_address_usecase.dart';

part 'add_address_event.dart';
part 'add_address_state.dart';

/// Handles state management for **Add Address** API execution.
class AddAddressBloc extends Bloc<AddAddressEvent, AddAddressState> {
  final AddAddressUseCase _addAddressUseCase;

  AddAddressBloc(this._addAddressUseCase) : super(AddAddressInitialState()) {
    on<AddAddressSubmitEvent>(_onAddAddressSubmit);
  }

  Future<void> _onAddAddressSubmit(
    AddAddressSubmitEvent event,
    Emitter<AddAddressState> emit,
  ) async {
    emit(AddAddressLoadingState());

    final result = await _addAddressUseCase.call(event.params);

    result.fold(
      (failure) => emit(AddAddressFailureState(failure.message)),
      (response) => emit(AddAddressSuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE AddAddressBloc =====");
    return super.close();
  }
}
