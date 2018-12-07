//
//  HMAuctionDetail.m
//  hmArt
//
//  Created by wangyong on 14-8-27.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctionDetail.h"

@interface HMAuctionDetail ()

@end

@implementation HMAuctionDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"竞买作品";
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
    
    // 左侧返回按钮，便于处理定时器
    UIBarButtonItem *backButton =  [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backButtonDown:)];
    backButton.style = UIBarButtonItemStyleDone;
    self.navigationItem.leftBarButtonItem = backButton;

    //
    _fullImageView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] applicationFrame].size.width, [[UIScreen mainScreen] applicationFrame].size.height+20);
    _fullImageView.alpha = 0;
    _hiddenBar = NO;
    _vipLevel = YES;

    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET - rect.origin.y;
    _scrollView.frame = rect;
    _scrollView.backgroundColor = [UIColor clearColor];
    
    _auctionScrollView.frame = rect;
    _auctionScrollView.hidden = YES;
    _scrollView.hidden = YES;
    
    CGRect rectContent = _historyContentView.frame;
    rectContent.size.height = rect.size.height - 10;
    _historyContentView.frame = rectContent;
    _historyContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _historyContentView.layer.borderWidth = 1.0;

    CGRect rectAuction = _auctionContentView.frame;
    rectAuction.size.height = rect.size.height - 10;
    _auctionContentView.frame = rectAuction;
    _auctionContentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _auctionContentView.layer.borderWidth = 1.0;
    
    _biddingView.layer.borderWidth = 1.0;
    _biddingView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _biddingView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:248.0/255.0 blue:236.0/255.0 alpha:1.0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ClickTabBar:) name:@"HMArtTabBarClickedAtIndexZero" object:nil];

    UITapGestureRecognizer *tapHaveRead = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHaveRead:)];
    tapHaveRead.numberOfTapsRequired = 1;
    tapHaveRead.numberOfTouchesRequired = 1;
    _showBidNoticeLabel.userInteractionEnabled = YES;
    [_showBidNoticeLabel addGestureRecognizer:tapHaveRead];
    
    self.inputform = _auctionScrollView;
    [self addInput:_priceInput sequence:1 name:@"price"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self query];
    [super viewWillAppear:animated];
    if (_toRead) {
        _toRead = NO;
        [HMUtility showModalView:_upgradeView baseView:self.view clickBackgroundToClose:YES fixSize:CGSizeMake(260, 210)];
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    if (_timer) {
        [_timer invalidate];
    }
    if (_recordTimer) {
        [_recordTimer invalidate];
    }
    
}

- (void)ClickTabBar:(NSNotification *)noticatication
{
    if (_timer) {
        [_timer invalidate];
    }
    if (_recordTimer) {
        [_recordTimer invalidate];
    }
    
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    if (_requestBidId != 0) {
        [net cancelRequest:_requestBidId];
    }

}

