//
//  HMMUIWebView.m
//  hmArt
//
//  Created by 刘学 on 16/10/14.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import "HMMUIWebView.h"
#import "PDRToolSystem.h"
#import "PDRToolSystemEx.h"
#import "PDRCoreAppFrame.h"
#import "PDRCoreAppManager.h"
#import "PDRCoreAppWindow.h"
#import "PDRCoreAppInfo.h"


@interface HMMUIWebView ()
{
    PDRCoreAppFrame* appFrame;
}
@end

@implementation HMMUIWebView


- (void)viewDidLoad
{
    
    PDRCore*  pCoreHandle = [PDRCore Instance];
    if (pCoreHandle != nil)
    {
        NSString* pFilePath = _url;
        if([_url hasPrefix:@"http://localhost/"]){
            
            NSString *httpUrl = _url;
            //httpUrl = [[httpUrl componentsSeparatedByString:@"?"] objectAtIndex:0];
            httpUrl = [httpUrl stringByReplacingOccurrencesOfString:@"http://localhost/" withString:@""];
            //pFilePath = [[NSBundle mainBundle] pathForResource:httpUrl ofType:nil];
            pFilePath = [NSString stringWithFormat:@"file://%@/%@", [NSBundle mainBundle].bundlePath, httpUrl];
            
            CFStringRef aCFString = (__bridge_retained CFStringRef)pFilePath;
            
            pFilePath =  (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, aCFString, NULL, NULL,  kCFStringEncodingUTF8 );
        }
        
        [pCoreHandle start];
        
        if ([[PDRCore Instance] respondsToSelector:@selector(startAsWebClient)]) {
            [[PDRCore Instance] performSelector:@selector(startAsWebClient)];
        }
        
        
        CGRect StRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        appFrame = [[PDRCoreAppFrame alloc] initWithName:@"WebViewID1" loadURL:pFilePath frame:StRect];
        // 单页面运行时设置Document目录
        //NSString* pStringDocumentpath = [NSString stringWithFormat:@"%@/mui/", [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        //[pCoreHandle.appManager.activeApp.appInfo setWwwPath:pStringDocumentpath];
        
        [pCoreHandle.appManager.activeApp.appWindow registerFrame:appFrame];
        [self.view  addSubview:appFrame];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden=YES;
    
    // 添加一个原生层的消息监听，可以监听页面中通过NJS发送的消息，并获取附带的数据
    // NJS 发送消息请参考Pandora/apps/HelloH5/plugin.html 文件的PostNotification方法
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NotiFunction:) name:@"SendDataToNative" object:nil];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.hidden=NO;
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SendDataToNative" object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    //[super dealloc];
    //[appFrame release];
    //[[PDRCore Instance] setContainerView:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)NotiFunction:(NSNotification*)pNoti
{
    if (pNoti) {
        NSString* pRecData = pNoti.object;
        if (pRecData) {
            NSLog(@"Native Receive Data:%@", pRecData);
            if([pRecData isEqualToString:@"goBack"]){
                
                [self.navigationController popViewControllerAnimated:YES];
            }else if([pRecData hasPrefix:@"hmqq-mui"]){
                NSString *httpUrl = pRecData;
                HMMUIWebView *web = [[HMMUIWebView alloc] initWithNibName:nil bundle:nil];
                web.url = [httpUrl stringByReplacingOccurrencesOfString:@"hmqq-mui" withString:@"http"];
                
                [self.navigationController pushViewController:web animated:YES];
                
            }else{
                UIAlertView* pAlertView = [[UIAlertView alloc] initWithTitle:@"原生层收到消息" message:pRecData delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                if (pAlertView) {
                    [pAlertView show];
                }
            }
        }
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
