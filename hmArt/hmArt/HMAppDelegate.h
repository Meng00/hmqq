//
//  HMAppDelegate.h
//  hmArt
//
//  Created by wangyong on 13-6-16.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "LCNetworkInterface.h"
#import "LCWebView.h"
#import "HMUserCenter.h"
#import "HMAuctionArea.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboApi.h"
#import "WXApi.h"
#import "HMJSWebView.h"
#import "HMPushMessages.h"
#import "HMAuctionRecords.h"
#import "WYWebController.h"
#import "HMStore.h"
#import "HMViewController.h"
#import "HMJsViewController.h"
#import <AlipaySDK/AlipaySDK.h>

@interface HMAppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>
{
    NSInteger _currentIndex;
    
    unsigned int _requestPushNewsId;
    unsigned int _requestLoginId;
    BOOL _inBackground;

    NSString *_gRandom;

}
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) IBOutlet UITabBarController *rootController;

- (NSString *)getRandomString;
@end
