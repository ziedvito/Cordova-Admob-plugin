//Copyright (c) 2014 Sang Ki Kwon (Cranberrygame)
//Email: cranberrygame@yahoo.com
//Homepage: http://cranberrygame.github.io
//License: MIT (http://opensource.org/licenses/MIT)
#import "AdmobOverlap.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonDigest.h> //md5

@implementation AdmobOverlap

@synthesize plugin;
//
@synthesize bannerAdUnit;
@synthesize interstitialAdUnit;
@synthesize isOverlap;
@synthesize isTest;
//
@synthesize bannerPreviousPosition;
@synthesize bannerPreviousSize;
@synthesize lastOrientation;
//
@synthesize bannerAdPreload;	
@synthesize fullScreenAdPreload;
//admob
@synthesize bannerView;
@synthesize interstitialView;

/*
- (CDVPlugin *) initWithWebView:(UIWebView *)theWebView {
    self = (Admob *)[super initWithWebView:theWebView];
    if (self) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(deviceOrientationChangeAdmob:)
         name:UIDeviceOrientationDidChangeNotification
         object:nil];
    }
    return self;
}
*/

- (void) deviceOrientationChangeAdmob:(NSNotification *)notification {
    if (bannerView != nil) {
/*	
        CGRect bannerFrame = bannerView.frame;
        if (bannerFrame.origin.y != 0)
        {
            bannerFrame.origin.y = self.webView.frame.size.width - bannerView.frame.size.height;
        }
        bannerFrame.origin.x = self.webView.frame.size.height * 0.5f - bannerView.frame.size.width * 0.5f;
        bannerView.frame = bannerFrame;
*/
    }
}

- (bool) _isLandscape {
    bool landscape = NO;
        
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if (UIInterfaceOrientationIsLandscape(currentOrientation)) {
        landscape = YES;
    }
    return landscape;
}

- (id) initWithPlugin:(id<Plugin>)plugin_{
    self = [super init];
    if (self) {
		self.plugin = plugin_;
    }
    return self;
}	

- (void) _setLicenseKey:(NSString *)email aLicenseKey:(NSString *)licenseKey {
}

- (void) _setUp:(NSString *)bannerAdUnit anInterstitialAdUnit:(NSString *)interstitialAdUnit anIsOverlap:(BOOL)isOverlap anIsTest:(BOOL)isTest {
	self.bannerAdUnit = bannerAdUnit;
	self.interstitialAdUnit = interstitialAdUnit;
	self.isOverlap = isOverlap;
	self.isTest = isTest;	
}

- (void) _preloadBannerAd {
	self.bannerAdPreload = YES;

	[self _hideBannerAd];
	
    [self loadBannerAd];
}

- (void) loadBannerAd {
	//
    if (bannerView == nil) {	
		if(self.bannerPreviousSize == nil) {
			self.bannerPreviousSize = @"SMART_BANNER";
		}	
		GADAdSize adSize = kGADAdSizeBanner;
		//https://developers.google.com/mobile-ads-sdk/docs/admob/android/banner			
		if ([self.bannerPreviousSize isEqualToString:@"BANNER"]) {
			adSize = kGADAdSizeBanner;//Banner (320x50, Phones and Tablets)
		} 
		else if ([self.bannerPreviousSize isEqualToString:@"LARGE_BANNER"]) {
			adSize = kGADAdSizeLargeBanner;//Large banner (320x100, Phones and Tablets)
		}
		else if ([self.bannerPreviousSize isEqualToString:@"MEDIUM_RECTANGLE"]) {
			adSize = kGADAdSizeMediumRectangle;//Medium rectangle (300x250, Phones and Tablets)
		}
		else if ([self.bannerPreviousSize isEqualToString:@"FULL_BANNER"]) {
			adSize = kGADAdSizeFullBanner;//Full banner (468x60, Tablets)
		}
		else if ([self.bannerPreviousSize isEqualToString:@"LEADERBOARD"]) {
			adSize = kGADAdSizeLeaderboard;//Leaderboard (728x90, Tablets)
		}
		else if ([self.bannerPreviousSize isEqualToString:@"SKYSCRAPER"]) {
			adSize = kGADAdSizeSkyscraper;//Skyscraper (120x600, Tablets)
		}		
		else if ([self.bannerPreviousSize isEqualToString:@"SMART_BANNER"]) {
			if([self _isLandscape]) {
				adSize = kGADAdSizeSmartBannerLandscape;//Smart banner (Auto size, Phones and Tablets) //https://developers.google.com/mobile-ads-sdk/docs/admob/android/banner#smart
			}
			else {
				adSize = kGADAdSizeSmartBannerPortrait;
			}			
		}
		else {
			if([self _isLandscape]) {
				adSize = kGADAdSizeSmartBannerLandscape;
			}
			else {
				adSize = kGADAdSizeSmartBannerPortrait;
			}			
		}		
	
		bannerView = [[GADBannerView alloc] initWithAdSize:adSize];
        //
		bannerView.adUnitID = self.bannerAdUnit;
		bannerView.delegate = self;
		bannerView.rootViewController = [self.plugin getViewController];//
	}

	GADRequest *request = [GADRequest request];
    //Note: Starting in SDK version 7.0.0, simulators will automatically show test ads.
    //https://developers.google.com/admob/ios/targeting
    if (self.isTest) {
		NSUUID* adid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        request.testDevices =
        [NSArray arrayWithObjects:
        // TODO: Add your device/simulator test identifiers here. They are printed to the console when the app is launched.
        [self md5:adid.UUIDString],
        nil];
    }
	[self.bannerView loadRequest:request];	
}

