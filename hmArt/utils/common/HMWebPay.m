//
//  HMWebPay.m
//  hmArt
//
//  Created by 刘学 on 15/7/12.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMWebPay.h"

@interface HMWebPay ()

@end
@implementation NSURLRequest (NSURLRequestWithIgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end

@implementation HMWebPay



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    CGRect rect = _webView.frame;
//    if (IOS7) {
//        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 29;
//    }else{
//        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 49;
//    }
    _webView.frame = rect;
    
//    // 左侧返回按钮，便于处理返回
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"web_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonDown:)];
//    self.navigationItem.leftBarButtonItem = backButton;
    
    [self loadWebPageWithString];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    self.navigationController.navigationBarHidden = NO;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)backButtonDown:(id)sender
{
    
    if ([_webView canGoBack]) {
        [_webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)loadWebPageWithString
{
    NSString *payUrl = [NSString stringWithFormat:@"https://%@payment/submit.htm?type=%i&paySerialNo=%@",HM_SYS_SERVER_URL,_type,_payOrderSerial];
    NSURL *url =[NSURL URLWithString:payUrl];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

//;开始加载的时候执行该方法。
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}

//;加载完成的时候执行该方法。
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[HMUtility tap2Action:@"网页打开失败，重新尝试" on:self.view target:self action:@selector(loadWebPageWithString)];
}


- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    NSLog(@"处理证书");
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if (YES) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    } else {
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [self setActivity:nil];
    [super viewDidUnload];
}


@end