- (void)backButtonDown:(id)sender
{
    if (_timer) {
        [_timer invalidate];
    }
    if (_recordTimer) {
        [_recordTimer invalidate];
    }
    
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    if (_requestBidId != 0) {
        [net cancelRequest:_requestBidId];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setParams:(NSString *)params
{
    NSDictionary *dicParam = [HMUtility parametersWithSeparator:@"=" delimiter:@"&" url:params];
    _code = [NSString stringWithFormat:@"%@", [dicParam objectForKey:@"code"]];
}

- (void)tapHaveRead:(UITapGestureRecognizer *)tap
{
    
    [HMUtility dismissModalView:_upgradeView];
    _toRead = YES;
    LCWebView *web = [[LCWebView alloc] initWithNibName:nil bundle:nil];
    web.url = kUrlBidNotice;
    web.title = @"竞买须知";
    [self.navigationController pushViewController:web animated:YES];
    
    _haveRead = YES;
    UIImage *image = _haveRead ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"check_not.png"];
    [_haveReadButton setImage:image forState:UIControlStateNormal];

}

#pragma mark -
#pragma mark detail auto zoom
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    [self hideStatusBar:YES];
    _fullImageView.alpha = 1;
    
    HMImageZoomView *zoomView = [[HMImageZoomView alloc] initWithFrame:_fullImageView.bounds];
    zoomView.contentOffset = CGPointMake(0, 0);
    NSString *imgUrlBig = [_auction objectForKey:@"image2"];
    NSMutableString *imgUrl = [[NSMutableString alloc] initWithCapacity:10];
    [imgUrl appendFormat:@"%@", HM_SYS_IMGSRV_PREFIX];
    if (imgUrlBig && imgUrlBig.length > 0) {
        [imgUrl appendString:imgUrlBig];
    }else{
        [imgUrl appendFormat:@"%@", [_auction objectForKey:@"image"]];
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

#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [queryParams setObject:_code forKey:@"code"];
    if (![HMGlobalParams sharedInstance].anonymous) {
        [queryParams setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    }
    _requestId = [net asynRequest:interfaceAuctionDetail with:queryParams needSSL:NO target:self action:@selector(dealAuction:withResult:)];
    [_activity startAnimating];
    [HMUtility showModalView:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealAuction:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestId = 0;
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        _auction = [NSDictionary dictionaryWithDictionary:[result.value objectForKey:@"obj"]];
        _level = [[_auction objectForKey:@"level"] integerValue];
        _vipLevel = [[_auction objectForKey:@"vipLevel"] boolValue];
        NSInteger status = [[_auction objectForKey:@"auctionStatus"] integerValue];
        if (status == 1) { //正在竞拍
            _auctionScrollView.hidden = NO;
            [self.view bringSubviewToFront:_auctionScrollView];
            _pageIndex = 1;
            _pageSize = 3;
            _totalCount = 0;
            _curPrice = 0;
            _stepPrice = 0;
            _inputPrice = 0;
            _haveRead = NO;
            _toRead = NO;

            _auctionRecords = [[NSMutableArray alloc] initWithCapacity:3];
            [self relayoutAuction];
            [self queryLog];
        }else{
            _auctionScrollView.hidden = YES;
            _scrollView.hidden = NO;
            [self.view sendSubviewToBack:_auctionScrollView];
            [self.view bringSubviewToFront:_scrollView];
            [self relayoutView];
        }
    }
}

- (void)relayoutView
{
    _pictureImageView.contentMode = UIViewContentModeScaleAspectFit;
    _pictureImageView.image = [UIImage imageNamed:@"holder_320_180.png"];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [_auction objectForKey:@"image"]];
    _pictureImageView.imageUrl = imgUrl;
    [_pictureImageView load];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    _pictureImageView.userInteractionEnabled = YES;
    [_pictureImageView addGestureRecognizer:tap];

    _nameLabel.text = [NSString stringWithFormat:@"%@(编号:%@)", [_auction objectForKey:@"artName"], [_auction objectForKey:@"code"]];
    self.title = [_auction objectForKey:@"artName"];
    
    CGFloat offsetY = 0;
    UILabel *labelAuthor = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
    labelAuthor.backgroundColor = [UIColor clearColor];
    labelAuthor.font = [UIFont systemFontOfSize:14.0];
    labelAuthor.text = [NSString stringWithFormat:@"作者：%@", [_auction objectForKey:@"artist"]];
    [_contentView addSubview:labelAuthor];
    offsetY += 21;
    
    UILabel *labelSize = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
    labelSize.backgroundColor = [UIColor clearColor];
    labelSize.font = [UIFont systemFontOfSize:14.0];
    labelSize.text = [NSString stringWithFormat:@"尺寸：%@", [_auction objectForKey:@"artSize"]];
    [_contentView addSubview:labelSize];
    offsetY += 21;
    
    UILabel *labelCreateTime = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
    labelCreateTime.backgroundColor = [UIColor clearColor];
    labelCreateTime.font = [UIFont systemFontOfSize:14.0];
    labelCreateTime.text = [NSString stringWithFormat:@"创作时间：%@", [_auction objectForKey:@"artCreateTime"]];
    [_contentView addSubview:labelCreateTime];
    offsetY += 21;

    NSInteger status = [[_auction objectForKey:@"auctionStatus"] integerValue];
    if (status == 3 || status == 4) { //历史竞拍
        UILabel *dealPrice = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
        dealPrice.backgroundColor = [UIColor clearColor];
        dealPrice.font = [UIFont systemFontOfSize:14.0];
        dealPrice.text = [NSString stringWithFormat:@"成交价格：￥%@", [_auction objectForKey:@"auctionPrice"]];
        [_contentView addSubview:dealPrice];
        offsetY += 21;

        UILabel *dealTime = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
        dealTime.backgroundColor = [UIColor clearColor];
        dealTime.font = [UIFont systemFontOfSize:14.0];
        dealTime.text = [NSString stringWithFormat:@"成交日期：%@", [_auction objectForKey:@"auctionStartTime"]];
        [_contentView addSubview:dealTime];
        offsetY += 21;

        UILabel *dealCity = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
        dealCity.backgroundColor = [UIColor clearColor];
        dealCity.font = [UIFont systemFontOfSize:14.0];
        dealCity.text = [NSString stringWithFormat:@"归属地：%@", [HMUtility getString:[_auction objectForKey:@"area"]]];
        [_contentView addSubview:dealCity];
        offsetY += 21;
    }else if (status == 0){  //未开始
        UILabel *dealPrice = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
        dealPrice.backgroundColor = [UIColor clearColor];
        dealPrice.font = [UIFont systemFontOfSize:14.0];
        dealPrice.text = [NSString stringWithFormat:@"起拍价：￥%@", [_auction objectForKey:@"initPrice"]];
        [_contentView addSubview:dealPrice];
        offsetY += 21;
        
        UILabel *dealTime = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
        dealTime.backgroundColor = [UIColor clearColor];
        dealTime.font = [UIFont systemFontOfSize:14.0];
        dealTime.text = [NSString stringWithFormat:@"竞拍日期：%@", [_auction objectForKey:@"auctionStartTime"]];
        [_contentView addSubview:dealTime];
        offsetY += 21;
        
    }

    UILabel *labelDescTitle = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY, 300, 21)];
    labelDescTitle.backgroundColor = [UIColor clearColor];
    labelDescTitle.font = [UIFont systemFontOfSize:14.0];
    labelDescTitle.text = @"简介:";
    [_contentView addSubview:labelDescTitle];
    offsetY += 21;

    UILabel *labelDesc = [[UILabel alloc] initWithFrame:CGRectMake(10, offsetY, 295, 21)];
    labelDesc.backgroundColor = [UIColor clearColor];
    labelDesc.font = [UIFont systemFontOfSize:14.0];
    labelDesc.numberOfLines = 0;
    labelDesc.lineBreakMode = NSLineBreakByWordWrapping;
    labelDesc.text = [NSString stringWithFormat:@"    %@", [_auction objectForKey:@"description"]];
    [labelDesc sizeToFit];
    [_contentView addSubview:labelDesc];
    
    CGRect rect = labelDesc.frame;
    offsetY = offsetY + rect.size.height ;
    CGRect rectContent = _contentView.frame;
    rectContent.size.height = offsetY;
    _contentView.frame = rectContent;
    
    CGRect rectContainer = _historyContentView.frame;
    if ((offsetY + rectContent.origin.y) > rectContainer.size.height) {
        rectContainer.size.height = offsetY + rectContent.origin.y + 10;
        _historyContentView.frame = rectContainer;
    }
     [_scrollView setContentSize:CGSizeMake(320, 225 + offsetY)];
}

