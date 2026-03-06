import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/injection.dart';
import '../../blocs/feed/feed_bloc.dart';
import '../../widgets/product_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FeedBloc>()..add(FeedLoadEvent()),
      child: const _FeedBody(),
    );
  }
}

class _FeedBody extends StatefulWidget {
  const _FeedBody();
  @override State<_FeedBody> createState() => _FeedBodyState();
}

class _FeedBodyState extends State<_FeedBody> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<FeedBloc>().add(FeedLoadMoreEvent());
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedBloc, FeedState>(
      builder: (context, state) {
        if (state is FeedLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is FeedError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<FeedBloc>().add(FeedLoadEvent()),
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }
        if (state is FeedLoaded) {
          if (state.products.isEmpty) {
            return const Center(child: Text('Нет товаров', style: TextStyle(color: AppColors.textSecondary)));
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<FeedBloc>().add(FeedRefreshEvent()),
            child: GridView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                childAspectRatio: 0.65,
              ),
              itemCount: state.products.length + (state.hasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == state.products.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                return ProductCard(product: state.products[i]);
              },
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
