import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/product/product_model.dart';

part 'feed_event.dart';
part 'feed_state.dart';

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final ApiClient _api;

  FeedBloc(this._api) : super(FeedInitial()) {
    on<FeedLoadEvent>(_onLoad);
    on<FeedRefreshEvent>(_onRefresh);
    on<FeedLoadMoreEvent>(_onLoadMore);
    on<FeedChangeModeEvent>(_onChangeMode);
    on<FeedChangeCategoryEvent>(_onChangeCategory);
  }

  String _mode     = 'discover';
  String? _catId;
  int _page        = 1;
  bool _hasMore    = true;

  Future<void> _onLoad(FeedLoadEvent e, Emitter<FeedState> emit) async {
    emit(FeedLoading());
    _page = 1; _hasMore = true;
    try {
      final res = await _api.getFeed(mode: _mode, page: 1, categoryId: _catId);
      _hasMore = res.hasMore;
      emit(FeedLoaded(products: res.items, hasMore: _hasMore, mode: _mode));
    } catch (err) {
      emit(FeedError(message: err.toString()));
    }
  }

  Future<void> _onRefresh(FeedRefreshEvent e, Emitter<FeedState> emit) async {
    _page = 1;
    try {
      final res = await _api.getFeed(mode: _mode, page: 1, categoryId: _catId);
      _hasMore = res.hasMore;
      emit(FeedLoaded(products: res.items, hasMore: _hasMore, mode: _mode));
    } catch (_) {}
  }

  Future<void> _onLoadMore(FeedLoadMoreEvent e, Emitter<FeedState> emit) async {
    if (!_hasMore || state is! FeedLoaded) return;
    final current = (state as FeedLoaded).products;
    _page++;
    try {
      final res = await _api.getFeed(mode: _mode, page: _page, categoryId: _catId);
      _hasMore = res.hasMore;
      emit(FeedLoaded(products: [...current, ...res.items], hasMore: _hasMore, mode: _mode));
    } catch (_) { _page--; }
  }

  Future<void> _onChangeMode(FeedChangeModeEvent e, Emitter<FeedState> emit) async {
    _mode = e.mode; _page = 1;
    add(FeedLoadEvent());
  }

  Future<void> _onChangeCategory(FeedChangeCategoryEvent e, Emitter<FeedState> emit) async {
    _catId = e.categoryId; _page = 1;
    add(FeedLoadEvent());
  }
}
