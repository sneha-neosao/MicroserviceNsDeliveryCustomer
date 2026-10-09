part of 'profile_details_bloc.dart';

sealed class ProfileDetailsState extends Equatable {
  const ProfileDetailsState();

  @override
  List<Object?> get props => [];
}

class ProfileDetailsInitialState extends ProfileDetailsState {}

class ProfileDetailsLoadingState extends ProfileDetailsState {}

class ProfileDetailsSuccessState extends ProfileDetailsState {
  final ProfileResponse data;

  const ProfileDetailsSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class ProfileDetailsFailureState extends ProfileDetailsState {
  final String message;

  const ProfileDetailsFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
