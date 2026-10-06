import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/string_validator_extension.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../remote/models/auth_model/register_response.dart';
import '../../../../remote/repositories/repository_impl.dart';

class RegisterParams extends Equatable {
  final String name;
  final String? email;
  final String contact;

  const RegisterParams({
    required this.name,
    this.email,
    required this.contact,
  });

  @override
  List<Object?> get props => [name, email, contact];
}

/// Use case for registering a new customer.
/// Validates mandatory name and contact, and optional email format.
class RegisterUseCase implements UseCase<RegisterResponse, RegisterParams> {
  final Repository _repository;

  const RegisterUseCase(this._repository);

  @override
  Future<Either<Failure, RegisterResponse>> call(RegisterParams params) async {
    final trimmedName = params.name.trim();
    final trimmedContact = params.contact.trim();
    final trimmedEmail = params.email?.trim() ?? '';

    if (trimmedName.isEmpty) {
      return Left(EmptyFailure('Please enter your full name'));
    }

    if (trimmedContact.isEmpty) {
      return Left(EmptyFailure('enter_mobile_number_error'.tr()));
    }

    if (!trimmedContact.isMobileNumberValid) {
      return Left(InvalidMobileNumberFailure('valid_mobile_number_error'.tr()));
    }

    if (trimmedEmail.isNotEmpty && !trimmedEmail.isEmailValid) {
      return Left(InvalidEmailFailure('please_enter_valid_email'.tr()));
    }

    return await _repository.register(
      RegisterParams(
        name: trimmedName,
        email: trimmedEmail.isNotEmpty ? trimmedEmail : null,
        contact: trimmedContact,
      ),
    );
  }
}
