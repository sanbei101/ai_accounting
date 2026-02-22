import 'package:ai_accounting/const.dart';
import 'package:ai_accounting/database/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseProvider = Provider<AppDatabase>((ref) => appDatabase);

final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllTransactions().map(
    (entities) =>
        entities.map(AppDatabase.entityToTransaction).toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime)),
  );
});

final totalsProvider = Provider<(double income, double expense)>((ref) {
  final transactions = ref.watch(transactionsProvider).value ?? [];

  final income = transactions
      .where((t) => t.type == CategoryType.income)
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  final expense = transactions
      .where((t) => t.type == CategoryType.expense)
      .fold<double>(0.0, (sum, t) => sum + t.amount);

  return (income, expense);
});

String _evaluateMath(String amount) {
  try {
    if (amount.contains('+')) {
      final parts = amount.split('+');
      if (parts.length == 2 && parts[1].isNotEmpty) {
        final sum =
            (double.tryParse(parts[0]) ?? 0) + (double.tryParse(parts[1]) ?? 0);
        return sum.toStringAsFixed(2);
      }
    } else if (amount.contains('-')) {
      final parts = amount.split('-');
      if (parts.length == 2 && parts[1].isNotEmpty) {
        final diff =
            (double.tryParse(parts[0]) ?? 0) - (double.tryParse(parts[1]) ?? 0);
        return diff.toStringAsFixed(2);
      }
    }
  } catch (_) {}
  return amount;
}

final evaluatedAmountProvider = Provider<double>((ref) {
  final amount = ref.watch(addPanelProvider).amount;
  final evaluated = _evaluateMath(amount);
  return double.tryParse(evaluated) ?? 0;
});

@immutable
class AddPanelState {
  final CategoryType selectedType;
  final Category? selectedCategory;
  final String amount;
  final String remark;
  final bool isAILoading;

  const AddPanelState({
    this.selectedType = CategoryType.expense,
    this.selectedCategory,
    this.amount = '0.00',
    this.remark = '',
    this.isAILoading = false,
  });

  List<Category> get categories => selectedType == CategoryType.expense
      ? expenseCategories
      : incomeCategories;

  AddPanelState copyWith({
    CategoryType? selectedType,
    Category? selectedCategory,
    String? amount,
    String? remark,
    bool? isAILoading,
  }) {
    return AddPanelState(
      selectedType: selectedType ?? this.selectedType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      amount: amount ?? this.amount,
      remark: remark ?? this.remark,
      isAILoading: isAILoading ?? this.isAILoading,
    );
  }
}

class AddPanelNotifier extends Notifier<AddPanelState> {
  @override
  AddPanelState build() {
    state = const AddPanelState().copyWith(
      selectedCategory: expenseCategories.first,
    );
    return state;
  }

  void setType(CategoryType type) {
    final newCategory = type == CategoryType.expense
        ? expenseCategories.first
        : incomeCategories.first;
    state = state.copyWith(selectedType: type, selectedCategory: newCategory);
  }

  void setCategory(Category category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setRemark(String remark) {
    state = state.copyWith(remark: remark);
  }

  void setAILoading(bool loading) {
    state = state.copyWith(isAILoading: loading);
  }

  void setAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  void handleKeyTap(
    String key,
    VoidCallback onSave,
    VoidCallback onSaveAndNew,
  ) {
    if (key == '完成') {
      onSave();
      return;
    }
    if (key == '再记') {
      onSaveAndNew();
      return;
    }
    if (key == '⌫') {
      _backspace();
      return;
    }

    _appendKey(key);
  }

  void _backspace() {
    if (state.amount.length > 1) {
      state = state.copyWith(
        amount: state.amount.substring(0, state.amount.length - 1),
      );
    } else {
      state = state.copyWith(amount: '0.00');
    }
  }

  void _appendKey(String key) {
    var newAmount = state.amount;
    if (newAmount == '0.00') {
      if (key == '.') {
        newAmount = '0.';
      } else if (key == '+' || key == '-') {
        newAmount = '0$key';
      } else {
        newAmount = key;
      }
    } else {
      final lastChar = newAmount[newAmount.length - 1];

      if ((key == '+' || key == '-') &&
          (lastChar == '+' || lastChar == '-' || lastChar == '.')) {
        return;
      }

      if ((key == '+' || key == '-') &&
          (newAmount.contains('+') || newAmount.contains('-'))) {
        newAmount = _evaluateMath(newAmount);
      }

      if (key == '.') {
        final parts = newAmount.split(RegExp(r'[+-]'));
        if (parts.last.contains('.')) return;
      }

      newAmount += key;
    }

    state = state.copyWith(amount: newAmount);
  }

  void reset() {
    state = state.copyWith(
      amount: '0.00',
      remark: '',
      selectedCategory: state.selectedType == CategoryType.expense
          ? expenseCategories.first
          : incomeCategories.first,
    );
  }
}

final addPanelProvider = NotifierProvider<AddPanelNotifier, AddPanelState>(
  AddPanelNotifier.new,
);
