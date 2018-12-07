//
//  HMAuctionArea.m
//  hmArt
//
//  Created by wangyong on 14-8-18.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctionArea.h"

@interface HMAuctionArea ()

@end

#define DOINGCELL_REUSEID @"DoingCollectionCell"
#define WILLDOCELL_REUSEID @"WillDoCollectionCell"

@implementation HMAuctionArea


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"竞买区";
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
    
//    self.view.userInteractionEnabled = YES;
//    UITapGestureRecognizer *singleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
//    [self.view addGestureRecognizer:singleTouch];
    
    _titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _titleView.layer.borderWidth = 1.0;
    
    self.title = _viewTitle;
    
    // 右侧按钮
    _rightButton =  [[UIBarButtonItem alloc] initWithTitle:@"拍品搜索" style:UIBarButtonItemStyleDone target:self action:@selector(showSearchView:)];
    [_rightButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:@"Helvetica-Bold" size:14.0], NSFontAttributeName,
                                         [UIColor whiteColor], NSForegroundColorAttributeName,
                                         nil]
                               forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = _rightButton;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAuctionStatus:)];
    tap1.numberOfTapsRequired = 1;
    tap1.numberOfTouchesRequired = 1;
    _auctionDoing.userInteractionEnabled = YES;
    [_auctionDoing addGestureRecognizer:tap1];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAuctionStatus:)];
    tap2.numberOfTapsRequired = 1;
    tap2.numberOfTouchesRequired = 1;
    _auctionWillDo.userInteractionEnabled = YES;
    [_auctionWillDo addGestureRecognizer:tap2];

    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAuctionStatus:)];
    tap3.numberOfTapsRequired = 1;
    tap3.numberOfTouchesRequired = 1;
    _auctionDone.userInteractionEnabled = YES;
    [_auctionDone addGestureRecognizer:tap3];
    
    [_doingCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:DOINGCELL_REUSEID];
    
    
    //_willDoTable.contentInset = UIEdgeInsetsMake(180, 0, 0, 0);
    //HMAnimateImageView *imagev = [[HMAnimateImageView alloc] initWithFrame:CGRectMake(0, -180, 320, 180)];
    //[_willDoTable addSubview: imagev];
    _curTimeIndex=0;
    _curTimeId=0;
    _curSortIndex=0;
    _curSortId=0;
    _curPriceIndex=0;
    _curTypeIndex=0;
    _keyword = @"";
    
    _data1 = [[NSMutableArray alloc] initWithObjects:@"类别", nil];
    _data2 = [[NSMutableArray alloc] initWithObjects:@"价格", nil];
    _data3 = [[NSMutableArray alloc] initWithObjects:@"年代", nil];
    _data4 = [[NSMutableArray alloc] initWithObjects:@"来源", nil];
    _sortArray = [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"类别",@"name",0,@"id", nil], nil];
    _timeArray = [[NSMutableArray alloc] initWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"年代",@"name",0,@"id", nil], nil];
    _resultDoingArray = [[NSMutableArray alloc] initWithCapacity:1];//正在竞买列表
    _countSecondsArray = [[NSMutableArray alloc] initWithCapacity:1];//倒计时列表
    _countGroupSecondsArray = [[NSMutableArray alloc] initWithCapacity:1];//预展倒计时列表
    _resultDoneArray = [[NSMutableArray alloc] initWithCapacity:1];//历史竞买列表
    _resultWillDoArray = [[NSMutableArray alloc] initWithCapacity:1];//预展列表
    _resultWillDoGroupArray = [[NSMutableArray alloc] initWithCapacity:1];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ClickTabBar:) name:@"HMArtTabBarClickedAtIndexZero" object:nil];
    // 遮盖层
    _btnAccessoryView=[[UIButton alloc] initWithFrame:CGRectMake(0, 44, 320, [[UIScreen mainScreen] applicationFrame].size.height - 44)];
    [_btnAccessoryView setBackgroundColor:[UIColor blackColor]];
    [_btnAccessoryView setAlpha:0.0f];
    [_btnAccessoryView addTarget:self action:@selector(ClickControlAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnAccessoryView];
    
    [self queryLabel];
    _searchType = 0;
    [self switchView:1];
    
    
}

