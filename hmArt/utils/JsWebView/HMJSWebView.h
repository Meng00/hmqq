//
//  HMJSWebView.h
//  hmArt
//
//  Created by 刘学 on 16/1/25.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import "HMJSBaseView.h"
#import "LCAlertView.h"
#import "EasyJSWebView.h"
#import "LCJsInterface.h"
#import "EGORefreshTableHeaderView.h"

@interface HMJSWebView : HMJSBaseView<UIScrollViewDelegate, UIWebViewDelegate, EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView * _refreshHeader;
    NSDate *_lastLoadDate;
    
    BOOL _reloading;
    
}

@property (nonatomic, copy) NSString *url;

@end
