part of 'profile_details_bloc.dart';

sealed class ProfileDetailsEvent extends Equatable {
  const ProfileDetailsEvent();

  @override
  List<Object?> get props => [];
}

class ProfileDetailsGetEvent extends ProfileDetailsEvent {}
