//
//  HMJSWebView.m
//  hmArt
//
//  Created by 刘学 on 16/1/25.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import "HMJSWebView.h"

@interface HMJSWebView ()

@end

@implementation HMJSWebView

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self.virtualWeb setScalesPageToFit:YES];
    // Do any additional setup after loading the view from its nib.
    //[self initMyWeb];
    self.tabBarController.tabBar.hidden=YES;
    NSLog(@"Y: %f", self.view.frame.origin.y);
    //增加下拉刷新区

   
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewWillDisappear:animated];
}

- (void)loadPage
{
    _lastLoadDate = [NSDate date];
    [self loadFromUrl:_url inWeb:nil];
}


#pragma mark -
#pragma mark webview delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    _reloading = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    _reloading = NO;
    if (_refreshHeader) {
        [_refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:webView.scrollView];
    }
//    if (!self.title ||  [self.title isEqualToString:@""]) {
//        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    }
    if (!webView.isLoading) {
        NSString *str = [NSString stringWithFormat:@"javascript:var appParams=%@;", _urlParams];
        [webView stringByEvaluatingJavaScriptFromString:str];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _reloading = NO;
    if (_refreshHeader) {
        [_refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:webView.scrollView];
    }
}



#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeader egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [_refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_refreshHeader refreshLastUpdatedDate];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    [self refreshPage];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    //    return [NSDate date]; // should return date data source was last changed
    NSDate *returnDate = [NSDate dateWithTimeInterval:0 sinceDate:_lastLoadDate];
    _lastLoadDate = [NSDate date];
    return returnDate;
}


@end

