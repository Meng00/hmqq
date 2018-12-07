//
//  HMUpgradeVIP.h
//  hmArt
//
//  Created by 刘学 on 15/7/14.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "HMUtility.h"
#import "HMGlobalParams.h"
#import "LCNetworkInterface.h"
#import "LCView.h"
#import "HMWebPay.h"
#import "WXApi.h"
#import "LCWebView.h"
#import <AlipaySDK/AlipaySDK.h>

@interface HMUpgradeVIP : UIViewController
{
    unsigned int _requestId;
    unsigned int _appPayRequestId;
    NSDictionary *dic;
    LCView *_topView;
    NSInteger _payType;
    NSDictionary *data;
    
    UIImageView *acpSelect;
    UIImageView *alipaySelect;
    UIImageView *weixinSelect;
    
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