- (void)relayoutAuction
{
    _auctionImageView.contentMode = UIViewContentModeScaleAspectFit;
    _auctionImageView.image = [UIImage imageNamed:@"holder_320_180.png"];
    NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [_auction objectForKey:@"image"]];
    _auctionImageView.imageUrl = imgUrl;
    [_auctionImageView load];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    _auctionImageView.userInteractionEnabled = YES;
    [_auctionImageView addGestureRecognizer:tap];

    _auctionNameLabel.text = [NSString stringWithFormat:@"%@(编号:%@)", [_auction objectForKey:@"artName"], [_auction objectForKey:@"code"]];
    self.title = [_auction objectForKey:@"artName"];
    
    NSNumber *price = [_auction objectForKey:@"auctionPrice"];
    if (price) {
        _curPrice = [price longLongValue];
        _auctionPriceLabel.text = [NSString stringWithFormat:@"￥%@", price];
    }else{
        _curPrice = 0;
        _auctionPriceLabel.text = @"未出价";
    }
    _myPriceLabel.text = [NSString stringWithFormat:@"￥%@", [_auction objectForKey:@"myPrice"]];
    _initPrice =  [[_auction objectForKey:@"initPrice"] integerValue];
    _initialPriceLabel.text = [NSString stringWithFormat:@"￥%ld", (long)_initPrice];
    _stepPrice = [[_auction objectForKey:@"increment"] integerValue];
    _stepPriceLabel.text = [NSString stringWithFormat:@"￥%ld", (long)_stepPrice];
    _depositLabel.text = [NSString stringWithFormat:@"￥%@", [_auction objectForKey:@"bail"]];
    _commissionLabel.text = [NSString stringWithFormat:@"￥%@", [_auction objectForKey:@"commisionBuyer"]];
    
    _authorLabel.text = [NSString stringWithFormat:@"%@", [_auction objectForKey:@"artist"]];
    _sizeLabel.text = [NSString stringWithFormat:@"%@", [_auction objectForKey:@"artSize"]];
    _drawTimeLabel.text = [NSString stringWithFormat:@"%@", [_auction objectForKey:@"artCreateTime"]];
    _descLabel.text = [NSString stringWithFormat:@"    %@", [_auction objectForKey:@"description"]];
    _descLabel.numberOfLines = 0;
    _descLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_descLabel sizeToFit];
    
    if (_curPrice == 0) {
        if (_initPrice == 0) {
            _inputPrice  = _stepPrice;
        }else{
            _inputPrice = _initPrice;
        }
    }else{
        _inputPrice = _curPrice + _stepPrice;
    }
    _priceInput.text = [NSString stringWithFormat:@"%llu", _inputPrice];
    _moreImageView.hidden = YES;
    CGRect rectInfo = _infoView.frame;
    CGRect rect = _bidderRecordsView.frame;
    CGRect rectDesc = _descLabel.frame;
    rectInfo.origin.y = rect.origin.y + rect.size.height + 5;
    rectInfo.size.height = rectDesc.origin.y + rectDesc.size.height + 2;
    _infoView.frame = rectInfo;
    
    CGRect rectContainer = _auctionContentView.frame;
    if ((rectInfo.origin.y + rectInfo.size.height) > rectContainer.size.height) {
        rectContainer.size.height = rectInfo.origin.y + rectInfo.size.height + 10;
        _auctionContentView.frame = rectContainer;
    }
    [_auctionScrollView setContentSize:CGSizeMake(320, rectContainer.size.height + 10)];

    NSNumber *remainMilSeconds = [_auction objectForKey:@"remainTime"];
    if (remainMilSeconds && [remainMilSeconds longLongValue] > 0) {
        _remainSeconds = [remainMilSeconds longLongValue] / 1000;
        _timeRemainLabel.text = [NSString stringWithString:[HMUtility compareCurrentTimeBySeconds:_remainSeconds]];
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        _recordTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(refreshRecords) userInfo:nil repeats:YES];

    }else{
        _timeRemainLabel.text = @"已结束";
    }


}

