//
//  HMSalesRequest.h
//  hmArt
//
//  Created by 刘学 on 15/7/20.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMInputController.h"
#import "HMUtility.h"
#import "HMGlobalParams.h"
#import "LCNetworkInterface.h"
#import "LCView.h"
#import "HMRecharge.h"
#import "LCWebView.h"
#import "LCAlertView.h"

@interface HMSalesRequest : HMInputController
{
    unsigned int _requestId;
    NSDictionary *dic;
    LCView *_topView;
    
    UITextField *_initPriceField;
    UITextField *_incrementField;
    
}

@property (nonatomic) NSInteger orderId;
@property (copy , nonatomic) NSString *artName;


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;


@end
