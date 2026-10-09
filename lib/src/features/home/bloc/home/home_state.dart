part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {}

class HomeLoadingState extends HomeState {}

class HomeSuccessState extends HomeState {
  final HomeResponse data;

  const HomeSuccessState(this.data);

  @override
  List<Object?> get props => [data];
}

class HomeFailureState extends HomeState {
  final String message;

  const HomeFailureState(this.message);

  @override
  List<Object?> get props => [message];
}
