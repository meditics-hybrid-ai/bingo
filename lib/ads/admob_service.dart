import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdsService {
  bool get isEnabled;

  Future<void> initialize();
  BannerAd createBannerAd({required BannerAdListener listener});
  void loadGameOverInterstitial();
  void showGameOverInterstitial();
  void dispose();
}

class AdMobAdsService implements AdsService {
  static const String _androidBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _androidInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  InterstitialAd? _gameOverInterstitial;

  @override
  bool get isEnabled => !kIsWeb;

  @override
  Future<void> initialize() {
    if (kIsWeb) {
      return Future<void>.value();
    }
    return MobileAds.instance.initialize().then((_) {});
  }

  @override
  BannerAd createBannerAd({required BannerAdListener listener}) {
    return BannerAd(
      size: AdSize.banner,
      adUnitId: _bannerAdUnitId,
      listener: listener,
      request: const AdRequest(),
    );
  }

  @override
  void loadGameOverInterstitial() {
    if (kIsWeb) {
      return;
    }

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _gameOverInterstitial?.dispose();
          _gameOverInterstitial = ad;
        },
        onAdFailedToLoad: (_) {
          _gameOverInterstitial = null;
        },
      ),
    );
  }

  @override
  void showGameOverInterstitial() {
    final ad = _gameOverInterstitial;
    if (ad == null) {
      loadGameOverInterstitial();
      return;
    }

    _gameOverInterstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        loadGameOverInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        loadGameOverInterstitial();
      },
    );
    ad.show();
  }

  @override
  void dispose() {
    _gameOverInterstitial?.dispose();
    _gameOverInterstitial = null;
  }

  String get _bannerAdUnitId {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosBannerAdUnitId
        : _androidBannerAdUnitId;
  }

  String get _interstitialAdUnitId {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosInterstitialAdUnitId
        : _androidInterstitialAdUnitId;
  }
}

class NoOpAdsService implements AdsService {
  const NoOpAdsService();

  @override
  bool get isEnabled => false;

  @override
  BannerAd createBannerAd({required BannerAdListener listener}) {
    throw UnsupportedError('NoOpAdsService cannot create banner ads.');
  }

  @override
  void dispose() {}

  @override
  Future<void> initialize() async {}

  @override
  void loadGameOverInterstitial() {}

  @override
  void showGameOverInterstitial() {}
}
