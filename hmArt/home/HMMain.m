//
//  HMMain.m
//  hmArt
//
//  Created by wangyong on 14-8-12.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMMain.h"

@interface HMMain ()

@end

@implementation HMMain

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

    for (int i = 0; i < 10; i++) {
        HMNetImageView *iv = (HMNetImageView *)[_scrollView viewWithTag:(100+i)];
        iv.hidden = YES;
    }
    
    CGRect rect = _scrollView.frame;
    if (IOS7) {
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 29;
    }else{
        rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - 49;
    }
    _scrollView.frame = rect;
    _scrollView.backgroundColor = [UIColor clearColor];

/*    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMemberImage:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _memberImage.userInteractionEnabled = YES;
    [_memberImage addGestureRecognizer:tap];

    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPointsLabel:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    _pointsLabel.userInteractionEnabled = YES;
    [_pointsLabel addGestureRecognizer:tap];
 
    
    UITapGestureRecognizer *tapPointsImage =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPointsLabel:)];
    tapPointsImage.numberOfTapsRequired = 1;
    tapPointsImage.numberOfTouchesRequired = 1;
    _pointsImage.userInteractionEnabled = YES;
    [_pointsImage addGestureRecognizer:tapPointsImage];
 */
    UITapGestureRecognizer *tapPushImage =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNoticLabel:)];
    tapPushImage.numberOfTapsRequired = 1;
    tapPushImage.numberOfTouchesRequired = 1;
    _pointsImage.userInteractionEnabled = YES;
    [_pointsImage addGestureRecognizer:tapPushImage];

    _funcItems = [[NSMutableArray alloc] initWithCapacity:10];
    [self queryAds];
    
    [self queryVersion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self queryArea];
    self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    
    if (![_adImageView isSwitching]) {
        [_adImageView startSwitch];
    }
    //[self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_white_bg.png"]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([_adImageView isSwitching]) {
        [_adImageView stopSwitch];
    }
    self.navigationController.navigationBarHidden = NO;
    //[HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    //[self.tabBarController.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_bg"]];
    [super viewWillDisappear:animated];
    
}

