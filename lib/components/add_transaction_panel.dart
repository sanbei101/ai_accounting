import 'dart:convert';

import 'package:ai_accounting/ai.dart';
import 'package:ai_accounting/const.dart';
import 'package:ai_accounting/database/database.dart';
import 'package:ai_accounting/providers.dart';
import 'package:ai_accounting/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _CategorySelectionComponent extends ConsumerWidget {
  const _CategorySelectionComponent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelState = ref.watch(addPanelProvider);
    final categories = panelState.categories;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              _ExpenseIncomeTab(type: CategoryType.expense, label: '支出'),
              const SizedBox(width: 8),
              _ExpenseIncomeTab(type: CategoryType.income, label: '收入'),
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
                isSelected: panelState.selectedCategory == category,
                onTap: () =>
                    ref.read(addPanelProvider.notifier).setCategory(category),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ExpenseIncomeTab extends ConsumerWidget {
  final CategoryType type;
  final String label;

  const _ExpenseIncomeTab({required this.type, required this.label});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref.watch(addPanelProvider).selectedType == type;
    return GestureDetector(
      onTap: () => ref.read(addPanelProvider.notifier).setType(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colorScheme.primaryContainer.withAlpha(150)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
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

class _CalculatorSection extends ConsumerWidget {
  final Function({bool keepOpen}) onSave;
  final VoidCallback onParseAI;
  const _CalculatorSection({required this.onSave, required this.onParseAI});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final panelState = ref.watch(addPanelProvider);

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
                      panelState.amount,
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
            _RemarkInput(onParseAI: onParseAI),
            _Keypad(onSave: onSave),
          ],
        ),
      ),
    );
  }
}

class _RemarkInput extends ConsumerStatefulWidget {
  final VoidCallback onParseAI;

  const _RemarkInput({required this.onParseAI});

  @override
  ConsumerState<_RemarkInput> createState() => _RemarkInputState();
}

class _RemarkInputState extends ConsumerState<_RemarkInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(addPanelProvider).remark,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panelState = ref.watch(addPanelProvider);

    return Padding(
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
              controller: _controller,
              decoration: InputDecoration(
                hintText: '点击填写备注信息 支持AI智能记账)',
                hintStyle: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant.withAlpha(150),
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) =>
                  ref.read(addPanelProvider.notifier).setRemark(value),
            ),
          ),
          IconButton(
            onPressed: panelState.isAILoading ? null : widget.onParseAI,
            icon: panelState.isAILoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.auto_awesome, color: context.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class _Keypad extends ConsumerWidget {
  final Function({bool keepOpen}) onSave;

  const _Keypad({required this.onSave});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void handleInput(String text) {
      ref.read(addPanelProvider.notifier).handleKeyTap(text);
    }

    return Container(
      color: context.colorScheme.surfaceContainerHighest.withAlpha(100),
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Row(
            children: [
              _Key('1', onTap: () => handleInput('1')),
              _Key('2', onTap: () => handleInput('2')),
              _Key('3', onTap: () => handleInput('3')),
              _Key(
                '⌫',
                isIcon: true,
                icon: Icons.backspace_outlined,
                onTap: () => handleInput('delete'),
              ),
            ],
          ),
          Row(
            children: [
              _Key('4', onTap: () => handleInput('4')),
              _Key('5', onTap: () => handleInput('5')),
              _Key('6', onTap: () => handleInput('6')),
              _Key('+', onTap: () => handleInput('+')),
            ],
          ),
          Row(
            children: [
              _Key('7', onTap: () => handleInput('7')),
              _Key('8', onTap: () => handleInput('8')),
              _Key('9', onTap: () => handleInput('9')),
              _Key('-', onTap: () => handleInput('-')),
            ],
          ),
          Row(
            children: [
              _Key('再记', onTap: () => onSave.call(keepOpen: true)),
              _Key('0', onTap: () => handleInput('0')),
              _Key('.', onTap: () => handleInput('.')),
              _Key(
                '完成',
                isPrimary: true,
                onTap: () => onSave.call(keepOpen: false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isPrimary;
  final bool isIcon;
  final IconData? icon;

  const _Key(
    this.text, {
    required this.onTap,
    this.isPrimary = false,
    this.isIcon = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: isPrimary
              ? context.colorScheme.primary
              : context.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
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

class AddTransactionPanel extends ConsumerStatefulWidget {
  final ValueChanged<Transaction> onAdd;

  const AddTransactionPanel({super.key, required this.onAdd});

  @override
  ConsumerState<AddTransactionPanel> createState() =>
      _AddTransactionPanelState();
}

class _AddTransactionPanelState extends ConsumerState<AddTransactionPanel> {
  Future<void> _parseWithAI() async {
    final input = ref.read(addPanelProvider).remark.trim();
    if (input.isEmpty) return;

    ref.read(addPanelProvider.notifier).setAILoading(true);

    try {
      final response = await chat(input);
      final data = jsonDecode(response) as Map<String, dynamic>;
      final transaction = Transaction.fromJson(data);

      ref.read(addPanelProvider.notifier)
        ..setAILoading(false)
        ..setType(transaction.type)
        ..setCategory(transaction.category)
        ..setAmount(transaction.amount.toStringAsFixed(2));
    } catch (e) {
      ref.read(addPanelProvider.notifier).setAILoading(false);
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
    }
  }

  void _saveTransaction({bool keepOpen = false}) {
    final panelState = ref.read(addPanelProvider);
    final amount = ref.read(evaluatedAmountProvider);

    if (amount <= 0 || panelState.selectedCategory == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('提示'),
          content: Text(
            panelState.selectedCategory == null ? '请先选择一个分类哦' : '请输入大于0的有效金额',
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
      category: panelState.selectedCategory!,
      type: panelState.selectedType,
      amount: amount,
      dateTime: DateTime.now(),
      remark: panelState.remark.trim(),
    );

    widget.onAdd(transaction);

    if (keepOpen) {
      ref.read(addPanelProvider.notifier).reset();
    } else {
      Navigator.pop(context);
    }
  }

  Widget dragHandle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: context.colorScheme.onSurfaceVariant.withAlpha(100),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          dragHandle(context),
          const Expanded(child: _CategorySelectionComponent()),
          _CalculatorSection(onSave: _saveTransaction, onParseAI: _parseWithAI),
        ],
      ),
    );
  }
}
