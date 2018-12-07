
//
//  LCJsWebViewEx.h
//  hmArt
//
//  Created by 刘学 on 16/1/9.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//


#import "LCJsBaseView.h"
#import "LCAlertView.h"
#import "EasyJSWebView.h"
#import "LCJsInterface.h"
#import "EGORefreshTableHeaderView.h"

@interface LCJsWebViewEx  : LCJsBaseView <UIScrollViewDelegate, UIWebViewDelegate, EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView * _refreshHeader;
    NSDate *_lastLoadDate;
    
    BOOL _reloading;
    
}

@property (nonatomic, copy) NSString *url;

@end
