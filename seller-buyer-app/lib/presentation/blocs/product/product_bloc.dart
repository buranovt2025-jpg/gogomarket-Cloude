import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';


import '../../../core/network/api_client.dart';
import '../../../data/models/product/product_model.dart';

abstract class ProductEvent extends Equatable {
  @override List<Object?> get props => [];
}
class ProductLoadEvent extends ProductEvent {
  final String id;
  ProductLoadEvent(this.id);
  @override List<Object?> get props => [id];
}

abstract class ProductState extends Equatable {
  @override List<Object?> get props => [];
}
class ProductInitial extends ProductState {}
class ProductLoading extends ProductState {}
class ProductLoaded  extends ProductState {
  final ProductModel product;
  ProductLoaded(this.product);
  @override List<Object?> get props => [product.id];
}
class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
  @override List<Object?> get props => [message];
}


class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiClient _api;
  ProductBloc(this._api) : super(ProductInitial()) {
    on<ProductLoadEvent>((e, emit) async {
      emit(ProductLoading());
      try {
        final p = await _api.getProduct(e.id);
        emit(ProductLoaded(p));
      } catch (err) {
        emit(ProductError(err.toString()));
      }
    });
  }
}