-(void)switchView :(NSInteger)tag
{
    /** 切换页面 ***/
    if (tag == _searchType) {
        return;
    }
    
    /*** 初始化值 ***/
    _searchView.hidden=YES;
    [self initSearchView];
    _curTimeIndex=0;
    _curTimeId=0;
    _curSortIndex=0;
    _curSortId=0;
    _curPriceIndex=0;
    _curTypeIndex=0;
    _keyword = @"";
    
    CGRect rectTitle = _titleView.frame;
    if (_searchView.hidden == NO) {
        rectTitle.origin.y = _searchView.frame.origin.y + _searchView.frame.size.height;
    }else{
        rectTitle.origin.y = 5;
    }
    _titleView.frame = rectTitle;
    
    CGRect rect = _doingView.frame;
    rect.origin.y = rectTitle.origin.y + rectTitle.size.height;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    _doingView.frame = rect;
    _willDoView.frame = rect;
    _doneView.frame = rect;
    
    CGRect rectContent = rect;
    rectContent.origin = CGPointMake(0, 0);
    _doingCollectionView.frame = rectContent;
    _doneTable.frame = rectContent;
    _willDoTable.frame = rectContent;
    
    _searchType = tag;
    _auctionDoing.textColor =[UIColor darkTextColor];
    _auctionWillDo.textColor =[UIColor darkTextColor];
    _auctionDone.textColor =[UIColor darkTextColor];
    UILabel *curLabel = (UILabel *)[_titleView viewWithTag:tag];
    curLabel.textColor = APP_SYS_RED_COLOR;
    
    self.navigationItem.rightBarButtonItem = nil;
    if (tag == 1) {
        _doingView.hidden = NO;
        _doneView.hidden = YES;
        _willDoView.hidden = YES;
        self.navigationItem.rightBarButtonItem = _rightButton;
    }else if (tag == 2){
        _doingView.hidden = YES;
        _doneView.hidden = NO;
        _willDoView.hidden = YES;
        self.navigationItem.rightBarButtonItem = _rightButton;
        HMGlobalParams *params = [HMGlobalParams sharedInstance];
        if (params.anonymous) {
            HMLoginEx *login = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
            login.hideBackButton = YES;
            [self.navigationController pushViewController:login animated:NO];
        }
    }else if (tag == 3){
        _doingView.hidden = YES;
        _doneView.hidden = YES;
        _willDoView.hidden = NO;
        
    }
    [self query];
    
}

-(void) initSearchView
{
    if(menu) [menu removeFromSuperview];
    menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 40) andHeight:25];
    menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
    menu.separatorColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0];
    menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
    menu.dataSource = self;
    menu.delegate = self;
    menu.hidden = YES;
    [self.view addSubview:menu];
    _searchBar.text = @"";
    
}

-(void) showSearchView:(id *)tag
{
    if (_searchView.hidden == YES) {
        _searchView.hidden = NO;
        menu.hidden = NO;
    }else {
        _searchView.hidden = YES;
        menu.hidden = YES;
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }
    
    CGRect rectTitle = _titleView.frame;
    if (_searchView.hidden == NO) {
        rectTitle.origin.y = _searchView.frame.origin.y + _searchView.frame.size.height;
    }else{
        rectTitle.origin.y = 5;
    }
    _titleView.frame = rectTitle;
    
    CGRect rect = _doingView.frame;
    rect.origin.y = rectTitle.origin.y + rectTitle.size.height;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    _doingView.frame = rect;
    _willDoView.frame = rect;
    _doneView.frame = rect;
    
    CGRect rectContent = rect;
    rectContent.origin = CGPointMake(0, 0);
    _doingCollectionView.frame = rectContent;
    _doneTable.frame = rectContent;
    _willDoTable.frame = rectContent;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ClickTabBar:) name:@"HMArtTabBarClickedAtIndexFirst" object:nil];
    if (_resultDoingArray.count > 0) {
        [self performSelector:@selector(queryDoingRefresh) withObject:[NSNumber numberWithBool:YES] afterDelay:3.0];
    }
    
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryDoingRefresh) object:[NSNumber numberWithBool:YES]];
    
    [super viewDidDisappear:animated];
}

- (void)ClickTabBar:(NSNotification *)noticatication
{
    if (_timer) {
        [_timer invalidate];
    }
    if (_timer2) {
        [_timer2 invalidate];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryDoingRefresh) object:[NSNumber numberWithBool:YES]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"HMArtTabBarClickedAtIndexFirst" object:nil];
    [super viewWillDisappear:animated];
}


- (void)setParams:(NSString *)params
{
    NSDictionary *dicParam = [HMUtility parametersWithSeparator:@"=" delimiter:@"&" url:params];
    _level = [[dicParam objectForKey:@"areaId"] integerValue];
    _viewTitle = [dicParam objectForKey:@"title"];
}

- (void)tapAuctionStatus:(UITapGestureRecognizer *)tap
{
    NSInteger tag = [tap.view tag];
    [self switchView:tag];
    
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    _pageDoingIndex = 1;
    _pageDoingSize = 50;
    _pageDoneIndex = 1;
    _pageDoneSize = 50;
    _pageWillDoIndex = 1;
    _pageWillDoSize = 8;
    
    if(_resultDoingArray)[_resultDoingArray removeAllObjects];
    if(_countSecondsArray)[_countSecondsArray removeAllObjects];
    if(_countGroupSecondsArray)[_countGroupSecondsArray removeAllObjects];
    if(_resultDoneArray)[_resultDoneArray removeAllObjects];
    if(_resultWillDoArray)[_resultWillDoArray removeAllObjects];
    if(_resultWillDoGroupArray)[_resultWillDoGroupArray removeAllObjects];
    
    if (_timer2) {
        [_timer2 invalidate];
    }
    if (_timer) {
        [_timer invalidate];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryDoingRefresh) object:[NSNumber numberWithBool:YES]];
    
    if (_searchType == 1) {
        [self queryDoing];
    }else if (_searchType == 2){
        [self queryDone];
    }else if (_searchType == 3){
        [self queryWillDoGroup];
    }
    
}

