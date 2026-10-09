part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to fetch Home screen data
class HomeGetEvent extends HomeEvent {
  final int offset;
  final int limit;
  final double? lat;
  final double? lng;

  const HomeGetEvent({
    this.offset = 1,
    this.limit = 10,
    this.lat,
    this.lng,
  });

  @override
  List<Object?> get props => [offset, limit, lat, lng];
}
