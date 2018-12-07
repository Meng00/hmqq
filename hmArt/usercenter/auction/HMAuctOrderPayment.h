//
//  HMAuctOrderPayment.h
//  hmArt
//
//  Created by 刘学 on 15/7/12.
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

@interface HMAuctOrderPayment : HMInputController<UITextFieldDelegate>
{
    unsigned int _requestId;
    unsigned int _appPayRequestId;
    NSDictionary *dic;
    LCView *_topView;
    
    UITextField *_mobileField;
    UITextField *_userNameField;
    UITextField *_addrField;
    
    NSInteger _payType;
    NSDictionary *data;
    
    UIImageView *acpSelect;
    UIImageView *alipaySelect;
    UIImageView *weixinSelect;
    UIImageView *offlineSelect;
    
}

@property (copy , nonatomic) NSString *orderIds;
@property (nonatomic) NSInteger *amount;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;


@end