- (void)queryDoing
{
    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestDoingId != 0) {
        [net cancelRequest:_requestDoingId];
    }

    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:_pageDoingIndex] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageDoingSize] forKey:@"pageSize"];
    [queryParam setValue:[NSNumber numberWithInteger:_searchType] forKey:@"type"];
    [queryParam setValue:[NSNumber numberWithInteger:_level] forKey:@"level"];
    
    [queryParam setValue:[NSNumber numberWithInteger:_curTimeId] forKey:@"timeLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curSortId] forKey:@"sortLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curPriceIndex] forKey:@"priceLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curTypeIndex] forKey:@"typeLabelId"];
    [queryParam setValue:_keyword forKey:@"keyword"];

    _requestDoingId = [net asynRequest:interfaceAuctionSearch with:queryParam needSSL:NO target:self action:@selector(dealAuctions:result:)];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_activity startAnimating];
    
}

- (void)queryDoingRefresh
{    
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestDoingRefreshId != 0) {
        [net cancelRequest:_requestDoingRefreshId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:1] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageDoingIndex*_pageDoingSize] forKey:@"pageSize"];
    [queryParam setValue:[NSNumber numberWithInteger:_searchType] forKey:@"type"];
    [queryParam setValue:[NSNumber numberWithInteger:_level] forKey:@"level"];
    
    [queryParam setValue:[NSNumber numberWithInteger:_curTimeId] forKey:@"timeLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curSortId] forKey:@"sortLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curPriceIndex] forKey:@"priceLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curTypeIndex] forKey:@"typeLabelId"];
    [queryParam setValue:_keyword forKey:@"keyword"];
    
    _requestDoingRefreshId = [net asynRequest:interfaceAuctionSearch with:queryParam needSSL:NO target:self action:@selector(refreshAuctions:result:)];
    [_activity startAnimating];
    [self performSelector:@selector(queryDoingRefresh) withObject:[NSNumber numberWithBool:YES] afterDelay:3.0];
}


- (void)queryDone
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestDoneId != 0 ) {
        [net cancelRequest:_requestDoneId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:_pageDoneIndex] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageDoneSize] forKey:@"pageSize"];
    [queryParam setValue:[NSNumber numberWithInteger:_searchType] forKey:@"type"];
    [queryParam setValue:[NSNumber numberWithInteger:_level] forKey:@"level"];
    
    [queryParam setValue:[NSNumber numberWithInteger:_curTimeId] forKey:@"timeLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curSortId] forKey:@"sortLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curPriceIndex] forKey:@"priceLabelId"];
    [queryParam setValue:[NSNumber numberWithInteger:_curTypeIndex] forKey:@"typeLabelId"];
    [queryParam setValue:_keyword forKey:@"keyword"];
    
    _requestDoneId = [net asynRequest:interfaceAuctionSearch with:queryParam needSSL:NO target:self action:@selector(dealAuctions:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)queryWillDoGroup
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestWillDoId != 0 ) {
        [net cancelRequest:_requestWillDoId];
    }
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:_level] forKey:@"level"];
    
    _requestWillDoId = [net asynRequest:interfaceAuctionDateGroup with:queryParam needSSL:NO target:self action:@selector(dealWillDoGroup:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)queryRec
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestWillDoRecId != 0 ) {
        [net cancelRequest:_requestWillDoRecId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:1] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:5] forKey:@"pageSize"];
    [queryParam setValue:[NSNumber numberWithInteger:_searchType] forKey:@"type"];
    [queryParam setValue:[NSNumber numberWithInteger:_level] forKey:@"level"];
    [queryParam setValue:[NSNumber numberWithInteger:1] forKey:@"top"];
    
    _requestWillDoRecId = [net asynRequest:interfaceAuctionSearch with:queryParam needSSL:NO target:self action:@selector(dealAuctionRec:result:)];
    
}

- (void)queryLabel
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestLabelId != 0) {
        [net cancelRequest:_requestLabelId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[NSNumber numberWithInteger:_level] forKey:@"level"];
    
    _requestLabelId = [net asynRequest:interfaceAuctLabelSearch with:queryParam needSSL:NO target:self action:@selector(dealLabel:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealAuctions:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    if (_searchType == 1) {
        _requestDoingId = 0;
    }else{
        _requestDoneId = 0;
    }
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        if (_searchType == 1) {
           
            if (_pageDoingIndex == 1) {
                [_resultDoingArray removeAllObjects];
                [_countSecondsArray removeAllObjects];
            }else{
                if (_timer) {
                    [_timer invalidate];
                }
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(queryDoingRefresh) object:[NSNumber numberWithBool:YES]];
            }
            [_doingCollectionView footerEndRefreshing];
            
            NSArray *data = [ret objectForKey:@"obj"];
            for (unsigned int i = 0; i < data.count; ++i) {
                [_resultDoingArray addObject:[data objectAtIndex:i]];
            }
            _pageDoingCount = [[ret objectForKey:@"pageCount"] integerValue];
            
            if (_pageDoingIndex < _pageDoingCount && _pageDoingCount > 1) {
                [_doingCollectionView addFooterWithTarget:self action:@selector(loadMoreDoingUp)];
                _doingCollectionView.footerPullToRefreshText = [NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageDoingIndex, (long)_pageDoingCount];
                _doingCollectionView.footerRefreshingText = @"正在加载数据，请耐心等待...";
                _doingCollectionView.footerReleaseToRefreshText = @"松开马上加载...";
            }else{
                [_doingCollectionView removeFooter];
            }

            [_doingCollectionView reloadData];
            [self initCount];
            [self performSelector:@selector(queryDoingRefresh) withObject:[NSNumber numberWithBool:YES] afterDelay:3.0];
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countdown) userInfo:nil repeats:YES];
        }else{
            if (_pageDoneIndex == 1) {
                [_resultDoneArray removeAllObjects];
            }
            [_doneTable footerEndRefreshing];
            NSArray *data = [ret objectForKey:@"obj"];
            for (unsigned int i = 0; i < data.count; ++i) {
                [_resultDoneArray addObject:[data objectAtIndex:i]];
            }
            _pageDoneCount = [[ret objectForKey:@"pageCount"] integerValue];

            if (_pageDoneIndex != _pageDoneCount && _pageDoneCount > 1) {
                [_doneTable addFooterWithTarget:self action:@selector(loadMoreDoneUp)];
                _doneTable.footerPullToRefreshText = [NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageDoneIndex, (long)_pageDoneCount];
                _doneTable.footerRefreshingText = @"正在加载数据，请耐心等待...";
                _doneTable.footerReleaseToRefreshText = @"松开马上加载...";
            }else{
                [_doneTable removeFooter];
            }
            [_doneTable reloadData];
        }
        
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"%@查询失败!" inView:self.view];
        }
    }
}

