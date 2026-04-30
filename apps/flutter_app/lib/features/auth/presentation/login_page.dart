import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../application/auth_controller.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final selectedRole = ref.watch(selectedDemoRoleProvider);

    return AppScaffold(
      title: 'Welcome',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'PakaPakaya',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Micro-batch food discovery, trust-gated ordering, and privacy-first chat for the mohalla.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Demo phone number',
              hintText: 'Changes with the selected account below',
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'OTP code',
              hintText: '123456 (demo code)',
            ),
          ),
          const SizedBox(height: 16),
          SegmentedButton<UserRole>(
            segments: const [
              ButtonSegment(
                value: UserRole.user,
                icon: Icon(Icons.person_outline),
                label: Text('Buyer'),
              ),
              ButtonSegment(
                value: UserRole.vendor,
                icon: Icon(Icons.storefront_outlined),
                label: Text('Vendor'),
              ),
              ButtonSegment(
                value: UserRole.admin,
                icon: Icon(Icons.admin_panel_settings_outlined),
                label: Text('Admin'),
              ),
            ],
            selected: {selectedRole},
            onSelectionChanged: auth.isLoading
                ? null
                : (selection) => ref
                    .read(selectedDemoRoleProvider.notifier)
                    .state = selection.first,
          ),
          const SizedBox(height: 10),
          Text(
            switch (selectedRole) {
              UserRole.user => '+92 300 1234567 demo buyer',
              UserRole.vendor => '+92 300 9876543 demo vendor',
              UserRole.admin => '+92 311 1110000 demo admin',
            },
          ),
          if (auth.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                auth.errorMessage!,
                style: TextStyle(color: Colors.red.shade800),
              ),
            ),
          ],
          const Spacer(),
          FilledButton(
            onPressed: auth.isLoading
                ? null
                : () => ref.read(authControllerProvider.notifier).loginDemo(selectedRole),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(auth.isLoading ? 'Signing in...' : 'Continue with demo OTP'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
