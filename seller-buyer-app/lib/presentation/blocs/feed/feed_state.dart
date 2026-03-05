part of 'feed_bloc.dart';

abstract class FeedState extends Equatable {
  const FeedState();
  @override List<Object?> get props => [];
}

class FeedInitial extends FeedState {}
class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<ProductModel> products;
  final bool hasMore;
  final String mode;
  const FeedLoaded({required this.products, required this.hasMore, required this.mode});
  @override List<Object?> get props => [products.length, mode, hasMore];
}

class FeedError extends FeedState {
  final String message;
  const FeedError({required this.message});
  @override List<Object?> get props => [message];
}
