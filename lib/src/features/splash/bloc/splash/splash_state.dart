part of 'splash_bloc.dart';

/// Base state for splash screen
sealed class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Initial state of splash screen
class SplashInitialState extends SplashState {}

/// State when splash screen is checking initial dependencies/session
class SplashLoadingState extends SplashState {}

/// State when user session is active (logged in)
class SplashAuthenticatedState extends SplashState {}

/// State when user session is not active (not logged in)
class SplashUnauthenticatedState extends SplashState {}

/// Compatible state holding login status flag
class SplashLoadedState extends SplashState {
  final bool isLoggedIn;

  const SplashLoadedState({this.isLoggedIn = false});

  @override
  List<Object?> get props => [isLoggedIn];
}
