import 'package:ai_accounting/const.dart';
import 'package:flutter/material.dart';
import 'package:ai_accounting/database/database.dart';
import 'package:ai_accounting/theme.dart';
import 'package:ai_accounting/utils.dart' as utils;

class TransactionTimelineTile extends StatelessWidget {
  final Transaction transaction;
  final bool isLast;

  const TransactionTimelineTile({
    super.key,
    required this.transaction,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == CategoryType.expense;
    const double headerHeight = 32;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 50,
            child: Column(
              children: [
                Container(
                  height: headerHeight,
                  alignment: Alignment.center,
                  child: Text(
                    utils.formatTime(transaction.dateTime),
                    style: context.textTheme.labelMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: isLast
                      ? const SizedBox()
                      : Center(
                          child: Container(
                            width: 1.5,
                            color: context.colorScheme.outlineVariant,
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: headerHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCategoryTag(context),
                      const Spacer(),
                      _buildAmountBadge(context, isExpense),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 12),
                  child: Text(
                    transaction.remark,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorScheme.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            transaction.category.name,
            style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            transaction.category.icon,
            size: 12,
            color: context.colorScheme.primary,
          ),
          Icon(
            Icons.chevron_right,
            size: 12,
            color: context.colorScheme.primary.withAlpha(100),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBadge(BuildContext context, bool isExpense) {
    final color = isExpense
        ? context.colorScheme.error
        : context.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100), width: 1.5),
      ),
      child: Text(
        '${isExpense ? '-' : '+'} ¥${transaction.amount.toStringAsFixed(2)}',
        style: context.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
