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

const aiPrompt = """
请你模拟生成一条账单记录,严格按照以下要求输出JSON格式的内容(仅输出JSON字符串,无任何多余文字):

1. 字段规范:
   - type:账单类型,仅允许取值 'expense'(支出)或 'income'(收入)
   - category:账单类别名称,必须与以下列表严格匹配:
     支出类别:餐饮美食、交通出行、日用百货、购物消费、居家生活、休闲娱乐、医疗健康、通讯话费、教育学习、人情往来、美容美发、其他支出
     收入类别:工资薪酬、奖金奖励、投资理财、兼职副业、报销款、其他收入
    - amount:金额,数值类型(保留2位小数)
   - date:日期,格式为 'YYYY-MM-DD'(例如 2024-06-01)
   - remark:备注,字符串类型(10~50字,简要描述账单原因)

2. 逻辑约束:
   - category 必须与 type 匹配(支出类别对应 type=expense,收入类别对应 type=income)
   - 所有字段不可缺失、不可为空

示例输出:
{"type":"expense","category":"餐饮美食","amount":89.90,"date":"2024-06-01","remark":"晚餐和朋友吃火锅,人均89.9元"}
""";