- (void)countdown
{
    _remainSeconds--;
    if (_remainSeconds > 0) {
        _timeRemainLabel.text = [HMUtility compareCurrentTimeBySeconds:_remainSeconds];
    }else{
        _timeRemainLabel.text = @"已结束";
        if (_timer) {
            [_timer invalidate];
        }
    }
}

- (IBAction)shareButtonDown:(id)sender {
    NSString *imagePath = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [_auction objectForKey:@"image2"]];
    NSString *content = @"";
    if (_fenxiangContext) {
        content = _fenxiangContext;
    }else{
        if(_source && _source ==1){
            //content = [NSString stringWithFormat:@"我在翰墨千秋艺术交易中心购买的%@艺术家的作品《%@》 ，又委托翰墨千秋二次销售了。喜欢该作品的朋友可以出价竞拍哦！手机下载“艺术交易中心”APP，了解更多详情。%@",[_auction objectForKey:@"artist"], [_auction objectForKey:@"artName"],HM_SYS_APPDOWN_URL];
            content = [NSString stringWithFormat:@"%@的作品《%@》正在艺术交易中心APP展示销售，敬请关注！点击链接，可下载APP。",[_auction objectForKey:@"artist"], [_auction objectForKey:@"artName"]];
        }else{
            NSInteger status = [[_auction objectForKey:@"auctionStatus"] integerValue];
            if (status == 0) { //未开拍
                content = [NSString stringWithFormat:@"《%@》作品正在艺术交易中心APP预展。点击链接，可下载APP。", [_auction objectForKey:@"artName"]];
            }else if (status == 1) { //正在竞拍
                content = [NSString stringWithFormat:@"%@的作品《%@》正在艺术交易中心APP拍卖。点击链接，可下载APP。",[_auction objectForKey:@"artist"], [_auction objectForKey:@"artName"]];
            }else if (status == 3 || status == 4) {//成交的
                content = [NSString stringWithFormat:@"%@的作品《%@》在艺术交易中心APP售出，成交价%@元。点击链接，可下载APP！",[_auction objectForKey:@"artist"], [_auction objectForKey:@"artName"],[_auction objectForKey:@"auctionPrice"]];
            }else if (status == 2){//流拍
                content = [NSString stringWithFormat:@"%@的作品《%@》在艺术交易中心流拍了。喜欢的买家可以申请重新拍卖哦！点击链接，可下载APP。",[_auction objectForKey:@"artist"], [_auction objectForKey:@"artName"]];
            }
        }
    }
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