- (NSString*) md5:(NSString*) input {
	const char *cStr = [input UTF8String];
	unsigned char digest[16];
	CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call

	NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];

	for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
	[output appendFormat:@"%02x", digest[i]];

	return  output;
}

- (void) _showBannerAd:(NSString *)position aSize:(NSString *)size {
	
	if ([self bannerIsShowingOverlap] && [position isEqualToString:self.bannerPreviousPosition] && [size isEqualToString:self.bannerPreviousSize]) {
		return;
	}
	
	self.bannerPreviousPosition = position;
	self.bannerPreviousSize = size;

	if(bannerAdPreload) {
		bannerAdPreload = NO;
	}
	else{
		[self _hideBannerAd];
		
		[self loadBannerAd];
	}
			
	[self addBannerViewOverlap:position aSize:size];

	CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"onBannerAdShown"];
	[pr setKeepCallbackAsBool:YES];
	[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
	//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
	//[pr setKeepCallbackAsBool:YES];
	//[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];	
}

- (BOOL) bannerIsShowingOverlap {
	//
	BOOL bannerIsShowing = NO;
	if (bannerView != nil) {
		//if banner is showing			
		//if ([bannerView isDescendantOfView:webView]) {
		UIView* webView = [bannerView superview];
		if (webView != nil) {
			bannerIsShowing = YES;
		}
	}

	return bannerIsShowing;
}

- (void) addBannerViewOverlap:(NSString*)position aSize:(NSString*)size {
/*
	//http://tigerwoods.tistory.com/11
	//http://developer.android.com/reference/android/widget/RelativeLayout.html
	//http://stackoverflow.com/questions/24900725/admob-banner-poitioning-in-android-on-bottom-of-the-screen-using-no-xml-relative
	RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(AdView.LayoutParams.WRAP_CONTENT, AdView.LayoutParams.WRAP_CONTENT);
	if (position.equals("top-left")) {
		Log.d("Admob", "top-left");		
		params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
		params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);		
	}
	else if (position.equals("top-center")) {		
		params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
		params.addRule(RelativeLayout.CENTER_HORIZONTAL);
	}
	else if (position.equals("top-right")) {		
		params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
		params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
	}
	else if (position.equals("left")) {
		params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);
		params.addRule(RelativeLayout.CENTER_VERTICAL);			
	}
	else if (position.equals("center")) {
		params.addRule(RelativeLayout.CENTER_HORIZONTAL);	
		params.addRule(RelativeLayout.CENTER_VERTICAL);	
	}
	else if (position.equals("right")) {	
		params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
		params.addRule(RelativeLayout.CENTER_VERTICAL);	
	}
	else if (position.equals("bottom-left")) {		
		params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);		
		params.addRule(RelativeLayout.ALIGN_PARENT_LEFT);		
	}
	else if (position.equals("bottom-center")) {
		
		params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		params.addRule(RelativeLayout.CENTER_HORIZONTAL);
	}
	else if (position.equals("bottom-right")) {
		params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
		params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);
	}
	else {		
		params.addRule(RelativeLayout.ALIGN_PARENT_TOP);
		params.addRule(RelativeLayout.CENTER_HORIZONTAL);
	}
	
	//bannerViewLayout.addView(bannerView, params);
	bannerView.setLayoutParams(params);
	bannerViewLayout.addView(bannerView);
*/
///*
	CGRect bannerFrame = bannerView.frame;
	if ([position isEqualToString:@"top-center"]) {		    
		bannerFrame.origin.y = 0;
	}
	else {
		bannerFrame.origin.y = [self.plugin getWebView].frame.size.height - bannerView.frame.size.height;
	}
	bannerFrame.origin.x = [self.plugin getWebView].frame.size.width * 0.5f - bannerView.frame.size.width * 0.5f;
	bannerView.frame = bannerFrame;
	//https://developer.apple.com/library/ios/documentation/uikit/reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/cl/UIView
	[[self.plugin getWebView] addSubview:bannerView];
//*/
/*
     CGFloat width = [self.plugin getWebView].bounds.size.width;
     CGFloat height = [self.plugin getWebView].bounds.size.height;
     if ([position isEqualToString:@"top-center"]) {
        bannerView.frame = CGRectMake(0, 0, width, 50);
     }
     else {
        bannerView.frame = CGRectMake(0, height - 50, width, 50);
     }
     //bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
     [[self.plugin getWebView] addSubview:bannerView];
*/
}

- (void) _reloadBannerAd {
    [self loadBannerAd];
}

