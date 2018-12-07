//
//  WLWebController.m
//  WangliBank
//
//  Created by 王启镰 on 16/6/21.
//  Copyright © 2016年 iSoftstone infomation Technology (Group) Co.,Ltd. All rights reserved.
//

#import "WYWebController.h"
#import "WYWebProgressLayer.h"
#import "UIView+Frame.h"
#import "HMUtility.h"
#import "HMGlobal.h"

@interface WYWebController ()<UIWebViewDelegate>

@end

@implementation WYWebController
{
    UIWebView *_webView;
    
    WYWebProgressLayer *_progressLayer; ///< 网页加载进度条
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarController.tabBar.hidden=YES;
    
    [self setStatusBarBackgroundColor:[UIColor whiteColor]];
    if(@available(iOS 11.0, *)){
        self.agentWeb.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
    }else{
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    self.navigationController.navigationBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;//
    self.navigationController.navigationBar.barTintColor = [UIColor greenColor];//改变statusBar的背景色
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_white_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    self.navigationController.navigationBar.tintColor = [UIColor grayColor];//导航栏返回按钮颜色
    
    if(@available(iOS 11.0, *)){
        
    }else{
        CGRect agentFrame = self.agentWeb.frame;
        agentFrame.size.height = agentFrame.size.height + 48;
        self.agentWeb.frame = agentFrame;
        
    }
    
    [self setupUI];
    
}
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}



- (void)setupUI {

    _progressLayer = [WYWebProgressLayer new];
    _progressLayer.frame = CGRectMake(0, 42, SCREEN_WIDTH, 2);
    
    [self.navigationController.navigationBar.layer addSublayer:_progressLayer];
    [self loadFromUrl:_url inWeb:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    _webUrl = [_webUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //
    NSRange searchResult = [_webUrl rangeOfString:@"?"];
    if (searchResult.location != NSNotFound) {
        NSString *params = [_webUrl substringFromIndex:(searchResult.location + 1)];
        NSDictionary *dicParam = [HMUtility parametersWithSeparator:@"=" delimiter:@"&" url:params];
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:dicParam options:NSJSONWritingPrettyPrinted error:nil];
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        _urlParams = str;
        NSString *title = [dicParam objectForKey:@"title"];
        if(title){
            self.title = title;
        }
    }
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    //[self setStatusBarBackgroundColor: nil];
    [super viewWillDisappear: animated];
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_progressLayer startLoad];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_progressLayer finishedLoad];
//    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_progressLayer finishedLoad];
}

- (void)dealloc {
    
    [_progressLayer closeTimer];
    [_progressLayer removeFromSuperlayer];
    _progressLayer = nil;
    NSLog(@"i am dealloc");
}

@end
