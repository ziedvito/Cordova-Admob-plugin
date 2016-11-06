//Copyright (c) 2014 Sang Ki Kwon (Cranberrygame)
//Email: cranberrygame@yahoo.com
//Homepage: http://cranberrygame.github.io
//License: MIT (http://opensource.org/licenses/MIT)
#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
//
#import <GoogleMobileAds/GADAdSize.h>
#import <GoogleMobileAds/GADBannerView.h>
#import <GoogleMobileAds/GADInterstitial.h>
#import <GoogleMobileAds/GADBannerViewDelegate.h>
#import <GoogleMobileAds/GADInterstitialDelegate.h>
#import <GoogleMobileAds/GADExtras.h>

@protocol Plugin <NSObject>
- (UIWebView*) getWebView;
- (UIViewController*) getViewController;
- (id<CDVCommandDelegate>) getCommandDelegate;
- (NSString*) getCallbackIdKeepCallback;
@end

@protocol PluginDelegate <NSObject>
- (void) _setLicenseKey:(NSString *)email aLicenseKey:(NSString *)licenseKey;
- (void) _setUp:(NSString *)bannerAdUnit anInterstitialAdUnit:(NSString *)interstitialAdUnit anIsOverlap:(BOOL)isOverlap anIsTest:(BOOL)isTest;
- (void) _preloadBannerAd;
- (void) _showBannerAd:(NSString *)position aSize:(NSString *)size;
- (void) _reloadBannerAd;
- (void) _hideBannerAd;
- (void) _preloadInterstitialAd;
- (void) _showInterstitialAd;
@end

@interface Admob : CDVPlugin <Plugin, PluginDelegate>

@property NSString *callbackIdKeepCallback;
//
@property id<PluginDelegate> pluginDelegate;
//
@property NSString *email;
@property NSString *licenseKey_;
@property BOOL validLicenseKey;
	
- (void) setLicenseKey: (CDVInvokedUrlCommand*)command;
- (void) setUp: (CDVInvokedUrlCommand*)command;
- (void) preloadBannerAd: (CDVInvokedUrlCommand*)command;
- (void) showBannerAd: (CDVInvokedUrlCommand*)command;
- (void) reloadBannerAd: (CDVInvokedUrlCommand*)command;
- (void) hideBannerAd: (CDVInvokedUrlCommand*)command;
- (void) preloadInterstitialAd: (CDVInvokedUrlCommand*)command;
- (void) showInterstitialAd: (CDVInvokedUrlCommand*)command;

@end
