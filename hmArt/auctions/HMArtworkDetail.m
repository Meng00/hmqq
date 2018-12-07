//
//  HMArtworkDetail.m
//  hmArt
//
//  Created by 刘学 on 15-7-8.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMArtworkDetail.h"

@interface HMArtworkDetail ()

@end

@implementation HMArtworkDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"作品详情";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    CGRect rect = _scrollView.frame;
    if (IOS7) {
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 29;
    }else{
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 49;
    }
    _scrollView.frame = rect;
    _scrollView.backgroundColor = [UIColor clearColor];
    
    _topView = [[LCView alloc] initWithFrame:CGRectMake(0, 2, 320, 0)];
    [_topView setPaddingTop:10 paddingBottom:10 paddingLeft:10 paddingRight:10];
    [_scrollView addSubview:_topView];
    _topView.backgroundColor = [UIColor whiteColor];
    
    [self query];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[NSNumber numberWithInteger:_artworkId] forKey:@"id"];
    
    _requestId = [net asynRequest:interfaceArtworkInfo with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealPictures:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        NSLog(@"%@", ret);
        
        dic = [ret objectForKey:@"obj"];
        
        
        LCView *headerView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
        [headerView setPaddingTop:0 paddingBottom:0 paddingLeft:0 paddingRight:0];
        [_topView addCustomSubview:headerView intervalTop:0];
        
        UILabel *artName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 0)];
        artName.text = [dic objectForKey:@"artName"];
        [headerView addCustomSublabel:artName intervalLeft:0 textMaxShowWidth:255 textMaxShowHeight:0];
        
        UIButton *fenxiang = [UIButton buttonWithType:UIButtonTypeCustom];
        fenxiang.frame = CGRectMake(0, 0, 48, 24);
        fenxiang.tag = 1030;
        fenxiang.hidden = NO;
        [fenxiang setImage:[UIImage imageNamed:@"btn_share.png"] forState:UIControlStateNormal];
        fenxiang.userInteractionEnabled = YES;
        [fenxiang addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareButtonDown:)]];
        [headerView addCustomSubview:fenxiang intervalLeft:0];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, headerView.frame.size.width, 1)];
        [_topView addCustomSublabel:line intervalTop:3];
        line.backgroundColor = [UIColor grayColor];
        
        HMNetImageView *image = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 180)];
        image.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
        [image load];
        image.userInteractionEnabled = YES;
        [image addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        [_topView addCustomSubview:image intervalTop:5];
        
        UILabel *artist = [[UILabel alloc] init];
        artist.text = [NSString stringWithFormat:@"作   者: %@", [dic objectForKey:@"artist"]];
        //artist.textColor = [UIColor redColor];
        artist.font = [UIFont systemFontOfSize:14.0f];
        [_topView addCustomSublabel:artist intervalTop:5];
        
        UILabel *artSize = [[UILabel alloc] init];
        artSize.text = [NSString stringWithFormat:@"尺   寸: %@", [dic objectForKey:@"artSize"]];
        [_topView addCustomSublabel:artSize intervalTop:5];
        
        UILabel *artCreateTime = [[UILabel alloc] init];
        artCreateTime.text = [NSString stringWithFormat:@"创作时间: %@", [dic objectForKey:@"artCreateTime"]];
        [_topView addCustomSublabel:artCreateTime intervalTop:5];
        
        UILabel *decripLabel = [[UILabel alloc] init];
        decripLabel.text = @"简介:  ";
        [_topView addCustomSublabel:decripLabel intervalTop:5];
        
        UILabel *descriContent = [[UILabel alloc] init];
        descriContent.text = [NSString stringWithFormat:@"  %@", [dic objectForKey:@"description"]];
        [_topView addCustomSublabel:descriContent intervalTop:3];
        
        
        [_topView resize];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.origin.y +_topView.frame.size.height+10);
    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
    }
}


/***** 点击弹出大图窗口代码开始  *******/

