import 'package:flutter/material.dart';
import '../../domain/models/ad_placement.dart';
import '../../services/monetization_service.dart';
import '../theme/app_theme.dart';

class BannerAdWidget extends StatelessWidget {
  final AdPlacement placement;
  final MonetizationService? monetizationService;

  const BannerAdWidget({
    super.key,
    required this.placement,
    this.monetizationService,
  });

  @override
  Widget build(BuildContext context) {
    final service = monetizationService;
    if (service != null && service.adsRemoved) {
      return const SizedBox.shrink(); // Hidden if ads removed
    }

    return Container(
      width: double.infinity,
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ads_click_rounded, color: AppTheme.secondary, size: 18),
            SizedBox(width: 8),
            Text(
              'Ad Banner Container (Ad-Free with Remove Ads)',
              style: TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
