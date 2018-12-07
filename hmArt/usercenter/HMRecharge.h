//
//  HMRecharge.h
//  hmArt
//
//  Created by 刘学 on 15/7/27.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMInputController.h"
#import "HMUtility.h"
#import "HMGlobalParams.h"
#import "LCNetworkInterface.h"
#import "LCView.h"
#import "HMNetImageView.h"
#import "HMWebPay.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>

@interface HMRecharge : HMInputController
{
    unsigned int _requestId;
    NSDictionary *dic;
    LCView *_topView;
    
    UITextField *_amountField;
    NSInteger _payType;
    
    UIImageView *acpSelect;
    UIImageView *alipaySelect;
    UIImageView *weixinSelect;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