- (void)tapMemberImage:(UITapGestureRecognizer *)tap
{
    if ([HMGlobalParams sharedInstance].anonymous) {
        HMLoginEx *login = [[HMLoginEx alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    HMUserCenter *ctrl = [[HMUserCenter alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}

- (void)tapPointsLabel:(UITapGestureRecognizer *)tap
{
    HMMemberPoints *ctrl = [[HMMemberPoints alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:ctrl animated:YES];
}

#pragma mark -
#pragma mark app version query
- (void)queryVersion
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestVersionId != 0) {
        [net cancelRequest:_requestVersionId];
    }
    _requestVersionId = [net asynExternalRequest:interfaceQueryVersionInStore cached:NO target:self action:@selector(dealVersion:result:)];
//    [net asynRequest:interfaceQueryVersionInStore with:nil needSSL:NO target:self action:@selector(dealVersion:result:)];
}

- (void)dealVersion:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    _requestVersionId = 0;
    
    NSDictionary *ret = result.value;
    NSArray *results = [ret objectForKey:@"results"];
    if (!results || (results.count == 0)) {
        return;
    }
    NSDictionary *appInfo = [results objectAtIndex:0];
    NSString *version = [appInfo objectForKey:@"version"];
    NSString *appName = [appInfo objectForKey:@"trackName"];
    if (version && version.length > 0) {
        NSString *numberVer = [version stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSDictionary *dictAppInfo = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [dictAppInfo objectForKey:@"CFBundleShortVersionString"];
        NSString *appVerNum = [appVersion stringByReplacingOccurrencesOfString:@"." withString:@""];//[dictAppInfo objectForKey:@"CFBundleVersion"];
        if ([numberVer integerValue] > [appVerNum integerValue]) {//app store版本号大于本地版本
            NSMutableString *tips = [NSMutableString stringWithFormat:@"%@V%@已发布",appName, version];
            [tips appendFormat:@"\n%@", [appInfo objectForKey:@"releaseNotes"]];
            [LCAlertView showWithTitle:@"升级提示" message:tips cancelTitle:@"稍后升级" cancelBlock:nil otherTitle:@"升级" otherBlock:^{[self upgradeApp];}];
        }else if([numberVer integerValue] == [appVerNum integerValue]){//两个版本号相同，本地是最新版本
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSString *localVerNum = [userDefaults stringForKey:LC_SYS_ID_BUILD_VER];
            if ((!localVerNum)  ||  ([appVerNum integerValue] > [localVerNum integerValue])) {
                [userDefaults setObject:appVersion forKey:LC_SYS_ID_APP_VERSION];
                [userDefaults setObject:appVerNum forKey:LC_SYS_ID_BUILD_VER];
                
                NSString *title = [NSString stringWithFormat:@"新版本特性(Ver%@)", appVersion];
                //每次发布更新时修改这个字符串
                NSString *newFeatures = [appInfo objectForKey:@"releaseNotes"];
                [LCAlertView showWithTitle:title message:newFeatures buttonTitle:@"确定"];
            }
        }
    }
    
}

- (void)upgradeApp
{
    NSString * url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", kAppStoreID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)drawScrollView:(NSDictionary *)dic
{
    
    if(_topView) [_topView removeFromSuperview];
    _topView = [[LCView alloc] initWithFrame:CGRectMake(4, 105, [[UIScreen mainScreen] bounds].size.width-8, 0)];
    _topView.backgroundColor = [UIColor clearColor];
    [_scrollView addSubview:_topView];
    
    
    /**   最新消息标签  */
    NSArray *news = [dic objectForKey:@"ins"];
    if (news.count > 0) {
        LCView *labelView = [[LCView alloc] init];
        [labelView setPaddingTop:10 paddingBottom:10 paddingLeft:2.5 paddingRight:2.5];
        [_topView addCustomSubview:labelView intervalTop:10];
        labelView.backgroundColor = [UIColor whiteColor];
        
        UILabel *newsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        newsLabel.text = @"最新动态: ";
        newsLabel.textColor = [UIColor redColor];
        newsLabel.tag = 1001;
        newsLabel.font = [UIFont systemFontOfSize:14.0f];
        newsLabel.userInteractionEnabled = YES;
        [newsLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnclickBut:)]];
        [labelView addCustomSublabel:newsLabel intervalLeft:10];
        
        UILabel *newsTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        newsTitle.text = [[news objectAtIndex:0] objectForKey:@"title"];
        //labelText.textColor = [UIColor grayColor];
        newsTitle.tag = 1001;
        newsTitle.font = [UIFont systemFontOfSize:14.0f];
        newsTitle.userInteractionEnabled = YES;
        [newsTitle addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnclickBut:)]];
        [labelView addCustomSublabel:newsTitle intervalLeft:5];
        
    }
    
    /*** 竞买区  ****/
    NSArray *areaList = [dic objectForKey:@"areas"];
    _areaItems = [NSMutableArray arrayWithArray:areaList];
    NSUInteger count = areaList.count;
    LCView *auctionView = [[LCView alloc] init];
    [_topView addCustomSubview:auctionView intervalTop:0];
    
    LCView *leftView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 155, 0)];
    [auctionView addCustomSubview:leftView intervalLeft:0];
    
    LCView *rightView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 155, 0)];
    [auctionView addCustomSubview:rightView intervalLeft:2];
    
    
    //NSLog(@"count/2=%i  count2= %i",count/2 ,count%2 );
    for (signed i = 0; i < count; i++) {
        if (i > 7) {
            break;
        }
        NSDictionary *area = [areaList objectAtIndex:i];
        
        HMNetImageView *iv = [[HMNetImageView alloc] init];
        iv.tag = 100 + i;
        iv.userInteractionEnabled = YES;
        iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [area objectForKey:@"image"]];
        [iv load];
        [iv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnclickBut:)]];
        
        LCView *labelView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 155, 0)];
        
        UILabel *areaName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 0, 16)];
        areaName.text = [area objectForKey:@"name"];
        [labelView addCustomSublabel:areaName intervalTop:0 textMaxShowWidth:150 textMaxShowHeight:16];
        
        UILabel *visitorName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 15)];
        visitorName.textAlignment = NSTextAlignmentRight;
        visitorName.text = [NSString stringWithFormat:@"围观：%@人",[area objectForKey:@"visitor"]];
        visitorName.textColor = [UIColor redColor];
        [labelView addCustomSublabel:visitorName intervalTop:0 textMaxShowWidth:150 textMaxShowHeight:15 font:[UIFont systemFontOfSize:12.0]];
        
        if (i == 0) {
            iv.frame = CGRectMake(0, 0, 155, 95);
            [leftView addCustomSubview:iv intervalTop:2];
            [leftView addCustomSubview:labelView intervalTop:0];
            
        }else if (i == 1) {
            iv.frame = CGRectMake(0, 0, 155, 123);
            [rightView addCustomSubview:iv intervalTop:2];
            [rightView addCustomSubview:labelView intervalTop:0];
            
        }else if (i == 2) {
            iv.frame = CGRectMake(0, 0, 155, 104);
            [leftView addCustomSubview:iv intervalTop:2];
            [leftView addCustomSubview:labelView intervalTop:0];
            
        }else if (i == 3) {
            iv.frame = CGRectMake(0, 0, 155, 95);
            [rightView addCustomSubview:iv intervalTop:2];
            [rightView addCustomSubview:labelView intervalTop:0];
        }else if (i == 4) {
            iv.frame = CGRectMake(0, 0, 155, 90);
            [leftView addCustomSubview:iv intervalTop:2];
            [leftView addCustomSubview:labelView intervalTop:0];
            
        }else if (i == 5) {
            iv.frame = CGRectMake(0, 0, 155, 133);
            [rightView addCustomSubview:iv intervalTop:2];
            [rightView addCustomSubview:labelView intervalTop:0];
        }else if (i == 6) {
            iv.frame = CGRectMake(0, 0, 155, 163);
            [leftView addCustomSubview:iv intervalTop:2];
            [leftView addCustomSubview:labelView intervalTop:0];
            
        }else if (i == 7) {
            iv.frame = CGRectMake(0, 0, 155, 101);
            [rightView addCustomSubview:iv intervalTop:2];
            [rightView addCustomSubview:labelView intervalTop:0];
        }
        labelView.backgroundColor = [UIColor whiteColor];
     
    }
    
    /**** 图片 ****/
    
    ahDic = [dic objectForKey:@"ah"];
    /**
    HMNetImageView *acutioneer = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 312, 84)];
    acutioneer.tag = 3001;
    acutioneer.userInteractionEnabled = YES;
    acutioneer.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [ahDic objectForKey:@"image"]];
    [acutioneer load];
    [acutioneer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnclickBut:)]];
    [_topView addCustomSubview:acutioneer intervalTop:2];
     **/
    
     _ahItems = [dic objectForKey:@"ahs2"];
