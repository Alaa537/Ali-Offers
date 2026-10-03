import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final void Function(String?) onCategorySelected;

  const CategoryFilterBar(
      {super.key,
      required this.selectedCategory,
      required this.onCategorySelected});

  static const _colors = {
    'الكل': Color(0xFF6941C6),
    'عروض اتصالات': Color(0xFF00A651),
    'عروض فودافون': Color(0xFFE31837),
    'دفع الفواتير': Color(0xFF1570EF),
    'عروض أخرى': Color(0xFFF79009),
  };

  static const _icons = {
    'الكل': Icons.apps_rounded,
    'عروض اتصالات': Icons.sim_card_rounded,
    'عروض فودافون': Icons.phone_android_rounded,
    'دفع الفواتير': Icons.receipt_long_rounded,
    'عروض أخرى': Icons.local_offer_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: AppConstants.productCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = AppConstants.productCategories[index];
          final selected = (selectedCategory == null && category == 'الكل') ||
              selectedCategory == category;
          final color = _colors[category] ?? AppColors.primaryGradientStart;
          return Semantics(
            button: true,
            label: category,
            child: GestureDetector(
              onTap: () =>
                  onCategorySelected(category == 'الكل' ? null : category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 92,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color:
                      selected ? color : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: selected ? color : color.withOpacity(.25)),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                              color: color.withOpacity(.25),
                              blurRadius: 12,
                              offset: const Offset(0, 5))
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BrandMark(
                        category: category,
                        color: selected ? Colors.white : color),
                    const SizedBox(height: 5),
                    Text(category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  final String category;
  final Color color;
  const _BrandMark({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    final text = category == 'عروض اتصالات'
        ? 'e&'
        : category == 'عروض فودافون'
            ? 'V'
            : category == 'دفع الفواتير'
                ? 'فاتورة'
                : null;
    if (text != null)
      return Text(text,
          style: TextStyle(
              color: color,
              fontSize: text == 'فاتورة' ? 10 : 23,
              fontWeight: FontWeight.w900));
    final icon = switch (category) {
      'الكل' => Icons.apps_rounded,
      'عروض فودافون' => Icons.phone_android_rounded,
      'دفع الفواتير' => Icons.receipt_long_rounded,
      _ => Icons.local_offer_rounded,
    };
    return Icon(icon, color: color, size: 25);
  }
}
