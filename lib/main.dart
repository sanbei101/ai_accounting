import 'package:ai_accounting/theme.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 记账'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.person)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: context.colorScheme.primaryContainer,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '本月结余',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '¥ 12,580.00',
                      style: context.textTheme.headlineLarge?.copyWith(
                        color: context.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: context.colorScheme.secondaryContainer,
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        size: 16,
                                        color: context
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '收入',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: context
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '¥ 8,200.00',
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          color: context
                                              .colorScheme
                                              .onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            color: context.colorScheme.secondaryContainer,
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        size: 16,
                                        color: context
                                            .colorScheme
                                            .onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '支出',
                                        style: context.textTheme.bodySmall
                                            ?.copyWith(
                                              color: context
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '¥ 5,620.00',
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(
                                          color: context
                                              .colorScheme
                                              .onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('最近账单', style: context.textTheme.titleLarge),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(
                      Icons.restaurant,
                      color: context.colorScheme.primary,
                    ),
                    title: const Text('餐饮美食'),
                    subtitle: const Text('今天 12:30'),
                    trailing: Text(
                      '- ¥ 35.00',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.error,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('记一笔'),
      ),
    );
  }
}
