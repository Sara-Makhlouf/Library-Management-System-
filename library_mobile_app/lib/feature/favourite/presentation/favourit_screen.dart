import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:library_mobile_app/core/theme.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favbloc.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favevent.dart';
import 'package:library_mobile_app/feature/favourite/bloc/favstate.dart';
import 'package:library_mobile_app/feature/favourite/data/repository.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      // حقن الـ Repository والـ Bloc وتوليد حدث الجلب أول ما تفتح الواجهة
      create: (context) =>
          FavoriteBloc(FavoriteRepository())..add(GetFavoritesEvent()),
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : const Color(0xFFEFE3D3),
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Favourite',
            style: TextStyle(
              color: isDark ? AppColors.textDark : Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            if (state is FavoriteLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FavoriteLoaded) {
              if (state.favoriteBooks.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد عناصر في المفضلة',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: state.favoriteBooks.length,
                itemBuilder: (context, index) {
                  final book = state.favoriteBooks[index];
                  return Card(
                    color: const Color(0xFFEFE3D3),
                    margin: const EdgeInsets.only(bottom: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          // صورة الغلاف مع معالجة الرابط القادم من الموديل
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: book.cover != null && book.cover!.isNotEmpty
                                ? Image.network(
                                    book.cover!,
                                    width: 60,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.book, size: 50),
                                  )
                                : const Icon(Icons.book, size: 50),
                          ),
                          const SizedBox(width: 15),

                          // تفاصيل الكتاب المتوافقة مع الموديل الجديد
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                /*/Text(
                                  'المؤلف: {book.authorName}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),*/
                                const SizedBox(height: 4),
                                Text(
                                  'التصنيف: ${book.categoryName}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'السعر: ${book.salePrice ?? book.price ?? '0'} \$',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // زر إزالة العنصر من المفضلة
                          IconButton(
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            onPressed: () {
                              // إرسال حدث التبديل لإزالة العنصر وتحديث القائمة
                              context.read<FavoriteBloc>().add(
                                ToggleFavoriteEvent(book.id),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is FavoriteError) {
              return Center(child: Text('حدث خطأ: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
