//
//  HMPaintingDetail.m
//  hmArt
//
//  Created by wangyong on 14-8-19.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMPaintingDetail.h"

#define degressToRadian(x) (M_PI * (x) / 180.0)

@interface HMPaintingDetail ()

@end

@implementation HMPaintingDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y - 5;
    _scrollView.frame = rect;
    _scrollView.backgroundColor = [UIColor clearColor];
    
    _fullImageView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height+20);
    _fullImageView.alpha = 0;
    _hiddenBar = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    _pictureImage.userInteractionEnabled = YES;
    [_pictureImage addGestureRecognizer:tap];
    
    [self query];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_requestId != 0) {
        [[LCNetworkInterface sharedInstance] cancelRequest:_requestId];
    }
    [super viewWillDisappear:animated];
}


- (void)setParams:(NSString *)params
{
    NSDictionary *dicParam = [HMUtility parametersWithSeparator:@"=" delimiter:@"&" url:params];
    _paintingId =[[dicParam objectForKey:@"id"] integerValue];
}

#pragma mark -
#pragma mark detail auto zoom
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    [self hideStatusBar:YES];
    _fullImageView.alpha = 1;
    
    HMImageZoomView *zoomView = [[HMImageZoomView alloc] initWithFrame:_fullImageView.bounds];
    zoomView.contentOffset = CGPointMake(0, 0);
    NSString *imgUrlBig = [_paintingInfo objectForKey:@"image2"];
    NSMutableString *imgUrl = [[NSMutableString alloc] initWithCapacity:10];
    [imgUrl appendFormat:@"%@", HM_SYS_IMGSRV_PREFIX];
    if (imgUrlBig && imgUrlBig.length > 0) {
        [imgUrl appendString:imgUrlBig];
    }else{
        [imgUrl appendFormat:@"%@", [_paintingInfo objectForKey:@"image"]];
    }
    
    [zoomView startLoadImage];
    zoomView.tag = 101;
    zoomView.zoomDelegate = self;
    [_fullImageView addSubview:zoomView];

    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window addSubview:_fullImageView];

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
#pragma mark share methods
- (IBAction)shareButtonDown:(id)sender
{
    NSString *imagePath = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [_paintingInfo objectForKey:@"image2"]];
    NSString *content = @"";
    if(_source){
        if(_source == 1)//画廊
            content = [NSString stringWithFormat:@"%@的作品《%@》正在艺术交易中心APP展示销售，敬请关注！点击链接，可下载APP。",[_paintingInfo objectForKey:@"artist"], [_paintingInfo objectForKey:@"name"]];
        else if(_source == 2)//艺术家
            content = [NSString stringWithFormat:@"%@的作品《%@》正在艺术交易中心APP展示销售，敬请关注！点击链接，可下载APP。",[_paintingInfo objectForKey:@"artist"], [_paintingInfo objectForKey:@"name"]];
    }else{
        content = [NSString stringWithFormat:@"我分享了艺术家%@的《%@》作品, TA正在艺术交易中心展示销售。您可在各大应用商店搜索“艺术交易中心”下载APP了解更多详情。",[_paintingInfo objectForKey:@"artist"], [_paintingInfo objectForKey:@"name"]];
    }
    
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:content
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:content
                                                  url:HM_SYS_APPDOWN_URL
                                          description:content
                                            mediaType:SSPublishContentMediaTypeNews];

    [ShareSDK showShareActionSheet:nil shareList:nil content:publishContent statusBarTips:YES authOptions:nil shareOptions:nil result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end){
        if (state == SSResponseStateSuccess) {
            [LCAlertView showWithTitle:nil message:@"分享成功！" buttonTitle:@"确认"];
        }
        else if (state == SSResponseStateFail){
            [LCAlertView showWithTitle:@"分享失败" message:[NSString stringWithFormat:@"错误码:%ld, 错误描述:%@", (long)[error errorCode], [error errorDescription]] buttonTitle:@"确认"];
        }
    }
     ];

}

- (IBAction)favoriteButtonDown:(id)sender {
    if ([HMGlobalParams sharedInstance].anonymous) {
        HMLoginEx *ctrl = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
        return;
    }
    [self submitFavorite];
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
    [queryParam setValue:[NSNumber numberWithInteger:_paintingId] forKey:@"id"];
    _requestId = [net asynRequest:interfaceArtWorkDetail with:queryParam needSSL:NO target:self action:@selector(dealDetail:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealDetail:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        _paintingInfo = [NSDictionary dictionaryWithDictionary:[result.value objectForKey:@"obj"]];
        [self relayoutView];
    }
}

- (void)submitFavorite
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[NSNumber numberWithInteger:_paintingId] forKey:@"artId"];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    _requestId = [net asynRequest:interfaceFavoriteAdd with:queryParam needSSL:NO target:self action:@selector(dealFavorite:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealFavorite:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        [HMUtility alert:@"收藏成功！" title:@"提示"];
    }else{
        if (result.message.length > 0) {
            [HMUtility alert:result.message title:@"提示"];
        }else{
            [HMUtility alert:@"收藏失败！" title:@"提示"];
        }
    }
}