- (void)refreshAuctions:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestDoingId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        
        NSArray *data = [ret objectForKey:@"obj"];
        if (_resultDoingArray.count == data.count) {
            for (unsigned int i = 0; i < data.count; ++i) {
                [_resultDoingArray replaceObjectAtIndex:i withObject:[data objectAtIndex:i]];
            }
        }
        [self refreshPriceAndTimes];
    }
}

- (void)dealAuctionRec:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    _requestWillDoRecId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        
        [_resultWillDoArray removeAllObjects];
        NSArray *data = [ret objectForKey:@"obj"];
        for (NSDictionary *item in data) {
            [_resultWillDoArray addObject:item];
            [_willDoRecImage addItem:[item objectForKey:@"image"]];
        }
    
    }
}

- (void)dealWillDoGroup:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];

    _requestWillDoId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        
        [_resultWillDoGroupArray removeAllObjects];
        [_countGroupSecondsArray removeAllObjects];
        
        NSArray *data = [ret objectForKey:@"obj"];
        for (NSDictionary *group in data) {
            [_resultWillDoGroupArray addObject:group];
        }
        
        [_willDoTable reloadData];
        [self initCountGroup];
        _timer2 = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countGroup) userInfo:nil repeats:YES];
        
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"%@查询失败!" inView:self.view];
        }
    }
}


- (void)dealLabel:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestLabelId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        
        NSDictionary *dic = [ret objectForKey:@"obj"];
        
        [_data1 removeAllObjects];
        [_data2 removeAllObjects];
        [_data3 removeAllObjects];
        [_data4 removeAllObjects];
        _sortArray = [dic objectForKey:@"sortLabel"];
        for (unsigned int i = 0; i < _sortArray.count; ++i) {
            [_data1 addObject:[[_sortArray objectAtIndex:i] objectForKey:@"name"]];
            
        }
        _data2 = [dic objectForKey:@"priceLabel"];
        _data3 = [[NSMutableArray alloc] initWithCapacity:1];
        _timeArray = [dic objectForKey:@"timeLabel"];
        for (unsigned int i = 0; i < _timeArray.count; ++i) {
            [_data3 addObject:[[_timeArray objectAtIndex:i] objectForKey:@"name"]];
        }
        _data4 = [dic objectForKey:@"typeLabel"];
        if(_data4 == nil)
            _data4 = [NSMutableArray arrayWithObjects:@"所有来源", @"平台自营", @"签约商家", @"二次销售", nil];
        
        
        [self initSearchView];
        
        
    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
    }
}


- (void)loadMoreDoingDown
{
    _pageDoingIndex--;
    if (_pageDoingIndex < 1) {
        _pageDoingIndex = 1;
        return;
    }
    [self queryDoing];
}

- (void)loadMoreDoingUp
{
    _pageDoingIndex++;
    if (_pageDoingIndex > _pageDoingCount) {
        _pageDoingIndex = _pageDoingCount;
        return;
    }
    [self queryDoing];
}

- (void)loadMoreDoneDown
{
    _pageDoneIndex--;
    if (_pageDoneIndex < 1) {
        _pageDoneIndex = 1;
        return;
    }
    [self queryDone];
}

- (void)loadMoreDoneUp
{
    _pageDoneIndex++;
    if (_pageDoneIndex > _pageDoneCount) {
        return;
    }
    [self queryDone];
}

