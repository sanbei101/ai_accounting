import 'package:flutter/material.dart';

enum CategoryType {
  expense, // 支出
  income, // 收入
}

class AppCategory {
  final String name;
  final IconData icon;
  final CategoryType type;

  const AppCategory({
    required this.name,
    required this.icon,
    required this.type,
  });
}

const List<AppCategory> expenseCategories = [
  AppCategory(name: '餐饮美食', icon: Icons.restaurant, type: CategoryType.expense),
  AppCategory(
    name: '交通出行',
    icon: Icons.directions_car,
    type: CategoryType.expense,
  ),
  AppCategory(
    name: '日用百货',
    icon: Icons.local_grocery_store,
    type: CategoryType.expense,
  ),
  AppCategory(
    name: '购物消费',
    icon: Icons.shopping_bag,
    type: CategoryType.expense,
  ),
  AppCategory(name: '居家生活', icon: Icons.home, type: CategoryType.expense),
  AppCategory(
    name: '休闲娱乐',
    icon: Icons.sports_esports,
    type: CategoryType.expense,
  ),
  AppCategory(
    name: '医疗健康',
    icon: Icons.local_hospital,
    type: CategoryType.expense,
  ),
  AppCategory(
    name: '通讯话费',
    icon: Icons.phone_android,
    type: CategoryType.expense,
  ),
  AppCategory(name: '教育学习', icon: Icons.school, type: CategoryType.expense),
  AppCategory(
    name: '人情往来',
    icon: Icons.card_giftcard,
    type: CategoryType.expense,
  ),
  AppCategory(name: '美容美发', icon: Icons.spa, type: CategoryType.expense),
  AppCategory(name: '其他支出', icon: Icons.more_horiz, type: CategoryType.expense),
];

const List<AppCategory> incomeCategories = [
  AppCategory(
    name: '工资薪酬',
    icon: Icons.account_balance_wallet,
    type: CategoryType.income,
  ),
  AppCategory(
    name: '奖金奖励',
    icon: Icons.attach_money,
    type: CategoryType.income,
  ),
  AppCategory(name: '投资理财', icon: Icons.trending_up, type: CategoryType.income),
  AppCategory(name: '兼职副业', icon: Icons.work, type: CategoryType.income),
  AppCategory(name: '报销款', icon: Icons.receipt_long, type: CategoryType.income),
  AppCategory(name: '其他收入', icon: Icons.more_horiz, type: CategoryType.income),
];
