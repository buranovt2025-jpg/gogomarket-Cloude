part of 'feed_bloc.dart';

abstract class FeedEvent extends Equatable {
  const FeedEvent();
  @override List<Object?> get props => [];
}

class FeedLoadEvent     extends FeedEvent {}
class FeedRefreshEvent  extends FeedEvent {}
class FeedLoadMoreEvent extends FeedEvent {}

class FeedChangeModeEvent extends FeedEvent {
  final String mode;
  const FeedChangeModeEvent(this.mode);
  @override List<Object?> get props => [mode];
}

class FeedChangeCategoryEvent extends FeedEvent {
  final String? categoryId;
  const FeedChangeCategoryEvent(this.categoryId);
  @override List<Object?> get props => [categoryId];
}