#pragma mark -
#pragma mark collection view methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView.tag == 101) {
        return _resultDoingArray.count;
    }
    return _resultWillDoGroupArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 101 && _resultDoingArray.count > 0) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DOINGCELL_REUSEID forIndexPath:indexPath];
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
       NSDictionary *audict = [_resultDoingArray objectAtIndex:indexPath.row];
        HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(5, 5, 140, 130)];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        iv.image = [UIImage imageNamed:@"holder_320_180.png"];
        NSString *imgUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [audict objectForKey:@"image"]];
        iv.imageUrl = imgUrl;
        [iv load];
        [cell.contentView addSubview:iv];
        
        
        UILabel *labelCode = [[UILabel alloc] initWithFrame:CGRectMake(5, 135, 110, 15)];
        labelCode.backgroundColor = [UIColor clearColor];
        labelCode.font = [UIFont systemFontOfSize:11.0];
        labelCode.text = [NSString stringWithFormat:@"编号:%@", [audict objectForKey:@"code"]]; //[coupon objectForKey:@"name"];
        [cell.contentView addSubview:labelCode];
        
        UILabel *ownerCode = [[UILabel alloc] initWithFrame:CGRectMake(5, 155, 95, 15)];
        ownerCode.backgroundColor = [UIColor clearColor];
        ownerCode.font = [UIFont systemFontOfSize:11.0];
        ownerCode.text = [NSString stringWithFormat:@"%@", [audict objectForKey:@"ownerTypeZH"]]; //[coupon objectForKey:@"name"];
        [cell.contentView addSubview:ownerCode];
        
        
        UILabel *labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(5, 170, 95, 15)];
        labelPrice.backgroundColor = [UIColor clearColor];
        labelPrice.font = [UIFont systemFontOfSize:11.0];
        labelPrice.textColor = [UIColor redColor];
        labelPrice.tag = 1003;
        NSNumber *price = [audict objectForKey:@"auctionPrice"];
        if (price) {
            labelPrice.text = [NSString stringWithFormat:@"当前价格:￥%@", price];
        }else{
            labelPrice.text = @"当前价格:未出价";
        }
        [cell.contentView addSubview:labelPrice];

        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(5, 185, 140, 15)];
        labelName.backgroundColor = [UIColor clearColor];
        labelName.font = [UIFont systemFontOfSize:13.0];
        labelName.text = [audict objectForKey:@"artName"]; //[coupon objectForKey:@"name"];
        [cell.contentView addSubview:labelName];
        
        UILabel *labelRemain = [[UILabel alloc] initWithFrame:CGRectMake(5, 200, 140, 15)];
        labelRemain.backgroundColor = [UIColor clearColor];
        labelRemain.font = [UIFont systemFontOfSize:11.0];
        labelRemain.textColor = [UIColor redColor];
        labelRemain.tag = 1001;
        labelRemain.text = @"距离结束:";
        [cell.contentView addSubview:labelRemain];

        //出价按钮区域
        UIView *dealView = [[UIView alloc] initWithFrame:CGRectMake(100, 151, 45, 35)];
        dealView.backgroundColor = [UIColor brownColor];
        dealView.autoresizesSubviews = NO;
        dealView.tag = 10000 + indexPath.row;
        
        UILabel *labelDeal = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 45, 15)];
        labelDeal.backgroundColor = [UIColor clearColor];
        labelDeal.font = [UIFont systemFontOfSize:9.0];
        labelDeal.textColor = [UIColor whiteColor];
        labelDeal.textAlignment = NSTextAlignmentCenter;
        labelDeal.text = @"我要竞买";
        [dealView addSubview:labelDeal];
 
        UILabel *labelTimes = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 45, 20)];
        labelTimes.backgroundColor = [UIColor clearColor];
        labelTimes.font = [UIFont systemFontOfSize:9.0];
        labelTimes.textAlignment = NSTextAlignmentCenter;
        labelTimes.tag = 1002;
        NSInteger times = [[audict objectForKey:@"auctionNumber"] integerValue];
        labelTimes.text = [NSString stringWithFormat:@"出价%ld次", (long)times];
       [dealView addSubview:labelTimes];

