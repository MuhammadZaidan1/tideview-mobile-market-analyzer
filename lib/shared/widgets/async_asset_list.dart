import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'custom_shimmer.dart';

class AsyncAssetList<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T data) builder;
  final String? emptyMessage;
  final String? errorMessage;
  final int shimmerCount;
  final double shimmerHeight;
  final EdgeInsetsGeometry? padding;

  const AsyncAssetList({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.emptyMessage,
    this.errorMessage,
    this.shimmerCount = 5,
    this.shimmerHeight = 100,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 120),
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => ListView.builder(
        padding: padding,
        itemCount: shimmerCount,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CustomShimmer(height: shimmerHeight, borderRadius: 24),
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            errorMessage ?? 'Failed to load data: $err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ),
      data: (data) {
        if (data is List && data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage ?? 'No data found',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }
        return builder(data);
      },
    );
  }
}
