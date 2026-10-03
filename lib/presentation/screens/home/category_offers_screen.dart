import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/product_card.dart';

class CategoryOffersScreen extends ConsumerStatefulWidget {
  final String category;
  const CategoryOffersScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryOffersScreen> createState() =>
      _CategoryOffersScreenState();
}

class _CategoryOffersScreenState extends ConsumerState<CategoryOffersScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 220) {
        ref.read(productsProvider.notifier).loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted)
        ref.read(productsProvider.notifier).setCategory(widget.category);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productsProvider);
    final color = _categoryColor(widget.category);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: () =>
                ref.read(productsProvider.notifier).loadProducts(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: color,
        onRefresh: () =>
            ref.read(productsProvider.notifier).loadProducts(refresh: true),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
                child:
                    _CategoryHeader(category: widget.category, color: color)),
            if (state.isLoading)
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: 6,
                  itemBuilder: (_, __) => const ProductCardShimmer(),
                ),
              )
            else if (state.error != null)
              SliverFillRemaining(
                child: _ErrorContent(
                    message: state.error!,
                    onRetry: () => ref
                        .read(productsProvider.notifier)
                        .loadProducts(refresh: true)),
              )
            else if (state.products.isEmpty)
              const SliverFillRemaining(
                  child: EmptyStateWidget(
                      icon: Icons.local_offer_outlined,
                      title: 'لا توجد عروض في هذا القسم',
                      subtitle: 'سيظهر أي عرض جديد هنا تلقائيًا'))
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childCount: state.products.length,
                  itemBuilder: (_, index) => ProductCard(
                      product: state.products[index], isGridView: true),
                ),
              ),
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                  child: Padding(
                      padding: EdgeInsets.all(22),
                      child: Center(child: CircularProgressIndicator()))),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'عروض اتصالات':
        return const Color(0xFF00A651);
      case 'عروض فودافون':
        return const Color(0xFFE31837);
      case 'دفع الفواتير':
        return const Color(0xFF1570EF);
      default:
        return AppColors.primaryGradientStart;
    }
  }
}

class _CategoryHeader extends StatelessWidget {
  final String category;
  final Color color;
  const _CategoryHeader({required this.category, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [color.withOpacity(.95), color.withOpacity(.55)]),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(.24),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(children: [
          Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18), shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 28)),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(category,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('العروض المنشورة في هذا القسم فقط',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
        ]),
      );
}

class _ErrorContent extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorContent({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.error, size: 46),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة')),
          ])));
}
