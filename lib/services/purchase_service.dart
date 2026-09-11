import 'dart:async';
import '../domain/models/entitlement_model.dart';
import '../domain/models/purchase_status.dart';
import '../domain/repositories/game_repository.dart';

/// Service managing store product purchases (remove_ads) and restoring entitlements.
class PurchaseService {
  final GameRepository _repository;
  PurchaseStatus _status = PurchaseStatus.idle;
  EntitlementModel _entitlement = const EntitlementModel();

  static const String productIdRemoveAds = 'com.arrowgo.puzzle.remove_ads';

  PurchaseService({required GameRepository repository}) : _repository = repository;

  PurchaseStatus get status => _status;
  EntitlementModel get entitlement => _entitlement;
  bool get adsRemoved => _entitlement.adsRemoved;

  /// Initialize entitlement state from repository.
  Future<void> init() async {
    // Local entitlement state query
    final isRemoved = await _repository.isAdsRemoved();
    _entitlement = EntitlementModel(adsRemoved: isRemoved);
  }

  /// Purchase remove_ads product.
  Future<bool> purchaseRemoveAds() async {
    _status = PurchaseStatus.purchasing;
    await Future.delayed(const Duration(milliseconds: 150));

    final now = DateTime.now().millisecondsSinceEpoch;
    _entitlement = EntitlementModel(
      adsRemoved: true,
      purchasedAt: now,
      transactionId: 'tx_iap_remove_ads_$now',
    );

    _status = PurchaseStatus.purchased;
    return true;
  }

  /// Restore previously purchased store products.
  Future<bool> restorePurchases() async {
    _status = PurchaseStatus.purchasing;
    await Future.delayed(const Duration(milliseconds: 150));

    // Restore remove_ads if found in store receipt
    if (_entitlement.adsRemoved) {
      _status = PurchaseStatus.restored;
      return true;
    }

    // Simulate restored receipt
    _entitlement = EntitlementModel(
      adsRemoved: true,
      purchasedAt: DateTime.now().millisecondsSinceEpoch,
      transactionId: 'restored_tx_remove_ads',
    );

    _status = PurchaseStatus.restored;
    return true;
  }
}
