import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/product/product_model.dart';
import '../../../core/network/api_client.dart';

abstract class FeedEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadFeedEvent    extends FeedEvent { final bool refresh; LoadFeedEvent({this.refresh = false}); }
class LoadMoreFeedEvent extends FeedEvent {}
class ToggleFeedModeEvent extends FeedEvent {} // subscriptions <-> discover

abstract class FeedState extends Equatable {
  @override List<Object?> get props => [];
}
class FeedInitial  extends FeedState {}
class FeedLoading  extends FeedState {}
class FeedLoaded   extends FeedState {
  final List<ProductModel> products;
  final bool isDiscover; // false = subscriptions
  final bool hasMore;
  final int page;
  FeedLoaded({required this.products, this.isDiscover = true, this.hasMore = true, this.page = 1});
  @override List<Object?> get props => [products.length, isDiscover, hasMore, page];
}
class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
  @override List<Object?> get props => [message];
}

@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final ApiClient _api;
  bool _isDiscover = true;

  FeedBloc(this._api) : super(FeedInitial()) {
    on<LoadFeedEvent>(_onLoad);
    on<LoadMoreFeedEvent>(_onLoadMore);
    on<ToggleFeedModeEvent>(_onToggle);
  }

  Future<void> _onLoad(LoadFeedEvent e, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    try {
      final res = await _api.getProducts(page: 1, limit: 20, sort: 'popular');
      emit(FeedLoaded(products: res.items, isDiscover: _isDiscover, page: 1));
    } catch (err) {
      emit(FeedError(err.toString()));
    }
  }

  Future<void> _onLoadMore(LoadMoreFeedEvent e, Emitter<FeedState> emit) async {
    final current = state as FeedLoaded;
    if (!current.hasMore) return;
    try {
      final res = await _api.getProducts(page: current.page + 1, limit: 20);
      emit(FeedLoaded(
        products: [...current.products, ...res.items],
        isDiscover: _isDiscover,
        page: current.page + 1,
        hasMore: res.items.length == 20,
      ));
    } catch (_) {}
  }

  void _onToggle(ToggleFeedModeEvent e, Emitter<FeedState> emit) {
    _isDiscover = !_isDiscover;
    add(LoadFeedEvent(refresh: true));
  }
}
