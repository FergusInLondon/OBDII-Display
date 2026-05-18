import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/obd_provider.dart';
import '../../transport/mock_transport.dart';
import '../theme/app_theme.dart';

class ScanScreen extends ConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Adapter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_searching, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            Text(
              'Searching for adapters...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () async {
                // Use MockTransport for now
                final transport = MockTransport();
                ref.read(transportStateNotifierProvider.notifier).setTransport(transport);

                final elm = ref.read(elm327ControllerProvider);
                final obd = ref.read(obdServiceProvider);

                await transport.connect();
                await elm.initialize();
                await obd.discoverSupportedPids();

                final profile = ref.read(activeProfileProvider);
                obd.startPolling(profile.stripSlots + [profile.primaryGauge, if(profile.secondaryGauge != null) profile.secondaryGauge!]);

                if (context.mounted) {
                  context.go('/dashboard');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('CONNECT TO MOCK ADAPTER'),
            ),
          ],
        ),
      ),
    );
  }
}
