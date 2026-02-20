import 'package:ai_accounting/const.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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

  factory Transaction.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = typeStr == 'expense'
        ? CategoryType.expense
        : CategoryType.income;

    final categoryName = json['category'] as String;
    final category =
        AppDatabase.categoryMap[(type, categoryName)] ?? Category.otherExpense;
    final amount = double.parse(json['amount'].toString());
    final dateStr = json['date'] as String;
    final dateTime = DateTime.parse(dateStr);

    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: category,
      type: type,
      amount: amount,
      dateTime: dateTime,
    );
  }
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
  AppDatabase.inMemory() : super(inMemoryConnection.executor);

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

  static final Map<(CategoryType, String), Category> categoryMap = () {
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
        categoryMap[(categoryType, entity.categoryName)] ??
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

DatabaseConnection get inMemoryConnection {
  return DatabaseConnection(NativeDatabase.memory());
}

final appDatabase = AppDatabase();