- (IBAction)haveReadButtonDown:(id)sender {
    _haveRead = !_haveRead;
    UIImage *image = _haveRead ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"check_not.png"];
    [_haveReadButton setImage:image forState:UIControlStateNormal];

}

#pragma mark -
#pragma mark auction bidder log methods
- (void)queryLog
{
    if (_recordTimer) {
        [_recordTimer invalidate];
    }

    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [queryParams setObject:_code forKey:@"code"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParams setObject:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    _requestId = [net asynRequest:interfaceAuctionBiddingRecords with:queryParams needSSL:NO target:self action:@selector(dealAuctionLog:withResult:)];
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(refreshRecords) userInfo:nil repeats:YES];
}

- (void)dealAuctionLog:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        [_auctionRecords removeAllObjects];
        NSArray *list = [result.value objectForKey:@"obj"];
        for (NSDictionary *bidder in list) {
            [_auctionRecords addObject:bidder];
        }
        _totalCount = [[result.value objectForKey:@"total"] integerValue];
        [self drawBidderRecordsView];
//
        
    }
}

- (void)drawBidderRecordsView
{
    for (UIView *view in _bidderRecordsView.subviews) {
        if (view.tag > 0) {
            [view removeFromSuperview];
        }
    }
    CGFloat offsetY = 23;
    int i = 0;
    for (NSDictionary *bidder in _auctionRecords) {
        UILabel *mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(1, offsetY, 74, 21)];
        mobileLabel.backgroundColor = [UIColor whiteColor];
        mobileLabel.font = [UIFont systemFontOfSize:11.0];
        mobileLabel.textAlignment = NSTextAlignmentCenter;
        NSString *mob = [NSString stringWithFormat:@"%@", [bidder objectForKey:@"mobile"]];
        mobileLabel.text = [mob stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
        mobileLabel.tag = 101;
        [_bidderRecordsView addSubview:mobileLabel];

        UILabel *areaLabel = [[UILabel alloc] initWithFrame:CGRectMake(76, offsetY, 72, 21)];
        areaLabel.backgroundColor = [UIColor whiteColor];
        areaLabel.font = [UIFont systemFontOfSize:11.0];
        areaLabel.textAlignment = NSTextAlignmentCenter;
        areaLabel.text = [NSString stringWithFormat:@"%@", [bidder objectForKey:@"area"]];
        areaLabel.tag = 102;
        [_bidderRecordsView addSubview:areaLabel];

        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(149, offsetY, 66, 21)];
        priceLabel.backgroundColor = [UIColor whiteColor];
        priceLabel.font = [UIFont systemFontOfSize:11.0];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.text =[NSString stringWithFormat:@"￥%@", [bidder objectForKey:@"auctionAmount"]];
        if (i == 0) {
            _curPrice = [[bidder objectForKey:@"auctionAmount"] longLongValue];
            _auctionPriceLabel.text = [NSString stringWithFormat:@"￥%llu", _curPrice];
            if (_curPrice >= _inputPrice) {
                _inputPrice = _curPrice + _stepPrice;
                _priceInput.text = [NSString stringWithFormat:@"%llu", _inputPrice];
            }
        }
        priceLabel.tag = 103;
        [_bidderRecordsView addSubview:priceLabel];

        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(216, offsetY, 83, 21)];
        timeLabel.backgroundColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:11.0];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        NSString *at = [bidder objectForKey:@"auctionDate"];
        timeLabel.text = [at substringFromIndex:5];
        timeLabel.tag = 104;
        [_bidderRecordsView addSubview:timeLabel];

        offsetY += 21;
        i++;
    }
    
    CGRect rect = _bidderRecordsView.frame;
    rect.size.height = offsetY + 1;
    _bidderRecordsView.frame = rect;
    CGFloat offsetImage = 0;
    if (_pageSize == 3 && _totalCount > 3) {
        _moreImageView.hidden = NO;
        CGRect rectImage = _moreImageView.frame;
        rectImage.origin.y = rect.origin.y + rect.size.height  + 2;
        _moreImageView.frame = rectImage;
        offsetImage = 20;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMoreRecords:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        _moreImageView.userInteractionEnabled = YES;
        [_moreImageView addGestureRecognizer:tap];
        
    }else{
        _moreImageView.hidden = YES;
    }
    CGRect rectInfo = _infoView.frame;
    rectInfo.origin.y = rect.origin.y + rect.size.height + offsetImage + 5;
    _infoView.frame = rectInfo;
    
    CGRect rectContainer = _auctionContentView.frame;
    if ((rectInfo.origin.y + rectInfo.size.height) > rectContainer.size.height) {
        rectContainer.size.height = rectInfo.origin.y + rectInfo.size.height + 10;
        _auctionContentView.frame = rectContainer;
    }

    [_auctionScrollView setContentSize:CGSizeMake(320, rectContainer.size.height + 10)];

}