//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDoingAuction:)];
//        tap.numberOfTapsRequired = 1;
//        tap.numberOfTouchesRequired = 1;
//        tap.cancelsTouchesInView = NO;
//        [dealView addGestureRecognizer:tap];
        [cell.contentView addSubview:dealView];
        
        cell.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.contentView.layer.borderWidth = 1.0;
        return  cell;
    }else{
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:WILLDOCELL_REUSEID forIndexPath:indexPath];
        
        return  cell;
    }

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView.tag == 101) {
        NSDictionary *item = [_resultDoingArray objectAtIndex:indexPath.row];
        HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
        ctrl.code = [item objectForKey:@"code"];
        ctrl.level = _level;
        ctrl.title = [item objectForKey:@"artName"];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

- (void)tapDoingAuction:(UITapGestureRecognizer *)recognize
{
    NSInteger tag = [recognize.view tag];
    NSInteger row = tag - 10000;
    NSDictionary *item = [_resultDoingArray objectAtIndex:row];
    HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.code = [item objectForKey:@"code"];
//    ctrl.level = _level;
    ctrl.title = [item objectForKey:@"artName"];
    [self.navigationController pushViewController:ctrl animated:YES];

}

#pragma mark -
#pragma mark tableview methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_searchType == 3) {
        return _resultWillDoGroupArray.count;
    }
    return _resultDoneArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchType == 3) {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    }
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchType == 2 && _resultDoneArray.count > 0) {
        static NSString *CellIdentifier = @"hmAuditCell";
        HMTransactionRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [HMUtility loadViewFromNib:@"HMTransactionRecordCell" withClass:[HMTransactionRecordCell class]];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        NSDictionary *item = [_resultDoneArray objectAtIndex:indexPath.section];
        cell.auditImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [item objectForKey:@"image"]];
        [cell.auditImage load];
        cell.nameLabel.text = [item objectForKey:@"artName"];
        cell.codeLabel.text = [NSString stringWithFormat:@"编号：%@", [item objectForKey:@"code"]];
        cell.authorLabel.text = [NSString stringWithFormat:@"作者：%@", [item objectForKey:@"artist"]];
        NSInteger auctionStatus = [[item objectForKey:@"auctionStatus"] integerValue];
        if (auctionStatus == 3) {
            cell.dealTimeLabel.text = [NSString stringWithFormat:@"竞买时间：%@", [item objectForKey:@"auctionDate"]];
            cell.priceLabel.text = [NSString stringWithFormat:@"成交价：￥%@", [item objectForKey:@"auctionPrice"]];
            cell.locationLabel.text = [NSString stringWithFormat:@"归属地：%@", [item objectForKey:@"area"]];
        }else{
            cell.priceLabel.text = @"流拍";
            cell.locationLabel.text = @"";
            cell.dealTimeLabel.text = @"";
        }
        return cell;
    }else if(_searchType == 3 && _resultWillDoGroupArray.count > 0){
        static NSString *CellIdentifier = @"WillDoCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        for (UIView *subview in cell.contentView.subviews) {
            [subview removeFromSuperview];
        }
        
        NSDictionary *dic = [_resultWillDoGroupArray objectAtIndex:indexPath.section];
        
        LCView *cellView = [[LCView alloc] initWithFrame:CGRectMake(0, 5, 320, 0)];
        [cellView setPaddingTop:3 paddingBottom:3 paddingLeft:4 paddingRight:4];
        cellView.tag = 100;
        cellView.backgroundColor = [UIColor clearColor];
        [cell addSubview:cellView];
        
        LCView *v1 = [[LCView alloc] initWithFrame:CGRectMake(4, 0, cellView.frame.size.width, 0)];
        [v1 setPaddingTop:5 paddingBottom:4 paddingLeft:5 paddingRight:5];
        [cellView addCustomSubview:v1 intervalTop:0];
        v1.backgroundColor = [UIColor whiteColor];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v1.frame.size.width*0.5, 0)];
        name.text = [dic objectForKey:@"name"];
        [v1 addCustomSublabel:name intervalLeft:0];
        
        UILabel *remainTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v1.frame.size.width*0.5, name.frame.size.height)];
        remainTime.tag = 1000;
        name.textColor = [UIColor redColor];
        remainTime.textAlignment = NSTextAlignmentRight;
        [v1 addCustomSublabel:remainTime intervalLeft:0];
        
        LCView *imageView = [[LCView alloc] initWithFrame:CGRectMake(4, 0, cellView.frame.size.width, 0)];
        [imageView setPaddingTop:0 paddingBottom:0 paddingLeft:1 paddingRight:1];
        [cellView addCustomSubview:imageView intervalTop:0];
        imageView.backgroundColor = [UIColor whiteColor];
        
        HMNetImageView *image = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width, 102)];
        image.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image1"]];
        [image load];
        [imageView addCustomSubview:image intervalTop:0];
        
        LCView *v2 = [[LCView alloc] initWithFrame:CGRectMake(0, 0, cellView.frame.size.width, 0)];
        [v2 setPaddingTop:5 paddingBottom:4 paddingLeft:5 paddingRight:5];
        [cellView addCustomSubview:v2 intervalTop:0];
        v2.backgroundColor = [UIColor whiteColor];
        
        UILabel *wordCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v2.frame.size.width*0.5-20, 0)];
        wordCount.text = [NSString stringWithFormat:@"%@件拍品",[dic objectForKey:@"workCount"]];
        [v2 addCustomSublabel:wordCount intervalLeft:0];
        
        UILabel *browseCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, v2.frame.size.width*0.5-30, 0)];
        browseCount.text = [NSString stringWithFormat:@"围观%@人",[dic objectForKey:@"browseCount"]];
        browseCount.textAlignment = NSTextAlignmentRight;
        [v2 addCustomSublabel:browseCount intervalLeft:0];
        
        UIButton *fenxiang = [UIButton buttonWithType:UIButtonTypeCustom];
        fenxiang.frame = CGRectMake(0, 0, 48, browseCount.frame.size.height);
        fenxiang.tag = 100+indexPath.section;
        NSLog(@"%i tag %i",indexPath.section,fenxiang.tag);
        [fenxiang setImage:[UIImage imageNamed:@"btn_share.png"] forState:UIControlStateNormal];
        fenxiang.userInteractionEnabled = YES;
        [fenxiang addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(share:)]];
        [v2 addCustomSubview:fenxiang intervalLeft:0];
        
        
        [cellView resize];
        
        float h = cellView.frame.size.height+cellView.frame.origin.y;
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width,h);
        return  cell;
    }else{
        static NSString *CellIdentifier = @"WillDoCell11";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_searchType == 3) {
        NSDictionary *item = [_resultWillDoGroupArray objectAtIndex:indexPath.section];
        HMAuctionPreview *ctrl = [[HMAuctionPreview alloc] initWithNibName:nil bundle:nil];
        ctrl.auditDate = [NSString stringWithFormat:@"%@ 开拍",[item objectForKey:@"startDate"]];
        ctrl.titleName = [item objectForKey:@"name"];
        ctrl.areaListId = [[item objectForKey:@"id"] integerValue];
        [self.navigationController pushViewController:ctrl animated:YES];
    }else{
        NSDictionary *item = [_resultDoneArray objectAtIndex:indexPath.section];
        HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
        ctrl.code = [item objectForKey:@"code"];
        ctrl.title = [item objectForKey:@"artName"];
        [self.navigationController pushViewController:ctrl animated:YES];
    }
}

