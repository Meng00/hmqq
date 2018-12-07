//
//  LCJsWebViewEx.m
//  vip
//
//  Created by wangyong on 15/9/17.
//  Copyright (c) 2015年 Beijing Unicom. All rights reserved.
//

#import "LCJsWebViewEx.h"

@interface LCJsWebViewEx ()

@end

@implementation LCJsWebViewEx

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self.virtualWeb setScalesPageToFit:YES];
    // Do any additional setup after loading the view from its nib.
    //[self initMyWeb];
    
    //增加下拉刷新区
    self.agentWeb.scrollView.delegate = self;
    if (_refreshHeader == nil) {
        _refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -self.agentWeb.bounds.size.height, self.agentWeb.bounds.size.width, self.agentWeb.bounds.size.height)];
        _refreshHeader.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        _refreshHeader.delegate = self;
        [self.agentWeb.scrollView addSubview:_refreshHeader];
    }
    [self loadPage];
    
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
    self.navigationController.navigationBarHidden = NO;
    if (self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = NO;
    }
//    if([self respondsToSelector:@selector(edgesForExtendedLayout)]){
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        //UIRectEdgeNone or UIRectEdgeAll
//        //UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;
//        [self setEdgesForExtendedLayout:UIRectEdgeNone];
//        self.automaticallyAdjustsScrollViewInsets=YES;
//    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillDisappear:animated];
}

- (void)loadPage
{
    _lastLoadDate = [NSDate date];
    //NSString *url = [NSString stringWithFormat:@"%@",url];
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
    if (!self.title ||  [self.title isEqualToString:@""]) {
        self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
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
