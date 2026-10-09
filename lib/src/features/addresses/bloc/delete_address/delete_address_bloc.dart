import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/delete_address_response.dart';
import '../../domain/usecases/delete_address_usecase.dart';

part 'delete_address_event.dart';
part 'delete_address_state.dart';

/// Handles state management for **Delete Address** API execution.
class DeleteAddressBloc extends Bloc<DeleteAddressEvent, DeleteAddressState> {
  final DeleteAddressUseCase _deleteAddressUseCase;

  DeleteAddressBloc(this._deleteAddressUseCase)
      : super(DeleteAddressInitialState()) {
    on<DeleteAddressSubmitEvent>(_onDeleteAddressSubmit);
  }

  Future<void> _onDeleteAddressSubmit(
    DeleteAddressSubmitEvent event,
    Emitter<DeleteAddressState> emit,
  ) async {
    emit(DeleteAddressLoadingState());

    final result = await _deleteAddressUseCase.call(
      DeleteAddressParams(publicId: event.publicId),
    );

    result.fold(
      (failure) => emit(DeleteAddressFailureState(failure.message)),
      (response) => emit(DeleteAddressSuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE DeleteAddressBloc =====");
    return super.close();
  }
}
