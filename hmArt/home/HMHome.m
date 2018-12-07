//
//  HMHome.m
//  hmArt
//
//  Created by 刘学 on 16/9/21.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import "HMHome.h"

@interface HMHome ()

@end

@implementation HMHome

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.agentWeb.scrollView setShowsVerticalScrollIndicator:NO];
    self.agentWeb.scrollView.bounces = NO;
    
    CGRect agentFrame = self.agentWeb.frame;
    if(self.tabBarController.tabBar.hidden == NO){
        agentFrame.size.height = agentFrame.size.height - 48;
    }
    
    self.agentWeb.frame = agentFrame;
    
    _url = [NSString stringWithFormat:@"http://localhost/%@", @"mui/HMMain.html"];
//    _url = @"http://60.205.212.126:8090/art-interface/mui/HMHome.html";
//    _url = @"https://app.4008988518.com/art-interface/mui/HMHome.html";
    
//    _url = @"http://60.205.212.126:8090/art-interface/mui/page/HMMain.html";
    
    self.agentWeb.scrollView.delegate = self;
    [self loadPage];
    
    [self queryVersion];
    
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
    
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if(@available(iOS 11.0, *)){
        self.agentWeb.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden=NO;
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = nil;
    }
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

#pragma mark -
#pragma mark app version query
- (void)queryVersion
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestVersionId != 0) {
        [net cancelRequest:_requestVersionId];
    }
    NSString *url = [NSString stringWithFormat:@"%@&random=%f", interfaceQueryVersionInStore, [[NSDate date] timeIntervalSinceNow]];
    _requestVersionId = [net asynExternalRequest:url cached:NO target:self action:@selector(dealVersion:result:)];
}

- (void)dealVersion:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    _requestVersionId = 0;
    
    NSDictionary *ret = result.value;
    NSArray *results = [ret objectForKey:@"results"];
    if (!results || (results.count == 0)) {
        return;
    }
    NSDictionary *appInfo = [results objectAtIndex:0];
    NSString *version = [appInfo objectForKey:@"version"];
    NSString *appName = [appInfo objectForKey:@"trackName"];
    if (version && version.length > 0) {
        NSString *numberVer = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSDictionary *dictAppInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [dictAppInfo objectForKey:@"CFBundleShortVersionString"];
        NSString *appVerNum = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];//[dictAppInfo objectForKey:@"CFBundleVersion"];
        if ([numberVer integerValue] > [appVerNum integerValue]) {//app store版本号大于本地版本
            NSMutableString *tips = [NSMutableString stringWithFormat:@"%@V%@已发布",appName, version];
            [tips appendFormat:@"\n%@", [appInfo objectForKey:@"releaseNotes"]];
            [LCAlertView showWithTitle:@"升级提示" message:tips cancelTitle:@"稍后升级" cancelBlock:nil otherTitle:@"升级" otherBlock:^{[self upgradeApp];}];
        }else if([numberVer integerValue] == [appVerNum integerValue]){//两个版本号相同，本地是最新版本
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *localVerNum = [userDefaults stringForKey:LC_SYS_ID_BUILD_VER];
            if ((!localVerNum)  ||  ([appVerNum integerValue] > [localVerNum integerValue])) {
                [userDefaults setObject:appVersion forKey:LC_SYS_ID_APP_VERSION];
                [userDefaults setObject:appVerNum forKey:LC_SYS_ID_BUILD_VER];
                
                NSString *title = [NSString stringWithFormat:@"新版本特性(Ver%@)", appVersion];
                //每次发布更新时修改这个字符串
                NSString *newFeatures = [appInfo objectForKey:@"releaseNotes"];
                [LCAlertView showWithTitle:title message:newFeatures buttonTitle:@"确定"];
            }
        }
    }
    
}

- (void)upgradeApp
{
    NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", kAppStoreID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end

