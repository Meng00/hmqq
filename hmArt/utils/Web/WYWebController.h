//
//  WLWebController.h
//  WangliBank
//
//  Created by 王启镰 on 16/6/21.
//  Copyright © 2016年 iSoftstone infomation Technology (Group) Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMJSBaseView.h"
#import "LCAlertView.h"
#import "EasyJSWebView.h"
#import "LCJsInterface.h"
#import "EGORefreshTableHeaderView.h"

@interface WYWebController : HMJSBaseView<UIScrollViewDelegate, UIWebViewDelegate, EGORefreshTableHeaderDelegate>
{
    EGORefreshTableHeaderView * _refreshHeader;
    NSDate *_lastLoadDate;
    
    BOOL _reloading;
    
}


@property (nonatomic, copy) NSString *url;

@end
