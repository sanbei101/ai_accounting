import 'dart:async';

import 'package:ai_accounting/components/add_transaction_panel.dart';
import 'package:ai_accounting/components/transaction_timeline_tile.dart';
import 'package:ai_accounting/database/database.dart';
import 'package:ai_accounting/theme.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Transaction> _transactions = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  StreamSubscription<List<TransactionEntity>>? _transactionsSubscription;

  @override
  void initState() {
    super.initState();
    _transactionsSubscription = appDatabase.watchAllTransactions().listen((
      entities,
    ) {
      setState(() {
        _transactions = entities.map(AppDatabase.entityToTransaction).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
      });
      _updateTotals();
    });
  }

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateTotals() async {
    final (income, expense) = await appDatabase.getTotals();
    setState(() {
      _totalIncome = income;
      _totalExpense = expense;
    });
  }

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
  Widget build(BuildContext context) {
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
                      '¥ ${(_totalIncome - _totalExpense).toStringAsFixed(2)}',
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
                                    '¥ ${_totalIncome.toStringAsFixed(2)}',
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
                                    '¥ ${_totalExpense.toStringAsFixed(2)}',
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
              child: _transactions.isEmpty
                  ? Center(
                      child: Text(
                        '暂无账单',
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        return TransactionTimelineTile(
                          transaction: _transactions[index],
                          isLast: index == _transactions.length - 1,
                        );
                      },
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