//    for (signed i = 0; i < _ahItems.count; i++) {
//        NSDictionary *ah = [_ahItems objectAtIndex:i];
//        HMNetImageView *acutioneer = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 312, 64)];
//        acutioneer.tag = 3000 + i;
//        acutioneer.userInteractionEnabled = YES;
//        acutioneer.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [ah objectForKey:@"image"]];
//        [acutioneer load];
//        [acutioneer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAh:)]];
//        [_topView addCustomSubview:acutioneer intervalTop:2];
//    
//    }
    
    if(_ahItems.count > 0){
        NSDictionary *ah = [_ahItems objectAtIndex:0];
        HMNetImageView *acutioneer = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 312, 64)];
        acutioneer.tag = 3000 + 0;
        acutioneer.userInteractionEnabled = YES;
        acutioneer.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [ah objectForKey:@"image"]];
        [acutioneer load];
        [acutioneer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAh:)]];
        [_topView addCustomSubview:acutioneer intervalTop:2];
    }
    
    /****** 其他竞买区 ******/
    if (count > 8) {
        
        LCView *auctOtherView = [[LCView alloc] init];
        [_topView addCustomSubview:auctOtherView intervalTop:2];
        
        LCView *leftOtherView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 155, 0)];
        [auctOtherView addCustomSubview:leftOtherView intervalLeft:0];
        //leftOtherView.backgroundColor = [UIColor whiteColor];
        
        LCView *rightOtherView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 155, 0)];
        [auctOtherView addCustomSubview:rightOtherView intervalLeft:2];
        //rightOtherView.backgroundColor = [UIColor whiteColor];
        
        for (signed i = 8; i < count; i++) {
            NSDictionary *area = [areaList objectAtIndex:i];
            
            HMNetImageView *iv = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 155, 84)];
            iv.tag = 100 + i;
            iv.userInteractionEnabled = YES;
            iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [area objectForKey:@"image"]];
            [iv load];
            [iv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnclickBut:)]];
            
            LCView *labelView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 155, 0)];
            
            UILabel *areaName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 0, 16)];
            areaName.text = [area objectForKey:@"name"];
            [labelView addCustomSublabel:areaName intervalTop:0 textMaxShowWidth:150 textMaxShowHeight:16];
            
            UILabel *visitorName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 16)];
            visitorName.textAlignment = NSTextAlignmentRight;
            visitorName.text = [NSString stringWithFormat:@"围观：%@人",[area objectForKey:@"visitor"]];
            visitorName.textColor = [UIColor redColor];
            [labelView addCustomSublabel:visitorName intervalTop:0 textMaxShowWidth:150 textMaxShowHeight:16 font:[UIFont systemFontOfSize:12.0]];
            
            if (i%2 == 0) {
                [leftOtherView addCustomSubview:iv intervalTop:2];
                [leftOtherView addCustomSubview:labelView intervalTop:0];
            }else if (i%2 == 1) {
                [rightOtherView addCustomSubview:iv intervalTop:2];
                [rightOtherView addCustomSubview:labelView intervalTop:0];
            }
            labelView.backgroundColor=[UIColor whiteColor];
        }
        
    }

    if(_ahItems.count > 1){
        NSDictionary *ah = [_ahItems objectAtIndex:1];
        HMNetImageView *acutioneer = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 312, 64)];
        acutioneer.tag = 3000 + 1;
        acutioneer.userInteractionEnabled = YES;
        acutioneer.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [ah objectForKey:@"image"]];
        [acutioneer load];
        [acutioneer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAh:)]];
        [_topView addCustomSubview:acutioneer intervalTop:5];
    }
    
    if(_ahItems.count > 4){
        
        LCView *recView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [_topView addCustomSubview:recView intervalTop:4];
        
        LCView *galleryView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 155, 0)];
        [recView addCustomSubview:galleryView intervalLeft:0];
        galleryView.backgroundColor = [UIColor whiteColor];
        
        NSDictionary *galleryDic = [_ahItems objectAtIndex:3];
        HMNetImageView *gallery = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 155, 84)];
        //gallery.tag = 4001;
        gallery.tag = 3000 + 3;
        gallery.userInteractionEnabled = YES;
        //gallery.imageUrl = [NSString stringWithFormat:@"%@", LC_IMG_HUALANG];
        gallery.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [galleryDic objectForKey:@"image"]];
        [gallery load];
        //[gallery addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnclickBut:)]];
        [gallery addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAh:)]];
        [galleryView addCustomSubview:gallery intervalTop:0];
        
        UILabel *galleryName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 0, 16)];
        //galleryName.text = @"画廊精品";
        galleryName.text = [galleryDic objectForKey:@"title"];
        galleryName.textColor = [UIColor redColor];
        [galleryView addCustomSublabel:galleryName intervalTop:0 textMaxShowWidth:150 textMaxShowHeight:16];
        
        UILabel *gallery2Name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 15)];
        gallery2Name.textAlignment = NSTextAlignmentRight;
        gallery2Name.text = @"推荐专区";
        [galleryView addCustomSublabel:gallery2Name intervalTop:0 textMaxShowWidth:150 textMaxShowHeight:15 font:[UIFont systemFontOfSize:12.0]];
        
        
        LCView *artistView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 155, 0)];
        [recView addCustomSubview:artistView intervalLeft:2];
        artistView.backgroundColor = [UIColor whiteColor];
        
        NSDictionary *artistDic = [_ahItems objectAtIndex:4];
        HMNetImageView *artist = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 155, 84)];
        //artist.tag = 4002;
        artist.tag = 3000 + 4;
        artist.userInteractionEnabled = YES;
        //artist.imageUrl = [NSString stringWithFormat:@"%@", LC_IMG_YISHUJIA];
        artist.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [artistDic objectForKey:@"image"]];
        [artist load];
        //[artist addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnclickBut:)]];
        [artist addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAh:)]];
        [artistView addCustomSubview:artist intervalTop:0];
        
        UILabel *artistName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 0, 16)];
        //artistName.text = @"艺术名家";
        artistName.text = [artistDic objectForKey:@"title"];
        artistName.textColor = [UIColor redColor];
        [artistView addCustomSublabel:artistName intervalTop:0 textMaxShowWidth:150 textMaxShowHeight:16];
        
        UILabel *artist2Name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 15)];
        artist2Name.textAlignment = NSTextAlignmentRight;
        artist2Name.text = @"推荐专区";
        [artistView addCustomSublabel:artist2Name intervalTop:0 textMaxShowWidth:150 textMaxShowHeight:15 font:[UIFont systemFontOfSize:12.0]];
        

    }
    
    if(_ahItems.count > 2){
        NSDictionary *ah = [_ahItems objectAtIndex:2];
        HMNetImageView *acutioneer = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 312, 64)];
        acutioneer.tag = 3000 + 2;
        acutioneer.userInteractionEnabled = YES;
        acutioneer.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [ah objectForKey:@"image"]];
        [acutioneer load];
        [acutioneer addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAh:)]];
        [_topView addCustomSubview:acutioneer intervalTop:5];
    }
    
    
    [_topView resize];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.origin.y + _topView.frame.size.height+10);
}

