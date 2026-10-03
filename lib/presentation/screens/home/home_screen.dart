import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/gradient_logo_text.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/product_card.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/featured_banner.dart';
import 'widgets/home_app_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isGridView = true;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(productsProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(productsProvider.notifier).loadProducts(refresh: true),
        color: AppColors.primaryGradientStart,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: HomeAppBar(
                user: user,
                onToggleView: () => setState(() => _isGridView = !_isGridView),
                isGridView: _isGridView,
              ),
            ),

            // Featured banner
            SliverToBoxAdapter(
              child: featuredAsync.when(
                data: (products) => products.isNotEmpty
                    ? FeaturedBanner(products: products)
                    : const SizedBox.shrink(),
                loading: () => const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

            // Category filter
            SliverToBoxAdapter(
              child: CategoryFilterBar(
                selectedCategory: productsState.category,
                onCategorySelected: (cat) {
                  if (cat == null) {
                    ref.read(productsProvider.notifier).setCategory(null);
                    return;
                  }
                  context.push('/category/${Uri.encodeComponent(cat)}',
                      extra: cat);
                },
              ),
            ),

            // Sort bar
            SliverToBoxAdapter(
              child: _buildSortBar(context, productsState),
            ),

            // Products grid/list
            if (productsState.isLoading)
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
            else if (productsState.error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 16),
                      Text(productsState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(productsProvider.notifier)
                            .loadProducts(refresh: true),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              )
            else if (productsState.products.isEmpty)
              const SliverFillRemaining(
                child: EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: 'لا توجد عروض',
                  subtitle: 'جرّب قسمًا آخر أو عُد لاحقًا',
                ),
              )
            else
              _isGridView
                  ? SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverMasonryGrid.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childCount: productsState.products.length,
                        itemBuilder: (context, index) => ProductCard(
                          product: productsState.products[index],
                          isGridView: true,
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ProductCard(
                            product: productsState.products[index],
                            isGridView: false,
                          ),
                          childCount: productsState.products.length,
                        ),
                      ),
                    ),

            // Loading more indicator
            if (productsState.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildSortBar(BuildContext context, ProductsState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${state.products.length}${state.hasMore ? '+' : ''} عرض',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sort_rounded,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'ترتيب',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'createdAt_desc', child: Text('الأحدث')),
              const PopupMenuItem(
                  value: 'price_asc', child: Text('السعر من الأقل')),
              const PopupMenuItem(
                  value: 'price_desc', child: Text('السعر من الأعلى')),
              const PopupMenuItem(
                  value: 'viewCount_desc', child: Text('الأكثر مشاهدة')),
            ],
            onSelected: (value) {
              final parts = value.split('_');
              ref.read(productsProvider.notifier).setSorting(
                    sortBy: parts[0],
                    descending: parts[1] == 'desc',
                  );
            },
          ),
        ],
      ),
    );
  }
}
