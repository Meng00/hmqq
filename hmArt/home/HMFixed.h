//
//  HMFixed.h
//  hmArt
//
//  Created by 刘学 on 16/9/21.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "HMJSBaseView.h"
#import "LCAlertView.h"
#import "EasyJSWebView.h"
#import "LCJsInterface.h"
#import "EGORefreshTableHeaderView.h"

@interface HMFixed : HMJSBaseView<UIScrollViewDelegate, UIWebViewDelegate>
{
    
    
}

@property (nonatomic, copy) NSString *url;

@end
