import 'package:ai_accounting/const.dart';
import 'package:ai_accounting/database/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late TransactionsCompanion testTransaction;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    db = AppDatabase.inMemory();

    testTransaction = TransactionsCompanion(
      id: Value('test_001'),
      categoryName: Value('餐饮美食'),
      categoryIcon: Value(0),
      categoryType: Value(CategoryType.expense.index),
      amount: Value(50.0),
      transactionTime: Value(DateTime.now()),
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase 核心功能测试', () {
    test('插入并查询交易数据', () async {
      final insertId = await db.insertTransaction(testTransaction);
      expect(insertId, 1);
      final transactions = await db.getAllTransactions();
      expect(transactions.length, 1);
      expect(transactions.first.id, 'test_001');
      expect(transactions.first.amount, 50.0);
    });

    test('删除交易数据', () async {
      await db.insertTransaction(testTransaction);
      final deleteCount = await db.deleteTransaction('test_001');
      expect(deleteCount, 1);
      final transactions = await db.getAllTransactions();
      expect(transactions.isEmpty, true);
    });

    test('计算总收入/总支出', () async {
      final incomeTx = TransactionsCompanion(
        id: Value('test_002'),
        categoryName: Value('工资'),
        categoryIcon: Value(1),
        categoryType: Value(CategoryType.income.index),
        amount: Value(1000.0),
        transactionTime: Value(DateTime.now()),
      );
      final expenseTx = TransactionsCompanion(
        id: Value('test_003'),
        categoryName: Value('交通'),
        categoryIcon: Value(2),
        categoryType: Value(CategoryType.expense.index),
        amount: Value(200.0),
        transactionTime: Value(DateTime.now()),
      );

      await db.insertTransaction(incomeTx);
      await db.insertTransaction(expenseTx);
      final totalIncome = await db.getTotalIncome();
      final totalExpense = await db.getTotalExpense();
      expect(totalIncome, 1000.0);
      expect(totalExpense, 200.0);
    });

    test('TransactionEntity 转 Transaction 模型', () async {
      await db.insertTransaction(testTransaction);
      final entity = await db.getAllTransactions().then((list) => list.first);
      final transaction = AppDatabase.entityToTransaction(entity);

      expect(transaction.id, entity.id);
      expect(transaction.amount, entity.amount);
      expect(transaction.type, CategoryType.expense);
      expect(transaction.category.name, testTransaction.categoryName.value);
    });
  });
}
