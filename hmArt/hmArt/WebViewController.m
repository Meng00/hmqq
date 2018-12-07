//
//  WebViewController.m
//  hmArt
//
//  Created by 刘学 on 16/10/14.
//  Copyright © 2016年 hanmoqianqiu. All rights reserved.
//

#import "WebViewController.h"
#import "PDRToolSystem.h"
#import "PDRToolSystemEx.h"
#import "PDRCoreAppFrame.h"
#import "PDRCoreAppManager.h"
#import "PDRCoreAppWindow.h"
#import "PDRCoreAppInfo.h"

@interface WebViewController()
{
    PDRCoreAppFrame* appFrame;
}

@end

@implementation WebViewController

- (void)viewDidLoad
{
    PDRCore*  pCoreHandle = [PDRCore Instance];
    if (pCoreHandle != nil)
    {
        
        NSString* pFilePath = [NSString stringWithFormat:@"file://%@/%@", [NSBundle mainBundle].bundlePath, @"mui/HMStore.html"];
        [pCoreHandle start];
        // 如果路径中包含中文，或Xcode工程的targets名为中文则需要对路径进行编码
        //NSString* pFilePath =  (NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, (CFStringRef)pTempString, NULL, NULL,  kCFStringEncodingUTF8 );
        CFStringRef aCFString = (__bridge_retained CFStringRef)pFilePath;
        
        pFilePath =  (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault, aCFString, NULL, NULL,  kCFStringEncodingUTF8 );
        
        // 单页面集成时可以设置打开的页面是本地文件或者是网络路径
        //pFilePath = @"http://www.163.com";
        
        
        // 用户在集成5+SDK时，需要在5+内核初始化时设置当前的集成方式，
        // 请参考AppDelegate.m文件的- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions方法
        
        if ([[PDRCore Instance] respondsToSelector:@selector(startAsWebClient)]) {
            [[PDRCore Instance] performSelector:@selector(startAsWebClient)];
        }
        
        
        CGRect StRect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        appFrame = [[PDRCoreAppFrame alloc] initWithName:@"WebViewID1" loadURL:pFilePath frame:StRect];
        // 单页面运行时设置Document目录
        NSString* pStringDocumentpath = [NSString stringWithFormat:@"%@/mui/", [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        [pCoreHandle.appManager.activeApp.appInfo setWwwPath:pStringDocumentpath];

        [pCoreHandle.appManager.activeApp.appWindow registerFrame:appFrame];
        [self.view  addSubview:appFrame];
        
    }
}

- (void)dealloc
{
    //[super dealloc];
    //[appFrame release];
    [[PDRCore Instance] setContainerView:nil];
}

@end