- (void)tapMoreRecords:(UITapGestureRecognizer *)tap
{
    _pageIndex = 1;
    _pageSize = 10;
    [self queryLog];
}

- (void)refreshRecords
{
    [self queryLog];
}

- (IBAction)priceChanged:(id)sender {
    unsigned long long tempPrice = [_priceInput.text longLongValue];
    if (tempPrice < (_curPrice + _stepPrice)) {
        [LCAlertView showWithTitle:nil message:@"出价不能小于当前价+加价幅度！" buttonTitle:@"确定"];
        _priceInput.text = [NSString stringWithFormat:@"%llu", _inputPrice];
        return;
    }
    unsigned long long  incre = tempPrice - _curPrice;
    if ((incre % _stepPrice) != 0) {
        [LCAlertView showWithTitle:nil message:@"加价金额必须是加价幅度的整数倍！" buttonTitle:@"确定"];
        _priceInput.text = [NSString stringWithFormat:@"%llu", _inputPrice];
        return;
    }
    _inputPrice = tempPrice;
}

- (IBAction)stepButtonDown:(UIButton *)sender {
    NSInteger tag = [sender tag];
    unsigned long long tempPrice;
    if (tag == 1) {
        tempPrice = _inputPrice - _stepPrice;
    }else {
        tempPrice = _inputPrice + _stepPrice;
    }
    if (tempPrice > _curPrice) {
        _priceInput.text = [NSString stringWithFormat:@"%llu", tempPrice];
        _inputPrice = tempPrice;
    }
}