- (void)tapOnclickBut:(UITapGestureRecognizer *)tap
{
    UIView *view = [tap view];
    NSInteger tag = view.tag;
    if (tag > 99 && tag < 1000) {
        
        NSDictionary *area = [_areaItems objectAtIndex: tag-100];
        
        HMAuctionArea *ctrl = [[HMAuctionArea alloc] initWithNibName:nil bundle:nil];
        ctrl.level = [[area objectForKey:@"level"] integerValue];
        ctrl.viewTitle = [area objectForKey:@"name"];
        [self.navigationController pushViewController:ctrl animated:YES];
        
    }else if (tag == 2001){
        
    }else if (tag == 3001){//拍卖商列表
        HMAuctioneerHome *ctrl = [[HMAuctioneerHome alloc] initWithNibName:nil bundle:nil];
        ctrl.titleName = [ahDic objectForKey:@"name"];
        [self.navigationController pushViewController:ctrl animated:YES];
        
       
//
        
    }else if (tag == 4001){//画廊
        HMGalleryCategory *ctrl = [[HMGalleryCategory alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
        
//        HMJSWebView *webEx = [[HMJSWebView alloc] initWithNibName:nil bundle:nil];
//        webEx.loadFromUrl = YES;
//        webEx.url = @"http://192.168.1.123:8080/art-interface/h5/record.html";
//        [self.navigationController pushViewController:webEx animated:YES];
//        
//        HMJsWebUserCenter *ctrl = [[HMJsWebUserCenter alloc] initWithNibName:nil bundle:nil];
//        [self.navigationController pushViewController:ctrl animated:YES];
//        
    }else if (tag == 4002){//艺术家
        HMArtistList *ctrl = [[HMArtistList alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
        
    }
}

#pragma mark -
#pragma mark query ads
- (void)queryAds
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestAdId != 0) {
        [net cancelRequest:_requestAdId];
    }
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity:1];
    [queryParam setValue:kAD_POS_CODE_HOME forKey:@"adPos"];
    
    _requestAdId = [net asynRequest:interfaceAds with:queryParam needSSL:NO target:self action:@selector(dealAds:withResult:)];
}

- (void)dealAds:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestAdId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSArray *adList = [result.value objectForKey:@"obj"];
        for (NSDictionary *ad in adList) {
            [_adImageView addItem:ad];
        }
        [_adImageView startSwitch];
    }
}

