//
//  HMSellerReg.h
//  hmArt
//
//  Created by 刘学 on 15/9/9.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMUtility.h"
#import "HMGlobalParams.h"
#import "LCNetworkInterface.h"
#import "LCView.h"

@interface HMSellerReg : UIViewController
{
    unsigned int _requestId;
    LCView *_reg;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
