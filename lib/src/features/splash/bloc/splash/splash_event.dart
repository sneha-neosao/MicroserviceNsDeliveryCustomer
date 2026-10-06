part of 'splash_bloc.dart';

/// Base event for splash screen
sealed class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when the splash screen initializes
class SplashInitEvent extends SplashEvent {}
