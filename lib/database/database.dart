import 'package:ai_accounting/const.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

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
    final result = await (select(transactions)
          ..where((t) => t.categoryType.equals(CategoryType.income.index)))
        .get();
    return result.fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  Future<double> getTotalExpense() async {
    final result = await (select(transactions)
          ..where((t) => t.categoryType.equals(CategoryType.expense.index)))
        .get();
    return result.fold<double>(0.0, (sum, t) => sum + t.amount);
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'ai_accounting',
    native: DriftNativeOptions(
      shareAcrossIsolates: true,
    ),
  );
}

final appDatabase = AppDatabase();
