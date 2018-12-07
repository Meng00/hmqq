//
//  HMJsViewController.m
//  hmArt
//
//  Created by 刘学 on 2018/1/28.
//  Copyright © 2018年 hanmoqianqiu. All rights reserved.
//

#import "HMJsViewController.h"

@interface HMJsViewController ()

@end

@implementation HMJsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarController.tabBar.hidden=YES;
    NSLog(@"Y: %f", self.view.frame.origin.y);
    
     [self loadPage];
}

-(void) initPage {
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
            [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
            if(@available(iOS 11.0, *)){
                self.agentWeb.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
            }else{
                self.automaticallyAdjustsScrollViewInsets = YES;
            }
            self.navigationController.navigationBarHidden = NO;
        }else{
            if(@available(iOS 11.0, *)){
                self.agentWeb.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }else{
                self.automaticallyAdjustsScrollViewInsets = NO;
            }
            self.navigationController.navigationBarHidden = YES;
            
        }
    }else{
        if(@available(iOS 11.0, *)){
            self.agentWeb.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        self.navigationController.navigationBarHidden = YES;
    }
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self initPage];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
    
    NSLog(@"Y0: %f", self.view.frame.origin.y);
    NSLog(@"Y1: %f", self.agentWeb.frame.origin.y);
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewWillDisappear:animated];
}

- (void)loadPage
{
    [self loadFromUrl:_url inWeb:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.isLoading) {
        NSString *str = [NSString stringWithFormat:@"javascript:var appParams=%@;", _urlParams];
        [webView stringByEvaluatingJavaScriptFromString:str];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