- (void)queryArea
{
    LCNetworkInterface *net = [LCNetworkInterface sharedInstance];
    if (_requestAreaId != 0) {
        [net cancelRequest:_requestId];
    }
    
    _requestId = [net asynRequest:interfaceHomeAreas with:nil needSSL:NO target:self action:@selector(dealAreas:withResult:)];
}

- (void)dealAreas:(NSString *)serviceName withResult:(LCInterfaceResult *)result
{
    _requestAreaId = 0;
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSLog(@"%@", result.value);
        NSDictionary *funcList = [result.value objectForKey:@"obj"];
        [self drawScrollView:funcList];
    }
}

- (void)tapRecommend:(UITapGestureRecognizer*)param
{
    NSInteger tag = [param.view tag] - 100;
    if (tag < 0 || tag > 9) {
        return;
    }
    for (NSDictionary *dictionary in _funcItems) {
        NSInteger index = [[dictionary objectForKey:@"num"] integerValue] - 1;
        if (index == tag) {
             //    [LCGlobalDeviceInfo submitDeviceInfoForAd:[dictionary objectForKey:@"name"] withType:@"HOME"];
            NSString *iosAddr = [dictionary objectForKey:@"url"];
            NSRange searchResult = [iosAddr rangeOfString:@"?"];
            NSDictionary *classNames = [HMGlobalParams sharedInstance].classNames;
            if (searchResult.location == NSNotFound) {
                NSString *localClass = [classNames objectForKey:iosAddr];
                id controller = [[NSClassFromString(localClass) alloc] init];
                if (controller != nil) {
                    self.navigationController.navigationBarHidden = NO;
                    [self.navigationController pushViewController:controller animated:true];
                }
            } else {
                NSString *className = [iosAddr substringToIndex:searchResult.location];
                NSString *params = [iosAddr substringFromIndex:(searchResult.location + 1)];
                NSString *localClass = [classNames objectForKey:className];
                id controller = [[NSClassFromString(localClass) alloc] init];
                if (controller != nil) {
                    if ([controller respondsToSelector:@selector(setParams:)]) {
                        [controller performSelector:@selector(setParams:) withObject:params];
                    }
                    self.navigationController.navigationBarHidden = NO;
                    [self.navigationController pushViewController:controller animated:true];
                }
                
            }
            
            break;
        }
    }
}


