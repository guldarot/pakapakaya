import 'package:flutter/material.dart';

import '../../../mocks/mock_data.dart';
import '../../../shared/widgets/app_scaffold.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Admin',
      child: ListView(
        children: [
          const Text(
            'Subscription plans',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...MockData.plans.map(
            (plan) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.code.name.toUpperCase(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('Items: ${plan.maxInventoryItems}'),
                    Text('Monthly orders: ${plan.maxMonthlyOrders}'),
                    const SizedBox(height: 8),
                    ...plan.features.map(Text.new),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Moderation, vendor review, and Barakat operations are intentionally left for the next implementation slice.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