- (void) _hideBannerAd {
	[self _removeBannerViewOverlap];
	
	CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"onBannerAdHidden"];
	[pr setKeepCallbackAsBool:YES];
	[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
	//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
	//[pr setKeepCallbackAsBool:YES];
	//[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];	
}

- (void)_removeBannerViewOverlap {
    if (bannerView == nil)
		return;
		
	//[self.bannerView removeFromSuperview];		
	//if banner is showing
	UIView* webView = [bannerView superview];
	if (webView != nil) {
		//https://developer.apple.com/library/ios/documentation/uikit/reference/UIView_Class/UIView/UIView.html#//apple_ref/occ/cl/UIView
		[self.bannerView removeFromSuperview];
		bannerView = nil;
	}
}

- (void) _preloadInterstitialAd {    
	self.fullScreenAdPreload = YES;	
	
	[self loadinterstitialAd];
}

- (void) loadinterstitialAd {
    if (interstitialView == nil || self.interstitialView.hasBeenUsed){//ios only //An interstitial object can only be used once for ios
        self.interstitialView = [[GADInterstitial alloc] init];
        //
		self.interstitialView.adUnitID = interstitialAdUnit;
        self.interstitialView.delegate = self;
    }	
	
	GADRequest *request = [GADRequest request];
    if (self.isTest) {
        NSUUID* adid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        request.testDevices =
        [NSArray arrayWithObjects:
        // TODO: Add your device/simulator test identifiers here. They are printed to the console when the app is launched.
        [self md5:adid.UUIDString],
        nil];
    }
	[self.interstitialView loadRequest:request];
}

- (void) _showInterstitialAd {
	if(fullScreenAdPreload) {
		fullScreenAdPreload = NO;

		[self.interstitialView presentFromRootViewController:[self.plugin getViewController]];
	}
	else{	
		[self loadinterstitialAd];
	}		
}

//GADBannerViewDelegate

- (void) adViewDidReceiveAd:(GADBannerView *)view {
	NSLog(@"adViewDidReceiveAd");

	if(bannerAdPreload) {
		CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"onBannerAdPreloaded"];
		[pr setKeepCallbackAsBool:YES];
		[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
		//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		//[pr setKeepCallbackAsBool:YES];
		//[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
	}
	
	CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"onBannerAdLoaded"];	
	[pr setKeepCallbackAsBool:YES];
	[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
	//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
	//[pr setKeepCallbackAsBool:YES];
	//[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
	
	bannerView.hidden = NO;
}

- (void) adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
	NSLog(@"adView: %@",error.description);
	bannerView.hidden = YES;
}

- (void) adViewWillLeaveApplication:(GADBannerView *)adView {
	NSLog(@"adViewWillLeaveApplication");
}

- (void) adViewWillPresentScreen:(GADBannerView *)adView {
	NSLog(@"adViewWillPresentScreen");//click and ad opened //onBannerAdShown x
}

- (void) adViewWillDismissScreen:(GADBannerView *)adView {
	NSLog(@"adViewWillDismissScreen");
}

- (void)adViewDidDismissScreen:(GADBannerView *)adView {
	NSLog(@"adViewDidDismissScreen");//onBannerAdHidden x
}

//GADInterstitialDelegate

- (void) interstitialDidReceiveAd:(GADInterstitial *)ad {
	NSLog(@"interstitialDidReceiveAd");
	
	if(fullScreenAdPreload) {
		CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"onInterstitialAdPreloaded"];
		[pr setKeepCallbackAsBool:YES];
		[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
		//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
		//[pr setKeepCallbackAsBool:YES];
		//[self.commandDelegate sendPluginResult:pr callbackId:self.callbackIdKeepCallback];			
	}
	
	CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"onInterstitialAdLoaded"];
	[pr setKeepCallbackAsBool:YES];
	[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
	//CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
	//[pr setKeepCallbackAsBool:YES];
	//[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
	
	if(!fullScreenAdPreload) {
		[self.interstitialView presentFromRootViewController:[self.plugin getViewController]];
	}
}

- (void) interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
	NSLog(@"interstitial: %@",error.description);
}

- (void) interstitialWillLeaveApplication:(GADInterstitial *)ad {
	NSLog(@"interstitialWillLeaveApplication");
}

- (void) interstitialWillPresentScreen:(GADInterstitial *)ad {
	NSLog(@"interstitialWillPresentScreen");
	
    CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"onInterstitialAdShown"];
	[pr setKeepCallbackAsBool:YES];
	[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
    //CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
	//[pr setKeepCallbackAsBool:YES];
	//[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
}

- (void) interstitialWillDismissScreen:(GADInterstitial *)ad {
	NSLog(@"interstitialWillDismissScreen");
}

- (void) interstitialDidDismissScreen:(GADInterstitial *)ad {
	NSLog(@"interstitialDidDismissScreen");
	
    CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"onInterstitialAdHidden"];
	[pr setKeepCallbackAsBool:YES];
	[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
    //CDVPluginResult* pr = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
	//[pr setKeepCallbackAsBool:YES];
	//[[self.plugin getCommandDelegate] sendPluginResult:pr callbackId:[self.plugin getCallbackIdKeepCallback]];
}

- (void) dealloc {
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
}

@end