#pragma mark -
#pragma mark detail auto zoom
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    [self hideStatusBar:YES];
    _fullImageView.alpha = 1;
    
    HMImageZoomView *zoomView = [[HMImageZoomView alloc] initWithFrame:_fullImageView.bounds];
    zoomView.contentOffset = CGPointMake(0, 0);
    NSString *imgUrlBig = [dic objectForKey:@"image2"];
    NSMutableString *imgUrl = [[NSMutableString alloc] initWithCapacity:10];
    [imgUrl appendFormat:@"%@", HM_SYS_IMGSRV_PREFIX];
    if (imgUrlBig && imgUrlBig.length > 0) {
        [imgUrl appendString:imgUrlBig];
    }else{
        [imgUrl appendFormat:@"%@", [dic objectForKey:@"image"]];
    }
    
    [zoomView startLoadImage];
    zoomView.tag = 101;
    zoomView.zoomDelegate = self;
    [_fullImageView addSubview:zoomView];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:_fullImageView];
    //    [self hideStatusBar:NO];
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestImageId != 0) {
        [net cancelRequest:_requestImageId];
    }
    _requestImageId = [net asynExternalRequest:imgUrl needSSL:NO cached:YES target:self action:@selector(dealImage:result:)];
}

- (void)dealImage:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    _requestImageId = 0;
    HMImageZoomView *zoomView = (HMImageZoomView *)[_fullImageView viewWithTag:101];
    [zoomView stopLoadImage];
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        UIImage *image = [UIImage imageWithData:result.value];
        [zoomView setImage:image];
        [self performSelector:@selector(setOriginFrame:) withObject:zoomView afterDelay:0.1];
    }
}

- (void) setOriginFrame:(HMImageZoomView *) sender
{
    [UIView animateWithDuration:0.4 animations:^{
        [sender setAnimationRect];
    }];
}

- (void)hideStatusBar:(BOOL)hidden
{
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:NO];
    _hiddenBar = hidden;
    if([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]){
        [self prefersStatusBarHidden];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (BOOL)prefersStatusBarHidden
{
    if (_hiddenBar) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark zoom imageview delegate
- (void)imageTapedWithObject:(id)sender
{
    if (_requestImageId != 0) {
        [[LCNetworkInterface sharedInstance] cancelRequest:_requestImageId];
    }
    for (UIView *subView in _fullImageView.subviews) {
        if (subView.tag > 0) {
            [subView removeFromSuperview];
        }
    }
    [_fullImageView removeFromSuperview];
    [self hideStatusBar:NO];
}

/***** 点击弹出大图窗口代码结束  *******/

- (void)shareButtonDown:(id)sender {
    NSString *imagePath = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
    NSString *content = [NSString stringWithFormat:@"我分享了艺术家%@的《%@》作品, TA正在艺术交易中心展示销售。您可在各大应用商店搜索“艺术交易中心”下载APP了解更多详情。",[dic objectForKey:@"artist"], [dic objectForKey:@"artName"]];
    [self enableKeyboardObserve:NO];
    //    NSString *clickUrl = @"http://app.4008988518.com/app/down.html";
    NSString *clickUrl = imagePath;
    id<ISSContent> publishCotent = [ShareSDK content:content defaultContent:content image:[ShareSDK imageWithUrl:imagePath] title:content url:clickUrl description:content mediaType:SSPublishContentMediaTypeNews];
    [ShareSDK showShareActionSheet:nil shareList:nil content:publishCotent statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end){
        [self enableKeyboardObserve:YES];
        if (state == SSResponseStateSuccess) {
            [LCAlertView showWithTitle:nil message:@"分享成功！" buttonTitle:@"确认"];
        }
        else if (state == SSResponseStateFail){
            
            [LCAlertView showWithTitle:@"分享失败" message:[NSString stringWithFormat:@"错误码:%ld, 错误描述:%@", (long)[error errorCode], [error errorDescription]] buttonTitle:@"确认"];
        }
    }
     ];
    
}



@end
