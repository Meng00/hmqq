//
//  HMViewController.m
//  hmArt
//
//  Created by 刘学 on 2018/1/13.
//  Copyright © 2018年 hanmoqianqiu. All rights reserved.
//

#import "HMViewController.h"
#import <WebKit/WebKit.h>

@interface HMViewController () <WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate>

@property (nonatomic,strong) WKWebView *webView;
@property (nonatomic,strong) UIProgressView *progressView;
@property (nonatomic,strong) UIBarButtonItem *leftBarButton;
@property (nonatomic,strong) UIBarButtonItem *leftBarButtonSecond;
@property (nonatomic,strong) UIBarButtonItem *negativeSpacer;
@property (nonatomic,strong) UIBarButtonItem *negativeSpacer2;
@property (nonatomic) BOOL refresh;

@end

@implementation HMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    self.tabBarController.tabBar.hidden=YES;
    
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
    self.webView.backgroundColor = [UIColor clearColor];
    
    [self LoadRequest];
    self.refresh = NO;
    [self addObserver];
    [self setBarButtonItem];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    if(@available(iOS 11.0, *)){
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationController.navigationBarHidden = YES;
    
    if(self.refresh){
        [self.webView reload];
    }else{
        if(![HMGlobalParams sharedInstance].anonymous){
            [self.webView evaluateJavaScript:[NSString stringWithFormat:@"sessionStorage.setItem('loginToken', '%@')", [HMGlobalParams sharedInstance].loginToken] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                
            }];
        }
    }
    self.refresh = NO;
    
    
}

#pragma mark 加载网页
- (void)LoadRequest
{
    //TODO:加载
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}
#pragma mark 添加KVO观察者
- (void)addObserver
{
    //TODO:kvo监听，获得页面title和加载进度值，以及是否可以返回
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark 设置BarButtonItem
- (void)setBarButtonItem
{
    
    //设置距离左边屏幕的宽度距离
    self.leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back_item.png"] style:UIBarButtonItemStylePlain target:self action:@selector(selectedToBack)];
    self.negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
    self.negativeSpacer.width = -5;
    
    //设置关闭按钮，以及关闭按钮和返回按钮之间的距离
    self.leftBarButtonSecond = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"close_item"] style:UIBarButtonItemStylePlain target:self action:@selector(selectedToClose)];
    self.leftBarButtonSecond.imageInsets = UIEdgeInsetsMake(0, -20, 0, 20);
    self.navigationItem.leftBarButtonItems = @[self.negativeSpacer,self.leftBarButton];
    
    
    //设置刷新按妞
    UIBarButtonItem *reloadItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"reload_item"] style:UIBarButtonItemStylePlain target:self action:@selector(selectedToReloadData)];
    self.navigationItem.rightBarButtonItem = reloadItem;
    
}
#pragma mark 关闭并返回上一界面
- (void)selectedToClose
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 返回上一个网页还是上一个Controller
- (void)selectedToBack
{
    if (self.webView.canGoBack == 1)
    {
        [self.webView goBack];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark reload
- (void)selectedToReloadData
{
    [self.webView reload];
}

#pragma mark - lazy
-(WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 设置偏好设置
        config.preferences = [[WKPreferences alloc] init];
        // 默认为0
        config.preferences.minimumFontSize = 10;
        // 默认认为YES
        config.preferences.javaScriptEnabled = YES;
        // 在iOS上默认为NO，表示不能自动通过窗口打开
        config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
        // web内容处理池
        config.processPool = [[WKProcessPool alloc] init];
        // 通过JS与webview内容交互
        config.userContentController = [[WKUserContentController alloc] init];
        // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
        // 我们可以在WKScriptMessageHandler代理中接收到
        [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
        _webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 22, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-22) configuration:config];
        
        // 设置代理
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
    }
    return _webView;
}


