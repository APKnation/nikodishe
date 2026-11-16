import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/network/api_config.dart';

import 'package:http/http.dart' as http;

// Provider that tracks backend connectivity
final backendStatusProvider = StreamProvider<bool>((ref) async* {
  yield* Stream.periodic(
    const Duration(seconds: 15),
    (_) => _checkBackend(),
  ).asyncMap((f) => f);
});

Future<bool> _checkBackend() async {
  try {
    final response = await http
        .get(Uri.parse(ApiConfig.healthUrl))
        .timeout(const Duration(seconds: 3));
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

class BackendStatusBanner extends ConsumerWidget {
  const BackendStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(backendStatusProvider);

    return status.when(
      data: (isOnline) {
        if (isOnline) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          color: AppColors.amberDark,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: AppColors.onColor, size: 15),
              SizedBox(width: 6),
              Text(
                'Mtandao wa seva haupati — data ya ndani inaonekana',
                style: TextStyle(
                  color: AppColors.onColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
