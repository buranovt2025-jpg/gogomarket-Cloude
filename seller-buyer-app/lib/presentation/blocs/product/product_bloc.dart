import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../data/models/product/product_model.dart';
import '../../../core/network/api_client.dart';

abstract class ProductEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoadProductEvent extends ProductEvent {
  final String id;
  LoadProductEvent(this.id);
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
}

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiClient _api;

  ProductBloc(this._api) : super(ProductInitial()) {
    on<LoadProductEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadProductEvent e, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      final product = await _api.getProduct(e.id);
      emit(ProductLoaded(product));
    } catch (err) {
      emit(ProductError(err.toString()));
    }
  }
}