-(UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [_progressView setFrame:CGRectMake(0, 21, self.view.frame.size.width, 1)];
        
        //设置进度条颜色
        [_progressView setTintColor:[UIColor colorWithRed:0.400 green:0.863 blue:0.133 alpha:1.000]];
        //_progressView.hidden = YES;
    }
    return _progressView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    //加载进度值
    if ([keyPath isEqualToString:@"estimatedProgress"])
    {
        if (object == self.webView)
        {
            [self.progressView setAlpha:1.0f];
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
            if(self.webView.estimatedProgress >= 1.0f)
            {
                [UIView animateWithDuration:1.5f
                                      delay:0.0f
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [self.progressView setAlpha:0.0f];
                                 }
                                 completion:^(BOOL finished) {
                                     [self.progressView setProgress:0.0f animated:NO];
                                 }];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    //网页title
    else if ([keyPath isEqualToString:@"title"])
    {
        if (object == self.webView)
        {
            self.navigationItem.title = self.webView.title;
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    //是否可以返回
    else if ([keyPath isEqualToString:@"canGoBack"])
    {
        if (object == self.webView)
        {
            if (self.webView.canGoBack == 1)
            {
                self.navigationItem.leftBarButtonItems = @[self.negativeSpacer,self.leftBarButton,self.leftBarButtonSecond];
            }
            else
            {
                self.navigationItem.leftBarButtonItems = @[self.negativeSpacer,self.leftBarButton];
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - WKNavigationDelegate
// 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //NSLog(@"页面开始加载");
   
}
// 加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //NSLog(@"加载完成");
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    //NSLog(@"当内容开始返回时调用");
    if(![HMGlobalParams sharedInstance].anonymous){
        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"sessionStorage.setItem('loginToken', '%@')", [HMGlobalParams sharedInstance].loginToken] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            
        }];
//        [self.webView evaluateJavaScript:[NSString stringWithFormat:@"setLoginToken('%@')", [HMGlobalParams sharedInstance].loginToken] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
//            
//        }];
    }
}
// 内容加载失败时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    //NSLog(@"页面加载超时");
    [self selectedToBack];
}
//跳转失败的时候调用
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    //NSLog(@"跳转失败");
    [self selectedToBack];
}
//服务器开始请求的时候调用
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //NSLog(@"在发送请求之前，决定是否跳转");
    NSURL *url = navigationAction.request.URL;
    NSString *scheme = [url scheme];
    NSLog(@"url: %@", [url absoluteString]);
    
    if ([scheme isEqualToString:@"appaction"]) {
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if ([scheme isEqualToString:@"hmqq-app"]) {
        [self handleCustomAction:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if ([scheme isEqualToString:@"tel"]) {
        
        LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:@"致电咨询" phone:[[url absoluteString] substringFromIndex:4] type:0 name:@"咨询" cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
        [actionSheet showPhonecall:self.tabBarController.tabBar];
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if([[url path] isEqualToString:@"/art-interface/mui/HMHome.html"]){
        [self selectedToClose];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }else if([[url path] isEqualToString:@"/art-interface/mui/HMHome.do"]){
        [self selectedToClose];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }if ([scheme isEqualToString:@"hmqq-jsweb"]) {
        
        NSString *httpUrl=[url absoluteString];
        HMJsViewController *web = [[HMJsViewController alloc] initWithNibName:nil bundle:nil];
        web.url = [httpUrl stringByReplacingOccurrencesOfString:@"hmqq-jsweb" withString:@"http"];
        [self.navigationController pushViewController:web animated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark - private method
- (void)handleCustomAction:(NSURL *)url
{
    NSString *host = [url host];
    NSLog(@"Host: %@", [url host]);
    NSLog(@"Port: %@", [url port]);
    NSLog(@"Path: %@", [url path]);
    NSLog(@"Relative path: %@", [url relativePath]);
    NSLog(@"Query: %@", [url query]);
    
    if ([host isEqualToString:@"Login"]) {
        //登录
        HMLoginEx *ctrl = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
    
}

#pragma mark - WKScriptMessageHandler
// 从web界面中接收到一个脚本时调用
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"AppModel"]) {
        NSLog(@"%@",message.body);
        NSString *method = [message.body objectForKey:@"method"];
        if([method isEqualToString:@"close"]){
            //关闭
            [self selectedToClose];
            
        }else if([method isEqualToString:@"goBack"]){
            //返回
            [self selectedToBack];
            
        }else if([method isEqualToString:@"refresh"]){
            //开启回退刷新页面
            self.refresh = YES;
        }else if([method isEqualToString:@"toLogin"]){
            //登录
            HMLoginEx *ctrl = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
            
        }else if([method isEqualToString:@"saveImage"]){
            //保存图片
            NSString *imgUrl = [message.body objectForKey:@"image"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
            UIImage *image = [UIImage imageWithData:data];
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
            [LCAlertView showWithTitle:nil message:@"图片保存成功！" buttonTitle:@"确认"];
        }else if([method isEqualToString:@"share"]){
            //分享
            NSString *title = [message.body objectForKey:@"title"];
            NSString *content = [message.body objectForKey:@"content"];
            NSString *image = [message.body objectForKey:@"image"];
            NSString *url = [message.body objectForKey:@"url"];
            NSString *Result = [message.body objectForKey:@"Result"];
            
            id<ISSContent> publishContent = [ShareSDK content:content
                                               defaultContent:content
                                                        image:[ShareSDK imageWithUrl:image]
                                                        title:title
                                                          url:url
                                                  description:content
                                                    mediaType:SSPublishContentMediaTypeNews];
            
            [ShareSDK showShareActionSheet:nil shareList:nil content:publishContent statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end){
                
                if (state == SSResponseStateSuccess) {
                    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@('%i')", Result, 1] completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                        
                    }];
                    //[LCAlertView showWithTitle:nil message:@"分享成功！" buttonTitle:@"确认"];
                }
                else if (state == SSResponseStateFail){
                    
                    [LCAlertView showWithTitle:@"分享失败" message:[NSString stringWithFormat:@"错误码:%ld, 错误描述:%@", (long)[error errorCode], [error errorDescription]] buttonTitle:@"确认"];
                }
            }
             ];
        }else if([method isEqualToString:@"appPay"]){
            int type = [[message.body objectForKey:@"type"] intValue];
            NSString *data = [message.body objectForKey:@"data"];
            if(type == 1){
                
                [[AlipaySDK defaultService] payOrder:data fromScheme:kAlipayAppKey callback:^(NSDictionary *resultDic) {
                    //NSLog(@"reslut = %@",resultDic);
                    if([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]){
                        NSRange foundObj=[[resultDic objectForKey:@"result"] rangeOfString:@"success=true" options:NSCaseInsensitiveSearch];
                        if(foundObj.length>0) {
                            //[HMUtility alert:@"支付成功!" title:@"提示"];
                            //[self.delegate.navigationController popViewControllerAnimated:YES];
                            //[self goBack];
                        }
                    }
                    
                }];
            }else if(type == 3){
                NSDictionary *weiData = [[LCJsonUtil sharedInstance] dictionaryWithData:[data dataUsingEncoding: NSUTF8StringEncoding]];
                
                NSMutableString *stamp  = [weiData objectForKey:@"timestamp"];
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                //req.openID              = [weiData objectForKey:@"appid"];
                req.partnerId           = [weiData objectForKey:@"partnerid"];
                req.prepayId            = [weiData objectForKey:@"prepayid"];
                req.nonceStr            = [weiData objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.package             = [weiData objectForKey:@"package"];
                req.sign                = [weiData objectForKey:@"sign"];
                BOOL b = [WXApi sendReq:req];
                //[WXApi safeSendReq:req];
                NSLog(@"%i",b);
                
            }else if(type == 2){
                HMWebPay *ctrl = [[HMWebPay alloc] initWithNibName:nil bundle:nil];
                ctrl.type = 2;
                ctrl.payOrderSerial = data;
                [self.navigationController pushViewController:ctrl animated:YES];
            }else if(type == 5){
                HMWebPay *ctrl = [[HMWebPay alloc] initWithNibName:nil bundle:nil];
                ctrl.type = 1;
                ctrl.payOrderSerial = data;
                [self.navigationController pushViewController:ctrl animated:YES];
            }
        }

    }
}

#pragma mark 移除观察者
- (void)dealloc
{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    [[self.webView configuration].userContentController removeScriptMessageHandlerForName:@"AppModel"];
}
@end