- (void)relayoutView
{
    _pictureImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [_paintingInfo objectForKey:@"image"]];
    [_pictureImage load];
    _titleLabel.text = [_paintingInfo objectForKey:@"name"];
    
    CGFloat offsetY = 0;
    UILabel *labelAuthor = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
    labelAuthor.backgroundColor = [UIColor clearColor];
    labelAuthor.font = [UIFont systemFontOfSize:14.0];
    labelAuthor.text = [NSString stringWithFormat:@"作       者：%@", [_paintingInfo objectForKey:@"artist"]];
    [_contentView addSubview:labelAuthor];
    offsetY += 21;
    
    UILabel *labelSize = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
    labelSize.backgroundColor = [UIColor clearColor];
    labelSize.font = [UIFont systemFontOfSize:14.0];
    NSString *size = [_paintingInfo objectForKey:@"size"];
    labelSize.text = [NSString stringWithFormat:@"尺       寸：%@", size];
    [_contentView addSubview:labelSize];
    offsetY += 21;
    
    UILabel *labelCreateTime = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
    labelCreateTime.backgroundColor = [UIColor clearColor];
    labelCreateTime.font = [UIFont systemFontOfSize:14.0];
    labelCreateTime.text = [NSString stringWithFormat:@"创作时间：%@", [_paintingInfo objectForKey:@"createDate"]];
    [_contentView addSubview:labelCreateTime];
    offsetY += 21;
    
    NSInteger pictureType = [[_paintingInfo objectForKey:@"type"] integerValue];
    NSString *price = [HMUtility getPrice:[_paintingInfo objectForKey:@"price"] pictureType:pictureType];
    if (price.length > 0) {
        UILabel *dealPrice = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
        dealPrice.backgroundColor = [UIColor clearColor];
        dealPrice.font = [UIFont systemFontOfSize:14.0];
        if (pictureType == 2) {
            dealPrice.text = [NSString stringWithFormat:@"售出价格：%@", price];
        }else{
            dealPrice.text = [NSString stringWithFormat:@"价       格：%@", price];
        }
        [_contentView addSubview:dealPrice];
        offsetY += 21;
    }
    
    if (pictureType == 2) {//已售作品，增加显示出售日期
        UILabel *dealSellDate = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
        dealSellDate.backgroundColor = [UIColor clearColor];
        dealSellDate.font = [UIFont systemFontOfSize:14.0];
        dealSellDate.text = [NSString stringWithFormat:@"售出日期：%@", [_paintingInfo objectForKey:@"sellDate"]];
        [_contentView addSubview:dealSellDate];
        offsetY += 21;
    }
    
    NSString *desc = [HMUtility getString:[_paintingInfo objectForKey:@"description"]];
    if (desc.length > 0) {
        UILabel *labelDescTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
        labelDescTitle.backgroundColor = [UIColor clearColor];
        labelDescTitle.font = [UIFont systemFontOfSize:14.0];
        labelDescTitle.text = @"简       介：";
        [_contentView addSubview:labelDescTitle];
        offsetY += 21;
        
        UILabel *labelDesc = [[UILabel alloc] initWithFrame:CGRectMake(10, offsetY, 295, 21)];
        labelDesc.backgroundColor = [UIColor clearColor];
        labelDesc.font = [UIFont systemFontOfSize:14.0];
        labelDesc.numberOfLines = 0;
        labelDesc.lineBreakMode = NSLineBreakByWordWrapping;
        labelDesc.text = [NSString stringWithFormat:@"    %@", desc];
        [labelDesc sizeToFit];
        [_contentView addSubview:labelDesc];
        
        CGRect rect = labelDesc.frame;
        offsetY = offsetY + rect.size.height + 5;
    }
    
    offsetY += 15;
    if (pictureType != 2) {
        UIButton *callButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [callButton setFrame:CGRectMake(35, offsetY, 240, 30)];
        [callButton setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
        [callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [callButton setTitle:@"我要咨询购买" forState:UIControlStateNormal];
        [callButton addTarget:self action:@selector(callButtonDown:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:callButton];
        offsetY += 35;
    }
    
    [_scrollView setContentSize:CGSizeMake(320, 225 + offsetY)];
    
}

- (void)callButtonDown:(id)sender
{
    NSString *tel = [_paintingInfo objectForKey:@"saleTel"];
    NSMutableString *call = [[NSMutableString alloc] init];
    if (tel && tel.length > 0) {
        [call appendString:tel];
    }else{
        [call appendString:HM_SYS_CUSTOM_SERVICE_PHONE];
    }
    NSString *name = [NSString stringWithFormat:@"致电%@咨询购买？", call];
    
    LCActionSheet *actionSheet = [[LCActionSheet alloc] initWithTitle:name phone:call type:0 name:@"销售咨询" cancelButtonTitle:@"取消" okButtonTitle:@"确定"];
    [actionSheet showPhonecall:self.tabBarController.tabBar];
    
}

#pragma mark -
#pragma makr zoom imageview delegate
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
@end
