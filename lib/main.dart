import 'package:ai_accounting/components/add_transaction_panel.dart';
import 'package:ai_accounting/components/transaction_timeline_tile.dart';
import 'package:ai_accounting/database/database.dart';
import 'package:ai_accounting/providers.dart';
import 'package:ai_accounting/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _addTransaction(Transaction transaction) async {
    await appDatabase.insertTransaction(
      TransactionsCompanion.insert(
        id: transaction.id,
        categoryName: transaction.category.name,
        categoryIcon: transaction.category.icon.codePoint,
        categoryType: transaction.type.index,
        amount: transaction.amount,
        transactionTime: transaction.dateTime,
        remark: transaction.remark,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final (income, expense) = ref.watch(totalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 记账'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: context.colorScheme.primaryContainer,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本月结余',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '¥ ${(income - expense).toStringAsFixed(2)}',
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: context.colorScheme.secondaryContainer,
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        size: 16,
                                        color: context
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '收入',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: context
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '¥ ${income.toStringAsFixed(2)}',
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          color: context
                                              .colorScheme
                                              .onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            color: context.colorScheme.secondaryContainer,
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        size: 16,
                                        color: context
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '支出',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: context
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '¥ ${expense.toStringAsFixed(2)}',
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          color: context
                                              .colorScheme
                                              .onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('最近账单', style: context.textTheme.titleLarge),
            const SizedBox(height: 24),
            Expanded(
              child: transactionsAsync.when(
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Center(
                      child: Text(
                        '暂无账单',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return TransactionTimelineTile(
                        transaction: transactions[index],
                        isLast: index == transactions.length - 1,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, e) => const Center(child: Text('加载失败')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddTransactionPanel(onAdd: _addTransaction),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
      ),
    );
  }
}
