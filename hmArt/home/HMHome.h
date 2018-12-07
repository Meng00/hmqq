//
//  HMHome.h
//  hmArt
//
//  Created by 刘学 on 16/9/21.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import "HMJSBaseView.h"
#import "LCAlertView.h"
#import "EasyJSWebView.h"
#import "LCJsInterface.h"
#import "EGORefreshTableHeaderView.h"

@interface HMHome : HMJSBaseView<UIScrollViewDelegate, UIWebViewDelegate>
{
    
    unsigned int _requestVersionId;
    
}

@property (nonatomic, copy) NSString *url;

@end
