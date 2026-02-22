import 'dart:convert';

import 'package:ai_accounting/ai.dart';
import 'package:ai_accounting/const.dart';
import 'package:ai_accounting/database/database.dart';
import 'package:ai_accounting/theme.dart';
import 'package:flutter/material.dart';

class _CategoryItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primaryContainer
                  : context.colorScheme.surfaceContainerHighest.withAlpha(120),
              shape: BoxShape.circle,
            ),
            child: Icon(
              category.icon,
              size: 24,
              color: isSelected
                  ? context.colorScheme.onPrimaryContainer
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category.name,
            style: context.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CategorySelectionComponent extends StatelessWidget {
  final CategoryType selectedType;
  final Category? selectedCategory;
  final ValueChanged<CategoryType> onTypeChanged;
  final ValueChanged<Category> onCategoryChanged;

  const _CategorySelectionComponent({
    required this.selectedType,
    required this.selectedCategory,
    required this.onTypeChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = selectedType == CategoryType.expense
        ? expenseCategories
        : incomeCategories;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              _buildTab(context, '支出', CategoryType.expense),
              const SizedBox(width: 8),
              _buildTab(context, '收入', CategoryType.income),
              const Spacer(),
              TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                label: const Text('收起'),
                style: TextButton.styleFrom(
                  foregroundColor: context.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryItem(
                category: category,
                isSelected: selectedCategory == category,
                onTap: () => onCategoryChanged(category),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTab(BuildContext context, String title, CategoryType type) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => onTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.primaryContainer.withAlpha(150)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            color: isSelected
                ? context.colorScheme.primary
                : context.colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _CalculatorComponent extends StatelessWidget {
  final String amount;
  final TextEditingController aiController;
  final bool isAILoading;
  final VoidCallback onParseAI;
  final ValueChanged<String> onKeyTap;

  const _CalculatorComponent({
    required this.amount,
    required this.aiController,
    required this.isAILoading,
    required this.onParseAI,
    required this.onKeyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '¥',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      amount,
                      style: context.textTheme.displaySmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: context.colorScheme.onSurfaceVariant.withAlpha(150),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: aiController,
                      decoration: InputDecoration(
                        hintText: '点击填写备注信息 支持AI智能记账)',
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant.withAlpha(
                            150,
                          ),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isAILoading ? null : onParseAI,
                    icon: isAILoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.auto_awesome,
                            color: context.colorScheme.primary,
                          ),
                  ),
                ],
              ),
            ),
            // 键盘区域
            Container(
              color: context.colorScheme.surfaceContainerHighest.withAlpha(100),
              padding: const EdgeInsets.all(6),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildKey(context, '1'),
                      _buildKey(context, '2'),
                      _buildKey(context, '3'),
                      _buildKey(
                        context,
                        '⌫',
                        isIcon: true,
                        icon: Icons.backspace_outlined,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildKey(context, '4'),
                      _buildKey(context, '5'),
                      _buildKey(context, '6'),
                      _buildKey(context, '+'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildKey(context, '7'),
                      _buildKey(context, '8'),
                      _buildKey(context, '9'),
                      _buildKey(context, '-'),
                    ],
                  ),
                  Row(
                    children: [
                      _buildKey(context, '再记'),
                      _buildKey(context, '0'),
                      _buildKey(context, '.'),
                      _buildKey(context, '完成', isPrimary: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(
    BuildContext context,
    String text, {
    bool isPrimary = false,
    bool isIcon = false,
    IconData? icon,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: isPrimary
              ? context.colorScheme.primary
              : context.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () => onKeyTap(text),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              child: isIcon
                  ? Icon(icon, color: context.colorScheme.onSurface)
                  : Text(
                      text,
                      style: context.textTheme.titleLarge?.copyWith(
                        color: isPrimary
                            ? context.colorScheme.onPrimary
                            : context.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddTransactionPanel extends StatefulWidget {
  final ValueChanged<Transaction> onAdd;

  const AddTransactionPanel({super.key, required this.onAdd});

  @override
  State<AddTransactionPanel> createState() => _AddTransactionPanelState();
}

class _AddTransactionPanelState extends State<AddTransactionPanel> {
  CategoryType _selectedType = CategoryType.expense;
  Category? _selectedCategory;
  String _amountStr = '0.00';

  final TextEditingController _aiInputController = TextEditingController();
  bool _isLoadingAI = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = expenseCategories.first;
  }

  @override
  void dispose() {
    _aiInputController.dispose();
    super.dispose();
  }

  Future<void> _parseWithAI() async {
    final input = _aiInputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _isLoadingAI = true;
    });

    try {
      final response = await chat(input);
      final data = jsonDecode(response) as Map<String, dynamic>;
      final transaction = Transaction.fromJson(data);

      setState(() {
        _selectedType = transaction.type;
        _selectedCategory = transaction.category;
        _amountStr = transaction.amount.toStringAsFixed(2);
      });
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('AI解析失败'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingAI = false;
      });
    }
  }

  void _evaluateMath() {
    try {
      if (_amountStr.contains('+')) {
        final parts = _amountStr.split('+');
        if (parts.length == 2 && parts[1].isNotEmpty) {
          final sum =
              (double.tryParse(parts[0]) ?? 0) +
              (double.tryParse(parts[1]) ?? 0);
          _amountStr = sum.toStringAsFixed(2);
        }
      } else if (_amountStr.contains('-')) {
        final parts = _amountStr.split('-');
        if (parts.length == 2 && parts[1].isNotEmpty) {
          final diff =
              (double.tryParse(parts[0]) ?? 0) -
              (double.tryParse(parts[1]) ?? 0);
          _amountStr = diff.toStringAsFixed(2);
        }
      }
    } catch (_) {}
  }

  void _saveTransaction({bool keepOpen = false}) {
    _evaluateMath();

    final amount = double.tryParse(_amountStr) ?? 0;

    if (amount <= 0 || _selectedCategory == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('提示'),
          content: Text(
            _selectedCategory == null ? '请先选择一个分类哦' : '请输入大于0的有效金额',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('知道啦'),
            ),
          ],
        ),
      );
      return;
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: _selectedCategory!,
      type: _selectedType,
      amount: amount,
      dateTime: DateTime.now(),
      remark: _aiInputController.text.trim(),
    );

    widget.onAdd(transaction);

    if (keepOpen) {
      setState(() {
        _amountStr = '0.00';
        _aiInputController.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _handleKeyTap(String key) {
    if (key == '完成') {
      _saveTransaction();
      return;
    }
    if (key == '再记') {
      _saveTransaction(keepOpen: true);
      return;
    }
    if (key == '⌫') {
      setState(() {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0.00';
        }
      });
      return;
    }

    setState(() {
      if (_amountStr == '0.00') {
        if (key == '.') {
          _amountStr = '0.';
        } else if (key == '+' || key == '-') {
          _amountStr = '0$key';
        } else {
          _amountStr = key;
        }
      } else {
        final lastChar = _amountStr[_amountStr.length - 1];

        if ((key == '+' || key == '-') &&
            (lastChar == '+' || lastChar == '-' || lastChar == '.')) {
          return;
        }

        if ((key == '+' || key == '-') &&
            (_amountStr.contains('+') || _amountStr.contains('-'))) {
          _evaluateMath();
        }

        if (key == '.') {
          final parts = _amountStr.split(RegExp(r'[+-]'));
          if (parts.last.contains('.')) return;
        }

        _amountStr += key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == CategoryType.expense
        ? expenseCategories
        : incomeCategories;
    if (_selectedCategory != null && !categories.contains(_selectedCategory)) {
      _selectedCategory = categories.isNotEmpty ? categories.first : null;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
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
          Expanded(
            child: _CategorySelectionComponent(
              selectedType: _selectedType,
              selectedCategory: _selectedCategory,
              onTypeChanged: (type) {
                setState(() {
                  _selectedType = type;
                });
              },
              onCategoryChanged: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),
          ),
          _CalculatorComponent(
            amount: _amountStr,
            aiController: _aiInputController,
            isAILoading: _isLoadingAI,
            onParseAI: _parseWithAI,
            onKeyTap: _handleKeyTap,
          ),
        ],
      ),
    );
  }
}
