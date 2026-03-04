import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/product/product_model.dart';

// ── Cart Item ─────────────────────────────────────────────────────────────────
class CartItem extends Equatable {
  final ProductModel product;
  final int qty;
  final String? variantId;

  const CartItem({required this.product, this.qty = 1, this.variantId});

  CartItem copyWith({int? qty}) => CartItem(product: product, qty: qty ?? this.qty, variantId: variantId);

  int get totalTiyin => product.priceTiyin * qty;

  Map<String, dynamic> toJson() => {'product': product.toJson(), 'qty': qty, 'variantId': variantId};
  factory CartItem.fromJson(Map<String, dynamic> j) => CartItem(
    product: ProductModel.fromJson(j['product'] as Map<String, dynamic>),
    qty: j['qty'] as int,
    variantId: j['variantId'] as String?,
  );

  @override List<Object?> get props => [product.id, variantId];
}

// ── Events ────────────────────────────────────────────────────────────────────
abstract class CartEvent extends Equatable {
  @override List<Object?> get props => [];
}
class CartAdd    extends CartEvent { final CartItem item; CartAdd(this.item); @override List<Object?> get props => [item]; }
class CartRemove extends CartEvent { final String productId; CartRemove(this.productId); @override List<Object?> get props => [productId]; }
class CartUpdate extends CartEvent { final String productId; final int qty; CartUpdate(this.productId, this.qty); @override List<Object?> get props => [productId, qty]; }
class CartClear  extends CartEvent {}

// ── State ─────────────────────────────────────────────────────────────────────
class CartState extends Equatable {
  final List<CartItem> items;
  const CartState({this.items = const []});

  int get totalQty    => items.fold(0, (s, i) => s + i.qty);
  int get totalTiyin  => items.fold(0, (s, i) => s + i.totalTiyin);
  bool contains(String id) => items.any((i) => i.product.id == id);

  CartState copyWith({List<CartItem>? items}) => CartState(items: items ?? this.items);

  Map<String, dynamic> toJson() => {'items': items.map((i) => i.toJson()).toList()};
  factory CartState.fromJson(Map<String, dynamic> j) => CartState(
    items: (j['items'] as List<dynamic>? ?? []).map((e) => CartItem.fromJson(e as Map<String, dynamic>)).toList(),
  );

  @override List<Object?> get props => [items.length, totalTiyin];
}

// ── Bloc ──────────────────────────────────────────────────────────────────────
@injectable
class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartAdd>(_onAdd);
    on<CartRemove>(_onRemove);
    on<CartUpdate>(_onUpdate);
    on<CartClear>((_, emit) => emit(const CartState()));
  }

  void _onAdd(CartAdd e, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final idx   = items.indexWhere((i) => i.product.id == e.item.product.id && i.variantId == e.item.variantId);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(qty: items[idx].qty + 1);
    } else {
      items.add(e.item);
    }
    emit(state.copyWith(items: items));
  }

  void _onRemove(CartRemove e, Emitter<CartState> emit) {
    emit(state.copyWith(items: state.items.where((i) => i.product.id != e.productId).toList()));
  }

  void _onUpdate(CartUpdate e, Emitter<CartState> emit) {
    if (e.qty <= 0) { add(CartRemove(e.productId)); return; }
    emit(state.copyWith(
      items: state.items.map((i) => i.product.id == e.productId ? i.copyWith(qty: e.qty) : i).toList(),
    ));
  }

  @override CartState fromJson(Map<String, dynamic> json) => CartState.fromJson(json);
  @override Map<String, dynamic>? toJson(CartState state) => state.toJson();
}