#pragma mark -
#pragma mark animated imageview delegate
- (void)animatedImageView:(HMAnimateImageView *)animatedImageView tapAtIndex:(NSInteger)index
{
    if (index < 0 || index >= _resultWillDoArray.count) {
        return;
    }
    NSDictionary *auction = [_resultWillDoArray objectAtIndex:index];
    HMAuctionDetail *ctrl = [[HMAuctionDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.code = [auction objectForKey:@"code"];
    [self.navigationController pushViewController:ctrl animated:YES];

}


#pragma mark -
#pragma mark timer countdown
- (void)initCount
{
    for (int i = _countSecondsArray.count; i < _resultDoingArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [_doingCollectionView cellForItemAtIndexPath:indexPath];
        NSNumber *remainMilSeconds = [[_resultDoingArray objectAtIndex:i] objectForKey:@"remainTime"];
        UILabel *labelRemain = (UILabel *)[cell.contentView viewWithTag:1001];
        if (remainMilSeconds && [remainMilSeconds longLongValue] > 0) {
            NSUInteger remainSeconds = [remainMilSeconds longLongValue] / 1000;
            labelRemain.text = [NSString stringWithFormat:@"距离结束:%@", [HMUtility compareCurrentTimeBySeconds:remainSeconds]];
            [_countSecondsArray addObject:[NSNumber numberWithInteger:remainSeconds]];
        }else{
            labelRemain.text = @"已结束";
            [_countSecondsArray addObject:[NSNumber numberWithInteger:0]];
        }
    }
}

- (void)countdown
{
    for (int i = 0; i < _resultDoingArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [_doingCollectionView cellForItemAtIndexPath:indexPath];
        NSUInteger remainSeconds = [[_countSecondsArray objectAtIndex:i] integerValue];
        if (remainSeconds > 0) {
            UILabel *labelRemain = (UILabel *)[cell.contentView viewWithTag:1001];
            labelRemain.text = [NSString stringWithFormat:@"距离结束:%@", [HMUtility compareCurrentTimeBySeconds:remainSeconds]];
            remainSeconds--;
//            NSLog(@"remian%d-%d", i, remainSeconds);
            [_countSecondsArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:remainSeconds]];
        }
    }
}


- (void)refreshPriceAndTimes
{
    for (int i = 0; i < _resultDoingArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UICollectionViewCell *cell = [_doingCollectionView cellForItemAtIndexPath:indexPath];
        NSDictionary *item = [_resultDoingArray objectAtIndex:i];
        NSNumber *price = [item objectForKey:@"auctionPrice"];
        UILabel *labelPrice = (UILabel *)[cell.contentView viewWithTag:1003];
        if (price) {
            labelPrice.text = [NSString stringWithFormat:@"当前价格:￥%@", price];
        }else{
            labelPrice.text = @"当前价格:未出价";
        }
        NSInteger times = [[item objectForKey:@"auctionNumber"] integerValue];
        UILabel *labelTimes = (UILabel *)[cell.contentView viewWithTag:1002];
        labelTimes.text = [NSString stringWithFormat:@"出价%ld次", (long)times];
        
        NSNumber *remainMilSeconds = [[_resultDoingArray objectAtIndex:i] objectForKey:@"remainTime"];
        if (remainMilSeconds && [remainMilSeconds longLongValue] > 0) {
            NSUInteger remainSeconds = [remainMilSeconds longLongValue] / 1000;
            [_countSecondsArray addObject:[NSNumber numberWithInteger:remainSeconds]];
        }else{
            [_countSecondsArray addObject:[NSNumber numberWithInteger:0]];
        }
    }
}


#pragma mark -
#pragma mark timer countGroup
- (void)initCountGroup
{
    for (int i = 0; i < _resultWillDoGroupArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        UITableViewCell *cell = [_willDoTable cellForRowAtIndexPath:indexPath];
        NSNumber *remainMilSeconds = [[_resultWillDoGroupArray objectAtIndex:i] objectForKey:@"remainTime"];
        UIView *cellView = [cell viewWithTag:100];
        UILabel *labelRemain = (UILabel *)[cellView viewWithTag:1000];
        if (remainMilSeconds && [remainMilSeconds longLongValue] > 0) {
            NSUInteger remainSeconds = [remainMilSeconds longLongValue] / 1000;
            labelRemain.text = [NSString stringWithFormat:@"距离开始:%@", [HMUtility compareCurrentTimeBySeconds:remainSeconds]];
            [_countGroupSecondsArray addObject:[NSNumber numberWithInteger:remainSeconds]];
        }else{
            labelRemain.text = @"正在竞拍";
            [_countGroupSecondsArray addObject:[NSNumber numberWithInteger:0]];
        }
    }
}

- (void)countGroup
{
    for (int i = 0; i < _resultWillDoGroupArray.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:i];
        UITableViewCell *cell = [_willDoTable cellForRowAtIndexPath:indexPath];
        NSUInteger remainSeconds = [[_countGroupSecondsArray objectAtIndex:i] integerValue];
        UIView *cellView = [cell viewWithTag:100];
        UILabel *labelRemain = (UILabel *)[cellView viewWithTag:1000];
        if (remainSeconds > 0) {
            labelRemain.text = [NSString stringWithFormat:@"距离开始:%@", [HMUtility compareCurrentTimeBySeconds:remainSeconds]];
            remainSeconds--;
            [_countGroupSecondsArray replaceObjectAtIndex:i withObject:[NSNumber numberWithInteger:remainSeconds]];
        }
    }
}