#pragma mark -
#pragma mark bidder methods
- (IBAction)bidButtonDown:(id)sender {
    NSString *sPrice = _priceInput.text;
    if (![HMTextChecker checkIsNumber:sPrice]) {
        [LCAlertView showWithTitle:nil message:@"您的出价金额不正确！" buttonTitle:@"确认"];
        return;
    }
    if (![HMTextChecker checkLength:sPrice min:1 max:10]) {
        [LCAlertView showWithTitle:nil message:@"您的出价金额不正确！" buttonTitle:@"确认"];
        return;
    }
    
    if (_inputPrice < _initPrice) {
        [LCAlertView showWithTitle:nil message:@"您的出价不能小于起拍价格！" buttonTitle:@"确认"];
        return;
    }
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    if (params.anonymous) {
        HMLoginEx *ctrl = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
        return;
    }
    if (_vipLevel == YES && params.vip == 0) {
        _upgradeView.hidden = NO;
        [HMUtility showModalView:_upgradeView baseView:self.view clickBackgroundToClose:YES fixSize:CGSizeMake(260, 210)];
        return;
    }
    if (_requestBidId != 0) {
        [LCAlertView showWithTitle:nil message:@"上次出价还未确认,请稍后出价！" buttonTitle:@"确认"];
        return;
    }
    NSString *tips = [NSString stringWithFormat:@"您确认出价%llu元购买当前拍品？", _inputPrice];
    [LCAlertView showWithTitle:@"提示" message:tips cancelTitle:@"稍后再说" cancelBlock:nil otherTitle:@"确认" otherBlock:^{[self queryBid];}];
    
}

- (IBAction)upgradeButtonDown:(id)sender {
    if (!_haveRead) {
        [HMUtility alert:@"若您已仔细阅读过竞买须知,请勾选“我已查看竞买须知”" title:@"操作提示"];
        return;
    }
//    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
//    if (_requestUpgradeId != 0) {
//        [net cancelRequest:_requestUpgradeId];
//    }
//    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
//    [queryParams setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
//    _requestUpgradeId = [net asynRequest:interfaceUserUpgrade with:queryParams needSSL:NO target:self action:@selector(dealUpgrade:withResult:)];
//    [_activity startAnimating];
//    [HMUtility showModalView:_activity baseView:self.view clickBackgroundToClose:NO];
    HMUpgradeVIP *ctrl = [[HMUpgradeVIP alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
    
}


- (void)dealUpgrade:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestUpgradeId = 0;
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        [LCAlertView showWithTitle:@"提示" message:@"您的升级请求已提交，我们的工作人员会尽快与您联系，请保持手机畅通！" cancelTitle:@"确定" cancelBlock:^{
            _upgradeView.hidden = YES;
            [HMUtility dismissModalView:_upgradeView];
        } otherTitle:nil otherBlock:nil];
    }else{
        if ([result.message length] > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"升级申请提交失败，请重新操作！" inView:self.view];
        }
    }
}


#pragma mark -
#pragma mark 竞价出价
- (void)queryBid
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestBidId != 0) {
        [net cancelRequest:_requestBidId];
    }
    NSMutableDictionary *queryParams = [[NSMutableDictionary alloc] initWithCapacity:3];
    [queryParams setObject:_code forKey:@"code"];
    [queryParams setObject:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    [queryParams setObject:[NSNumber numberWithInteger:_inputPrice] forKey:@"price"];
    _requestBidId = [net asynRequest:interfaceAuctionBidding with:queryParams needSSL:NO target:self action:@selector(dealBidding:withResult:)];
    [_activity startAnimating];
    [HMUtility showModalView:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealBidding:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestBidId = 0;
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        [HMUtility showTip:@"出价成功!" inView:self.view];
        _myPriceLabel.text = [NSString stringWithFormat:@"￥%llu", _inputPrice];
        _auctionPriceLabel.text = [NSString stringWithFormat:@"￥%llu", _inputPrice];
    }else{
        if ([result.message length] > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"出价失败，请重新出价！" inView:self.view];
        }
    }
    
}
@end
