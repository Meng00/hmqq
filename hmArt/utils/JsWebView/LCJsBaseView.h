//
//  LCJsBaseView.h
//  vip
//
//  Created by wangyong on 15/9/16.
//  Copyright (c) 2015年 Beijing Unicom. All rights reserved.
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

@interface LCJsBaseView : UIViewController<UIWebViewDelegate,MFMessageComposeViewControllerDelegate, LCJsInterfaceDelegate,HMJsLoginDelegate>
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
