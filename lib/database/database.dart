import 'package:ai_accounting/const.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

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

@DataClassName('TransactionEntity')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get categoryName => text()();
  IntColumn get categoryIcon => integer()();
  IntColumn get categoryType => integer()();
  RealColumn get amount => real()();
  DateTimeColumn get transactionTime => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<TransactionEntity>> getAllTransactions() =>
      select(transactions).get();

  Stream<List<TransactionEntity>> watchAllTransactions() =>
      select(transactions).watch();

  Future<int> insertTransaction(TransactionsCompanion entry) =>
      into(transactions).insert(entry);

  Future<int> deleteTransaction(String id) =>
      (delete(transactions)..where((t) => t.id.equals(id))).go();

  Future<double> getTotalIncome() async {
    final sumExpr = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([sumExpr])
      ..where(transactions.categoryType.equals(CategoryType.income.index));

    final result = await query
        .map((row) => row.read(sumExpr) ?? 0.0)
        .getSingle();
    return result;
  }

  Future<double> getTotalExpense() async {
    final sumExpr = transactions.amount.sum();
    final query = selectOnly(transactions)
      ..addColumns([sumExpr])
      ..where(transactions.categoryType.equals(CategoryType.expense.index));

    final result = await query
        .map((row) => row.read(sumExpr) ?? 0.0)
        .getSingle();
    return result;
  }

  static final Map<(CategoryType, String), Category> _categoryMap = () {
    final map = <(CategoryType, String), Category>{};
    for (final c in Category.expenses) {
      map[(CategoryType.expense, c.name)] = c;
    }
    for (final c in Category.incomes) {
      map[(CategoryType.income, c.name)] = c;
    }
    return map;
  }();

  static Transaction entityToTransaction(TransactionEntity entity) {
    final categoryType = CategoryType.values[entity.categoryType];

    final category =
        _categoryMap[(categoryType, entity.categoryName)] ??
        Category.otherExpense;

    return Transaction(
      id: entity.id,
      category: category,
      type: categoryType,
      amount: entity.amount,
      dateTime: entity.transactionTime,
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'ai_accounting',
    native: DriftNativeOptions(shareAcrossIsolates: true),
  );
}

final appDatabase = AppDatabase();
