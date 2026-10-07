import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../configs/injector/injector_conf.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/failure_converter.dart';
import '../../../../core/utils/logger.dart';
import '../../../../remote/models/address_model/address_list_response.dart';
import '../../domain/usecases/address_list_usecase.dart';

part 'address_list_event.dart';
part 'address_list_state.dart';

/// Handles state management for **Address List** fetching operations.
class AddressListBloc extends Bloc<AddressListEvent, AddressListState> {
  final AddressListUseCase? _addressListUseCase;

  AddressListUseCase get addressListUseCase =>
      _addressListUseCase ?? getIt<AddressListUseCase>();

  AddressListBloc([AddressListUseCase? addressListUseCase])
      : _addressListUseCase = addressListUseCase,
        super(AddressListInitialState()) {
    on<AddressListGetEvent>(_onAddressListGet);
  }

  Future<void> _onAddressListGet(
    AddressListGetEvent event,
    Emitter<AddressListState> emit,
  ) async {
    emit(AddressListLoadingState());

    final result = await addressListUseCase.call(NoParams());

    result.fold(
      (failure) => emit(
        AddressListFailureState(
          failure.message.isNotEmpty
              ? failure.message
              : mapFailureToMessage(failure),
        ),
      ),
      (response) => emit(AddressListSuccessState(response)),
    );
  }

  @override
  Future<void> close() {
    logger.i("===== CLOSE AddressListBloc =====");
    return super.close();
  }
}
