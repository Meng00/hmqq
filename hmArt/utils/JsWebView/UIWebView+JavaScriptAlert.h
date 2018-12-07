//
//  UIWebView+JavaScriptAlert.h
//  lifeassistant
//
//  Created by wangyong on 15-6-9.
//
//

#import <UIKit/UIKit.h>

@interface UIWebView (JavaScriptAlert)<UIAlertViewDelegate>

- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame;
@end
