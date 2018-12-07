//
//  LCWebView.m
//  lifeassistant
//
//  Created by wangyong on 14-2-22.
//
//

#import "LCWebView.h"
#import "HMAppDelegate.h"
#import "NSString+URL.h"

@interface LCWebView ()

@end

@implementation LCWebView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _showHtml = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    CGRect rect = self.webView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    self.webView.frame = rect;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (!_showHtml) {
        if (_url) {
            NSRange searchResult = [_url rangeOfString:@"?"];
            NSURL *reqUrl;
            HMAppDelegate *app = (HMAppDelegate *)[UIApplication sharedApplication].delegate;
            NSString *ran = [app getRandomString];
            if (searchResult.location == NSNotFound) {
                reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?random=%@", _url, ran]];
            }else{
                reqUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@&random=%@", _url, ran]];
            }
            self.webView.delegate = self;
            [self.webView loadRequest:[NSURLRequest requestWithURL:reqUrl]];
            [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
            [_activity startAnimating];
        }
    }else{
        [self.webView loadHTMLString:_html baseURL:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark webview delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!_showHtml) {
        [_activity stopAnimating];
        [HMUtility dismissModalView:_activity];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    NSString *desc = nil;
    switch (error.code) {
        case NSURLErrorDNSLookupFailed:
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorCannotFindHost:
            desc = @"当前网络不可用，请检查网络设置";
            break;
        case NSURLErrorTimedOut:
            desc = @"连接超时，请重新尝试";
            break;
        case NSURLErrorDataNotAllowed:
            desc = @"服务器不可到达，请检查网络";
            break;
        case NSURLErrorBadURL:
        case NSURLErrorUnsupportedURL:
            desc = @"连接地址错误，请重新尝试";
            break;
        default:
            desc = @"网页打开失败，请重新尝试";
            break;
    }
    [LCAlertView showWithTitle:@"提示" message:desc buttonTitle:@"确定"];
}
@end
