import 'dart:convert';

import 'package:ai_accounting/ai.dart';
import 'package:ai_accounting/const.dart';
import 'package:flutter/cupertino.dart';

void main() async {
  await testAIResponse();
}

const prompt = "早餐吃包子,12元";
Future<void> testAIResponse() async {
  try {
    debugPrint('正在调用AI接口...');
    final aiResponse = await chat(prompt);
    debugPrint('AI原始返回结果:\n$aiResponse');
    final Map<String, dynamic> billData = jsonDecode(aiResponse);

    final requiredFields = ['type', 'category', 'amount', 'date', 'remark'];
    for (final field in requiredFields) {
      if (!billData.containsKey(field) || billData[field] == null) {
        throw Exception('缺失必填字段:$field');
      }
    }

    final String type = billData['type'];
    if (type != 'expense' && type != 'income') {
      throw Exception('type字段值非法,仅允许 expense/income,实际值:$type');
    }

    final String categoryName = billData['category'];
    final List<String> validCategoryNames = type == 'expense'
        ? Category.expenses.map((e) => e.name).toList()
        : Category.incomes.map((e) => e.name).toList();
    if (!validCategoryNames.contains(categoryName)) {
      throw Exception(
        'category字段值非法,${type == "expense" ? "支出" : "收入"}类别仅允许:$validCategoryNames,实际值:$categoryName',
      );
    }
    final double amount = double.parse(billData['amount'].toString());
    final String amountStr = amount.toStringAsFixed(2);
    if (double.parse(amountStr) != amount) {
      throw Exception('amount字段未保留2位小数,实际值:$amount');
    }

    final String date = billData['date'];
    final RegExp dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(date)) {
      throw Exception('date字段格式非法(需YYYY-MM-DD),实际值:$date');
    }

    final String remark = billData['remark'];
    if (remark.length < 10 || remark.length > 50) {
      throw Exception('remark字段长度非法(10~50字),实际长度:${remark.length},内容:$remark');
    }

    debugPrint('\n✅ 测试通过!账单数据完全符合要求:');
    debugPrint('类型:${type == "expense" ? "支出" : "收入"}');
    debugPrint('类别:$categoryName');
    debugPrint('金额:$amount 元');
    debugPrint('日期:$date');
    debugPrint('备注:$remark');
  } catch (e) {
    debugPrint('\n❌ 测试失败:$e');
  }
}
