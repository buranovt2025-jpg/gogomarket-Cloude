import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/product/product_model.dart';

// Cart item
class CartItem extends Equatable {
  final ProductModel product;
  final String? variantId;
  final int quantity;
  const CartItem({required this.product, this.variantId, required this.quantity});
  CartItem copyWith({int? quantity}) =>
    CartItem(product: product, variantId: variantId, quantity: quantity ?? this.quantity);
  int get totalTiyin => product.priceTiyin * quantity;
  @override List<Object?> get props => [product.id, variantId];
}

// Events
abstract class CartEvent extends Equatable {
  @override List<Object?> get props => [];
}
class AddToCartEvent extends CartEvent {
  final ProductModel product; final String? variantId;
  AddToCartEvent({required this.product, this.variantId});
  @override List<Object?> get props => [product.id, variantId];
}
class RemoveFromCartEvent extends CartEvent {
  final String productId; final String? variantId;
  RemoveFromCartEvent({required this.productId, this.variantId});
  @override List<Object?> get props => [productId, variantId];
}
class UpdateQuantityEvent extends CartEvent {
  final String productId; final String? variantId; final int quantity;
  UpdateQuantityEvent({required this.productId, this.variantId, required this.quantity});
  @override List<Object?> get props => [productId, quantity];
}
class ClearCartEvent extends CartEvent {}

// State
class CartState extends Equatable {
  final List<CartItem> items;
  const CartState({this.items = const []});
  int get itemCount => items.fold(0, (acc, i) => acc + i.quantity);
  int get totalTiyin => items.fold(0, (acc, i) => acc + i.totalTiyin);
  int get totalSum => totalTiyin ~/ 100;
  bool get isEmpty => items.isEmpty;
  @override List<Object?> get props => [items];
}

@injectable
class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCartEvent>(_onAdd);
    on<RemoveFromCartEvent>(_onRemove);
    on<UpdateQuantityEvent>(_onUpdate);
    on<ClearCartEvent>((_, emit) => emit(const CartState()));
  }

  void _onAdd(AddToCartEvent e, Emitter<CartState> emit) {
    final idx = state.items.indexWhere(
      (i) => i.product.id == e.product.id && i.variantId == e.variantId,
    );
    final items = List<CartItem>.from(state.items);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(product: e.product, variantId: e.variantId, quantity: 1));
    }
    emit(CartState(items: items));
  }

  void _onRemove(RemoveFromCartEvent e, Emitter<CartState> emit) {
    emit(CartState(
      items: state.items.where(
        (i) => !(i.product.id == e.productId && i.variantId == e.variantId)
      ).toList(),
    ));
  }

  void _onUpdate(UpdateQuantityEvent e, Emitter<CartState> emit) {
    if (e.quantity <= 0) {
      add(RemoveFromCartEvent(productId: e.productId, variantId: e.variantId));
      return;
    }
    final items = state.items.map((i) {
      if (i.product.id == e.productId && i.variantId == e.variantId) {
        return i.copyWith(quantity: e.quantity);
      }
      return i;
    }).toList();
    emit(CartState(items: items));
  }

  @override
  CartState fromJson(Map<String, dynamic> json) => const CartState(); // skip hydration for now
  @override
  Map<String, dynamic>? toJson(CartState state) => null;
}
