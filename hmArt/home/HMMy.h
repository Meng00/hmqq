//
//  HMMy.h
//  hmArt
//
//  Created by 刘学 on 16/10/10.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMJSBaseView.h"
#import "LCAlertView.h"
#import "EasyJSWebView.h"
#import "LCJsInterface.h"
#import "EGORefreshTableHeaderView.h"

@interface HMMy :  HMJSBaseView<UIScrollViewDelegate, UIWebViewDelegate>
{
    
    
}

@property (nonatomic, copy) NSString *url;

@end
