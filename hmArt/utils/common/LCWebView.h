//
//  LCWebView.h
//  lifeassistant
//
//  Created by wangyong on 14-2-22.
//
//

#import <UIKit/UIKit.h>
#import "HMUtility.h"
#import "LCAlertView.h"
#import "HMGlobal.h"
@interface LCWebView : UIViewController<UIWebViewDelegate>

@property (nonatomic) BOOL showHtml;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *html;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
@end
