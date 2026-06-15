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
  static const bool _forceTestAds = bool.fromEnvironment(
    'ADMOB_FORCE_TEST_ADS',
  );
  static const bool _forceProductionAds = bool.fromEnvironment(
    'ADMOB_FORCE_PRODUCTION_ADS',
  );

  static const String _androidTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _androidTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosTestInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  static const String _androidProductionBannerAdUnitId =
      'ca-app-pub-0000000000000000/0000000000';
  static const String _iosProductionBannerAdUnitId =
      'ca-app-pub-0000000000000000/0000000000';
  static const String _androidProductionInterstitialAdUnitId =
      'ca-app-pub-0000000000000000/0000000000';
  static const String _iosProductionInterstitialAdUnitId =
      'ca-app-pub-0000000000000000/0000000000';

  InterstitialAd? _gameOverInterstitial;

  @override
  bool get isEnabled => !kIsWeb;

  bool get _useTestAds {
    if (_forceTestAds) {
      return true;
    }
    if (_forceProductionAds) {
      return false;
    }
    return !kReleaseMode;
  }

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
    if (_useTestAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _iosTestBannerAdUnitId
          : _androidTestBannerAdUnitId;
    }

    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosProductionBannerAdUnitId
        : _androidProductionBannerAdUnitId;
  }

  String get _interstitialAdUnitId {
    if (_useTestAds) {
      return defaultTargetPlatform == TargetPlatform.iOS
          ? _iosTestInterstitialAdUnitId
          : _androidTestInterstitialAdUnitId;
    }

    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosProductionInterstitialAdUnitId
        : _androidProductionInterstitialAdUnitId;
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
