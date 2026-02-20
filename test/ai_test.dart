import 'dart:convert';

import 'package:ai_accounting/ai.dart';
import 'package:ai_accounting/const.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const prompt = "早餐吃包子,12元";

  group('AI接口核心功能测试', () {
    test('AI返回包含所有必填字段', () async {
      final aiResponse = await chat(prompt);
      final Map<String, dynamic> billData = jsonDecode(aiResponse);

      final requiredFields = ['type', 'category', 'amount', 'date', 'remark'];
      for (final field in requiredFields) {
        expect(billData.containsKey(field), true);
        expect(billData[field], isNotNull);
      }
    });

    test('type字段值为expense或income', () async {
      final aiResponse = await chat(prompt);
      final Map<String, dynamic> billData = jsonDecode(aiResponse);

      final String type = billData['type'];
      expect(['expense', 'income'].contains(type), true);
    });

    test('category字段值在合法类别范围内', () async {
      final aiResponse = await chat(prompt);
      final Map<String, dynamic> billData = jsonDecode(aiResponse);

      final String type = billData['type'];
      final String categoryName = billData['category'];
      final List<String> validCategoryNames = type == 'expense'
          ? Category.expenses.map((e) => e.name).toList()
          : Category.incomes.map((e) => e.name).toList();

      expect(validCategoryNames.contains(categoryName), true);
    });

    test('amount字段保留2位小数', () async {
      final aiResponse = await chat(prompt);
      final Map<String, dynamic> billData = jsonDecode(aiResponse);

      final double amount = double.parse(billData['amount'].toString());
      final String amountStr = amount.toStringAsFixed(2);

      expect(double.parse(amountStr), amount);
    });

    test('date字段格式为YYYY-MM-DD', () async {
      final aiResponse = await chat(prompt);
      final Map<String, dynamic> billData = jsonDecode(aiResponse);

      final String date = billData['date'];
      final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');

      expect(dateRegex.hasMatch(date), true);
    });

    test('remark字段长度在10~50字之间', () async {
      final aiResponse = await chat(prompt);
      final Map<String, dynamic> billData = jsonDecode(aiResponse);

      final String remark = billData['remark'];

      expect(remark.length, greaterThanOrEqualTo(10));
      expect(remark.length, lessThanOrEqualTo(50));
    });

    test('完整验证账单数据结构', () async {
      final aiResponse = await chat(prompt);
      final Map<String, dynamic> billData = jsonDecode(aiResponse);

      // 验证类型
      final String type = billData['type'];
      expect(['expense', 'income'].contains(type), true);

      // 验证类别
      final String categoryName = billData['category'];
      final List<String> validCategoryNames = type == 'expense'
          ? Category.expenses.map((e) => e.name).toList()
          : Category.incomes.map((e) => e.name).toList();
      expect(validCategoryNames.contains(categoryName), true);

      // 验证日期
      final String date = billData['date'];
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date), true);

      // 验证备注
      final String remark = billData['remark'];
      expect(remark.length, greaterThanOrEqualTo(10));
      expect(remark.length, lessThanOrEqualTo(50));
    });
  });
}