#pragma mark -
#pragma mark JSDropDownMenu
- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu {
    return 4;
}

-(BOOL)displayByCollectionViewInColumn:(NSInteger)column{
//    if (column==0) {
//        return YES;
//    }
    return NO;
}

-(BOOL)haveRightTableViewInColumn:(NSInteger)column{
    return NO;
}

-(CGFloat)widthRatioOfLeftColumn:(NSInteger)column{
    return 1;
}

-(NSInteger)currentLeftSelectedRow:(NSInteger)column{
    if (column==0) {
        return _curSortIndex;
    }else if (column==1) {
        return _curPriceIndex;
    }else if (column==2) {
        return _curTimeIndex;
    }else if (column==3) {
        return _curTypeIndex;
    }
    return 0;
}

- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    
    self.navigationItem.rightBarButtonItem = nil;
    if (column==0) {
        return _data1.count;
    } else if (column==1){
        return _data2.count;
    } else if (column==2){
        return _data3.count;
    } else if (column==3){
        return _data4.count;
    }
    return 0;
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForColumn:(NSInteger)column{
    
    switch (column) {
        case 0: return @"类别";
            break;
        case 1: return @"价格";
            break;
        case 2: return @"年代";
            break;
        case 3: return @"来源";
            break;
        default:
            return nil;
            break;
    }
}

- (NSString *)menu:(JSDropDownMenu *)menu titleForRowAtIndexPath:(JSIndexPath *)indexPath {
    
    if (indexPath.column==0) {
        return _data1[indexPath.row];
    } else if (indexPath.column==1) {
        return _data2[indexPath.row];
    } else if (indexPath.column==2){
        return _data3[indexPath.row];
    } else {
        return _data4[indexPath.row];
    }
}

- (void)menu:(JSDropDownMenu *)menu didSelectRowAtIndexPath:(JSIndexPath *)indexPath {
    if (indexPath.column == 0) {
        _curSortIndex = indexPath.row;
        _curSortId = [[[_sortArray objectAtIndex:_curSortIndex] objectForKey:@"id"] integerValue];
    } else if(indexPath.column == 1){
        _curPriceIndex = indexPath.row;
    } else if(indexPath.column == 2){
        _curTimeIndex = indexPath.row;
        _curTimeId = [[[_timeArray objectAtIndex:_curTimeIndex] objectForKey:@"id"] integerValue];
    } else{
        _curTypeIndex = indexPath.row;
    }
    [self query];
    self.navigationItem.rightBarButtonItem = _rightButton;
}

#pragma mark
#pragma mark - UISearchBarDelegate 协议
// UISearchBar得到焦点并开始编辑时，执行该方法
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    [self controlAccessoryView:0.1];// 显示遮盖层。
    
    return YES;
}
// 取消按钮被按下时，执行的方法
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    self.searchBar.text = _keyword;
    
    [self controlAccessoryView:0];// 隐藏遮盖层。
}

// 键盘中，搜索按钮被按下，执行的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"---%@",searchBar.text);
    [self.searchBar resignFirstResponder];// 放弃第一响应者
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self controlAccessoryView:0];// 隐藏遮盖层。
    _keyword = self.searchBar.text;
    [self query];
}
// 遮罩层（按钮）-点击处理事件
- (void) ClickControlAction:(id)sender{
    NSLog(@"handleTaps");
    [self controlAccessoryView:0];
}
// 控制遮罩层的透明度
- (void)controlAccessoryView:(float)alphaValue{
    [UIView animateWithDuration:0.2 animations:^{
        //动画代码
        [_btnAccessoryView setAlpha:alphaValue];
    }completion:^(BOOL finished){
        if (alphaValue<=0) {
            [self.searchBar resignFirstResponder];
            [self.searchBar setShowsCancelButton:NO animated:YES];
            self.searchBar.text = _keyword;
        }
    }];
}

#pragma mark
#pragma mark - 预展分享
- (void)share:(id)sender {
    UIView *view = [sender view];
    NSInteger tag = [view tag];
    NSDictionary *dic = [_resultWillDoGroupArray objectAtIndex:tag-100];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image1"]];
    
    NSString *content = [NSString stringWithFormat:@"《%@》正在艺术交易中心APP预展。点击链接，可下载APP。",[dic objectForKey:@"name"]];
    
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

@end
