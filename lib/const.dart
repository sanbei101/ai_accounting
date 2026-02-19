import 'package:flutter/material.dart';

enum CategoryType {
  expense, // 支出
  income, // 收入
}

enum Category {
  // 支出类别
  food(name: '餐饮美食', icon: Icons.restaurant, type: CategoryType.expense),
  transport(
    name: '交通出行',
    icon: Icons.directions_car,
    type: CategoryType.expense,
  ),
  groceries(
    name: '日用百货',
    icon: Icons.local_grocery_store,
    type: CategoryType.expense,
  ),
  shopping(name: '购物消费', icon: Icons.shopping_bag, type: CategoryType.expense),
  homeLiving(name: '居家生活', icon: Icons.home, type: CategoryType.expense),
  entertainment(
    name: '休闲娱乐',
    icon: Icons.sports_esports,
    type: CategoryType.expense,
  ),
  medical(name: '医疗健康', icon: Icons.local_hospital, type: CategoryType.expense),
  phone(name: '通讯话费', icon: Icons.phone_android, type: CategoryType.expense),
  education(name: '教育学习', icon: Icons.school, type: CategoryType.expense),
  gifts(name: '人情往来', icon: Icons.card_giftcard, type: CategoryType.expense),
  beauty(name: '美容美发', icon: Icons.spa, type: CategoryType.expense),
  otherExpense(
    name: '其他支出',
    icon: Icons.more_horiz,
    type: CategoryType.expense,
  ),

  // 收入类别
  salary(
    name: '工资薪酬',
    icon: Icons.account_balance_wallet,
    type: CategoryType.income,
  ),
  bonus(name: '奖金奖励', icon: Icons.attach_money, type: CategoryType.income),
  investment(name: '投资理财', icon: Icons.trending_up, type: CategoryType.income),
  partTime(name: '兼职副业', icon: Icons.work, type: CategoryType.income),
  reimbursement(
    name: '报销款',
    icon: Icons.receipt_long,
    type: CategoryType.income,
  ),
  otherIncome(name: '其他收入', icon: Icons.more_horiz, type: CategoryType.income);

  final String name;
  final IconData icon;
  final CategoryType type;

  const Category({required this.name, required this.icon, required this.type});

  static List<Category> get expenses =>
      Category.values.where((c) => c.type == CategoryType.expense).toList();

  static List<Category> get incomes =>
      Category.values.where((c) => c.type == CategoryType.income).toList();
}
