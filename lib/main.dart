import 'dart:async';

import 'package:ai_accounting/const.dart';
import 'package:ai_accounting/database/database.dart';
import 'package:ai_accounting/theme.dart';
import 'package:flutter/material.dart';

class Transaction {
  final String id;
  final Category category;
  final CategoryType type;
  final double amount;
  final DateTime dateTime;

  Transaction({
    required this.id,
    required this.category,
    required this.type,
    required this.amount,
    required this.dateTime,
  });
}

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
  final List<Transaction> _transactions = [];
  double _totalIncome = 0;
  double _totalExpense = 0;
  StreamSubscription<List<TransactionEntity>>? _transactionsSubscription;

  @override
  void initState() {
    super.initState();
    _transactionsSubscription = appDatabase.watchAllTransactions().listen(
      (entities) {
        setState(() {
          _transactions.clear();
          _transactions.addAll(
            entities.map(_entityToTransaction).toList(),
          );
        });
        _updateTotals();
      },
    );
  }

  @override
  void dispose() {
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _updateTotals() async {
    final income = await appDatabase.getTotalIncome();
    final expense = await appDatabase.getTotalExpense();
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
      ),
    );
  }

  Transaction _entityToTransaction(TransactionEntity entity) {
    final categoryType = CategoryType.values[entity.categoryType];
    final categories = categoryType == CategoryType.expense
        ? Category.expenses
        : Category.incomes;
    final category = categories.firstWhere(
      (c) => c.name == entity.categoryName,
      orElse: () => Category.otherExpense,
    );

    return Transaction(
      id: entity.id,
      category: category,
      type: categoryType,
      amount: entity.amount,
      dateTime: entity.transactionTime,
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) {
      return '今天 ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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
                        final t = _transactions[index];
                        final isExpense = t.type == CategoryType.expense;
                        return ListTile(
                          leading: Icon(
                            t.category.icon,
                            color: context.colorScheme.primary,
                          ),
                          title: Text(t.category.name),
                          subtitle: Text(_formatDate(t.dateTime)),
                          trailing: Text(
                            '${isExpense ? '-' : '+'} ¥ ${t.amount.toStringAsFixed(2)}',
                            style: context.textTheme.titleMedium?.copyWith(
                              color: isExpense
                                  ? context.colorScheme.error
                                  : context.colorScheme.primary,
                            ),
                          ),
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

class AddTransactionPanel extends StatefulWidget {
  final Function(Transaction) onAdd;

  const AddTransactionPanel({super.key, required this.onAdd});

  @override
  State<AddTransactionPanel> createState() => _AddTransactionPanelState();
}

class _AddTransactionPanelState extends State<AddTransactionPanel> {
  CategoryType _selectedType = CategoryType.expense;
  Category? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveTransaction() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _selectedCategory == null) return;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory!,
      type: _selectedType,
      amount: amount,
      dateTime: DateTime.now(),
    );

    widget.onAdd(transaction);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == CategoryType.expense
        ? Category.expenses
        : Category.incomes;
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.onSurfaceVariant.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  '记一笔',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          // Type selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SegmentedButton<CategoryType>(
              segments: const [
                ButtonSegment(
                  value: CategoryType.expense,
                  label: Text('支出'),
                  icon: Icon(Icons.arrow_downward, size: 18),
                ),
                ButtonSegment(
                  value: CategoryType.income,
                  label: Text('收入'),
                  icon: Icon(Icons.arrow_upward, size: 18),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<CategoryType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                  _selectedCategory = null;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          // Amount input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '金额',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: context.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixText: '¥ ',
                    prefixStyle: context.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    hintText: '0.00',
                    hintStyle: context.textTheme.headlineLarge?.copyWith(
                      color: context.colorScheme.onSurfaceVariant.withAlpha(
                        100,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: context.colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Category selector
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '分类',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: categories.map((category) {
                          final isSelected = _selectedCategory == category;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Card(
                              color: isSelected
                                  ? context.colorScheme.primaryContainer
                                  : context.colorScheme.surfaceContainerLow,
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      category.icon,
                                      size: 20,
                                      color: isSelected
                                          ? context
                                                .colorScheme
                                                .onPrimaryContainer
                                          : context.colorScheme.onSurface,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      category.name,
                                      style: context.textTheme.bodyLarge
                                          ?.copyWith(
                                            color: isSelected
                                                ? context
                                                      .colorScheme
                                                      .onPrimaryContainer
                                                : context.colorScheme.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Save button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saveTransaction,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '保存',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
