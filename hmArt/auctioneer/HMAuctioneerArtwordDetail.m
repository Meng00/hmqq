//
//  HMAuctioneerArtwordDetail.m
//  hmArt
//
//  Created by 刘学 on 15-7-7.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctioneerArtwordDetail.h"

@interface HMAuctioneerArtwordDetail ()

@end

@implementation HMAuctioneerArtwordDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    CGRect rect = _scrollView.frame;
    if (IOS7) {
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 29;
    }else{
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 49;
    }
    _scrollView.frame = rect;
    _scrollView.backgroundColor = [UIColor whiteColor];
    
    _topView = [[LCView alloc] initWithFrame:CGRectMake(4, 10, 312, 0)];
    [_topView setPaddingTop:0 paddingBottom:0 paddingLeft:2 paddingRight:2];
    [_scrollView addSubview:_topView];
    
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
    
    _requestId = [net asynRequest:interfaceAuctioneerArtworkDetail with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
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
        //artName.textColor = [UIColor redColor];
        artName.font = [UIFont systemFontOfSize:14.0f];
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
        [_topView addCustomSublabel:line intervalTop:0];
        line.backgroundColor = [UIColor grayColor];
        
        HMNetImageView *image = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 180)];
        image.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
        [image load];
        image.userInteractionEnabled = YES;
        [image addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
        [_topView addCustomSubview:image intervalTop:1];
        
        UILabel *artist = [[UILabel alloc] init];
        artist.text = [NSString stringWithFormat:@"作   者:%@", [dic objectForKey:@"artist"]];
        artist.font = [UIFont systemFontOfSize:14.0f];
        [_topView addCustomSublabel:artist intervalTop:3];
        
        UILabel *artSize = [[UILabel alloc] init];
        artSize.text = [NSString stringWithFormat:@"尺   寸:%@", [dic objectForKey:@"artSize"]];
        artSize.font = [UIFont systemFontOfSize:14.0f];
        [_topView addCustomSublabel:artSize intervalTop:3];
        
        UILabel *artCreateTime = [[UILabel alloc] init];
        artCreateTime.text = [NSString stringWithFormat:@"创作时间:%@", [dic objectForKey:@"artCreateTime"]];
        artCreateTime.font = [UIFont systemFontOfSize:14.0f];
        [_topView addCustomSublabel:artCreateTime intervalTop:3];
        
        UILabel *timeLabel = [[UILabel alloc] init];
        timeLabel.text = [NSString stringWithFormat:@"年   代:%@", [dic objectForKey:@"timeLabelChs"]];
        timeLabel.font = [UIFont systemFontOfSize:14.0f];
        [_topView addCustomSublabel:timeLabel intervalTop:3];
        
        
        if([dic objectForKey:@"initPrice"]){
            UILabel *sortLable = [[UILabel alloc] init];
            sortLable.text = [NSString stringWithFormat:@"价   格:￥%@", [dic objectForKey:@"initPrice"]];
            sortLable.font = [UIFont systemFontOfSize:14.0f];
            [_topView addCustomSublabel:sortLable intervalTop:3];
        }
        
        
        UILabel *decripLabel = [[UILabel alloc] init];
        decripLabel.text = @"简介:";
        decripLabel.font = [UIFont systemFontOfSize:14.0f];
        [_topView addCustomSublabel:decripLabel intervalTop:3];
        
        UILabel *descriContent = [[UILabel alloc] init];
        descriContent.text = [NSString stringWithFormat:@"  %@", [dic objectForKey:@"description"]];
        descriContent.font = [UIFont systemFontOfSize:14.0f];
        [_topView addCustomSublabel:descriContent intervalTop:3];
        
        UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
        paybut.frame = CGRectMake(40, 0, 240, 30);
        paybut.tag = 3001;
        [paybut setTitle:@"我要咨询购买" forState:UIControlStateNormal];
        [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
        paybut.userInteractionEnabled = YES;
        [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callButtonDown:)]];
        [_topView addCustomSubview:paybut intervalTop:10];
        
        [_topView resize];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.origin.y +_topView.frame.size.height + 30);
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
    NSString *imagePath = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, _auctioneerImage];
    NSString *content = [NSString stringWithFormat:@"%@的作品《%@》正在艺术交易中心APP在线预展，敬请关注。点击链接，可下载APP。",[dic objectForKey:@"artist"],[dic objectForKey:@"artName"]];
    [self enableKeyboardObserve:NO];
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:content
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:content
                                                  url:HM_SYS_APPDOWN_URL
                                          description:content
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil shareList:nil content:publishContent statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end){
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


- (void)callButtonDown:(id)sender {
    NSString *name = [NSString stringWithFormat:@"致电我们-%@ ？", [dic objectForKey:@"phone"]];
    LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:name phone:[dic objectForKey:@"phone"] type:0 name:@"更多服务" cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
    [actionSheet showPhonecall:self.tabBarController.tabBar];
    
}

@end
