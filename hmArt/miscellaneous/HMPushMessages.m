//
//  HMMy.m
//  hmArt
//
//  Created by 刘学 on 16/10/10.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import "HMPushMessages.h"

@interface HMPushMessages ()

@end

@implementation HMPushMessages

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.agentWeb.scrollView setShowsVerticalScrollIndicator:NO];
    self.agentWeb.scrollView.bounces = NO;
    
    CGRect agentFrame = self.agentWeb.frame;
    if(self.tabBarController.tabBar.hidden == NO){
        agentFrame.size.height = agentFrame.size.height - 48;
    }
    self.agentWeb.frame = agentFrame;
    
    
    _url = [NSString stringWithFormat:@"http://localhost/%@", @"mui/member/HMPush_list.html"];
    self.agentWeb.scrollView.delegate = self;
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
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden=NO;
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

- (void)loadPage
{
    [self loadFromUrl:_url inWeb:nil];
}


#pragma mark -
#pragma mark webview delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}



#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}


@end
