import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/product/product_model.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class FeedEvent extends Equatable {
  @override List<Object?> get props => [];
}
class FeedLoad       extends FeedEvent {
  final String mode; // discover | following
  FeedLoad({this.mode = 'discover'});
  @override List<Object?> get props => [mode];
}
class FeedLoadMore   extends FeedEvent {}
class FeedRefresh    extends FeedEvent {}
class FeedToggleMode extends FeedEvent {}
class FeedSetCategory extends FeedEvent {
  final String? category;
  FeedSetCategory(this.category);
  @override List<Object?> get props => [category];
}

// ── State ─────────────────────────────────────────────────────────────────────
class FeedState extends Equatable {
  final List<ProductModel> products;
  final String mode;         // discover | following
  final String? category;
  final int  currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? error;

  const FeedState({
    this.products    = const [],
    this.mode        = 'discover',
    this.category,
    this.currentPage = 1,
    this.hasMore     = true,
    this.isLoading   = false,
    this.isLoadingMore = false,
    this.isRefreshing  = false,
    this.error,
  });

  FeedState copyWith({
    List<ProductModel>? products,
    String? mode, String? category,
    int? currentPage, bool? hasMore,
    bool? isLoading, bool? isLoadingMore, bool? isRefreshing,
    String? error, bool clearError = false, bool clearCategory = false,
  }) => FeedState(
    products:      products     ?? this.products,
    mode:          mode         ?? this.mode,
    category:      clearCategory ? null : (category ?? this.category),
    currentPage:   currentPage  ?? this.currentPage,
    hasMore:       hasMore      ?? this.hasMore,
    isLoading:     isLoading    ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isRefreshing:  isRefreshing  ?? this.isRefreshing,
    error:         clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [products.length, mode, category, currentPage, hasMore, isLoading, isLoadingMore, isRefreshing, error];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────
@injectable
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  final ApiClient _api;

  FeedBloc(this._api) : super(const FeedState()) {
    on<FeedLoad>(_onLoad);
    on<FeedLoadMore>(_onLoadMore);
    on<FeedRefresh>(_onRefresh);
    on<FeedToggleMode>(_onToggle);
    on<FeedSetCategory>(_onCategory);
  }

  Future<void> _onLoad(FeedLoad e, Emitter<FeedState> emit) async {
    emit(state.copyWith(isLoading: true, mode: e.mode, currentPage: 1, clearError: true));
    try {
      final res = await _api.getFeed(mode: e.mode, page: 1, category: state.category);
      emit(state.copyWith(
        products: res.items, currentPage: 1,
        hasMore: res.items.length < res.total,
        isLoading: false,
      ));
    } catch (err) {
      emit(state.copyWith(isLoading: false, error: err.toString()));
    }
  }

  Future<void> _onLoadMore(FeedLoadMore e, Emitter<FeedState> emit) async {
    if (!state.hasMore || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.currentPage + 1;
      final res  = await _api.getFeed(mode: state.mode, page: next, category: state.category);
      emit(state.copyWith(
        products: [...state.products, ...res.items],
        currentPage: next,
        hasMore: state.products.length + res.items.length < res.total,
        isLoadingMore: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(FeedRefresh e, Emitter<FeedState> emit) async {
    emit(state.copyWith(isRefreshing: true));
    try {
      final res = await _api.getFeed(mode: state.mode, page: 1, category: state.category);
      emit(state.copyWith(
        products: res.items, currentPage: 1,
        hasMore: res.items.length < res.total,
        isRefreshing: false, clearError: true,
      ));
    } catch (_) {
      emit(state.copyWith(isRefreshing: false));
    }
  }

  void _onToggle(FeedToggleMode e, Emitter<FeedState> emit) {
    final next = state.mode == 'discover' ? 'following' : 'discover';
    add(FeedLoad(mode: next));
  }

  void _onCategory(FeedSetCategory e, Emitter<FeedState> emit) {
    emit(state.copyWith(category: e.category, clearCategory: e.category == null));
    add(FeedLoad(mode: state.mode));
  }
}
