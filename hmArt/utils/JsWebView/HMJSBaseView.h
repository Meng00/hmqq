//
//  HMJSBaseView.h
//  hmArt
//
//  Created by 刘学 on 16/1/25.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EasyJSWebView.h"
#import "LCJsInterface.h"
#import "LCNetworkInterface.h"
#import "HMUtility.h"
#import "LCAlertView.h"
#import "EasyJSDataFunction.h"
#import "HMLoginEx.h"
#import "EGORefreshTableHeaderView.h"
#import <AudioToolbox/AudioToolbox.h>
#import "LCActionSheet.h"
#import <AVFoundation/AVFoundation.h>
#import <ShareSDK/ShareSDK.h>

@interface HMJSBaseView : UIViewController<UIWebViewDelegate,MFMessageComposeViewControllerDelegate, LCJsInterfaceDelegate,HMJsLoginDelegate>
{
    
    EasyJSDataFunction * _rightButFunc;
    //    EasyJSDataFunction * _authCodeFunc;
    EasyJSDataFunction * _scanQrcodeFunc;
    EasyJSDataFunction * _locateFunc;
    EasyJSDataFunction *_shakeMotionFunc;
    
    unsigned int _requestWebAppId;
    unsigned int _requestId;
    NSString *_appEntrance;
    NSString *_webUrl;
    
    BOOL _tabBarHidden;
    
    //EasyJSWebView *_agentWeb;
    
    NSTimer *_timer;
    
    BOOL _isShaking;
    
    NSString *_urlParams;
    
}


@property (strong, nonatomic) EasyJSWebView *agentWeb;

- (void)loadFromUrl:(NSString *)toUrl inWeb:(UIWebView *)webView;


- (void)loadFromCode:(NSString *)serviceCode withParams:(NSString *)urlParams inWeb:(UIWebView *)webView;

- (void)refreshPage;


@end
