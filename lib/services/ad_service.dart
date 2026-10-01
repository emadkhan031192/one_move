/// Isolated rewarded-ad integration point.
///
/// The core game never requires ads. When a real ad SDK is wired in later,
/// implement [showRewardedAd] and flip [isAvailable]; hint dialogs already
/// check this service before offering an ad-gated free hint.
class AdService {
  /// No ad SDK is bundled: rewarded ads are currently unavailable.
  bool get isAvailable => false;

  /// Shows a rewarded ad. Returns true when the reward was earned.
  Future<bool> showRewardedAd() async => false;
}