#pragma mark -
#pragma mark 中间区域广告图片点击
- (void)tapAh:(UITapGestureRecognizer*)tap
{
    UIView *view = [tap view];
    NSInteger tag = view.tag;
    if(tag >= 3000){
        NSInteger index = tag - 3000;
        NSDictionary *dictionary = [_ahItems objectAtIndex:index];
        NSInteger adType = [[dictionary objectForKey:@"type"] integerValue];
        //    [LCGlobalDeviceInfo submitDeviceInfoForAd:[dictionary objectForKey:@"name"] withType:@"HOME"];
        if (adType == 1) {
            
            NSString *iosAddr = [dictionary objectForKey:@"url"];
            NSRange searchResult = [iosAddr rangeOfString:@"?"];
            NSDictionary *classNames = [HMGlobalParams sharedInstance].classNames;
            if (searchResult.location == NSNotFound) {
                NSString *localClass = [classNames objectForKey:iosAddr];
                id controller = [[NSClassFromString(localClass) alloc] init];
                if (controller != nil) {
                    self.navigationController.navigationBarHidden = NO;
                    [self.navigationController pushViewController:controller animated:true];
                }
            } else {
                NSString *className = [iosAddr substringToIndex:searchResult.location];
                NSString *params = [iosAddr substringFromIndex:(searchResult.location + 1)];
                NSString *localClass = [classNames objectForKey:className];
                id controller = [[NSClassFromString(localClass) alloc] init];
                if (controller != nil) {
                    if ([controller respondsToSelector:@selector(setParams:)]) {
                        [controller performSelector:@selector(setParams:) withObject:params];
                    }
                    self.navigationController.navigationBarHidden = NO;
                    [self.navigationController pushViewController:controller animated:true];
                }
                
            }
            
        } else if (adType == 3){
            
            HMJSWebView *web = [[HMJSWebView alloc] initWithNibName:nil bundle:nil];
            web.url = [dictionary objectForKey:@"url"];
            [self.navigationController pushViewController:web animated:YES];
            
        } else if (adType == 2){
            // 判断result是不是Http链接，如果是打开浏览器
            NSURL *candidateURL = [NSURL URLWithString: [dictionary objectForKey:@"url"]];
            
            // 如果是URL, 则用浏览器访问
            if (candidateURL) {
                UIApplication *myApp = [UIApplication sharedApplication];
                [myApp openURL:candidateURL];
            }
        }
    }
    
}

@end
