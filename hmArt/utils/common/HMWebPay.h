//
//  HMWebPay.h
//  hmArt
//
//  Created by 刘学 on 15/7/12.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMGlobal.h"
#import "HMUtility.h"

@interface HMWebPay : UIViewController<UIWebViewDelegate,NSURLConnectionDelegate>
{
    
}

@property (nonatomic) NSInteger type;
@property (nonatomic, copy) NSString *payOrderSerial;

@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
