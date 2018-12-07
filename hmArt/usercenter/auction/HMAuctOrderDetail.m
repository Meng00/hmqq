//
//  HMAuctOrderDetail.m
//  hmArt
//
//  Created by 刘学 on 15/7/11.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctOrderDetail.h"

@interface HMAuctOrderDetail ()

@end

@implementation HMAuctOrderDetail

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"订单详情";
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
    
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self query];
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initPage
{
    [_topView removeFromSuperview];
    _topView = [[LCView alloc] initWithFrame:CGRectMake(0, 1, 320, 100)];
    _topView.tag = 100;
    [_topView setPaddingTop:0 paddingBottom:20 paddingLeft:0 paddingRight:0];
    [_scrollView addSubview:_topView];
    _topView.backgroundColor = [UIColor clearColor];
    
    /******  快递信息  **********/
    if([dic objectForKey:@"expressNumber"]){
        LCView *expressView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
        [expressView setPaddingTop:6 paddingBottom:6 paddingLeft:10 paddingRight:10];
        [_topView addCustomSubview:expressView intervalTop:10];
        expressView.backgroundColor = [UIColor whiteColor];
        
        UILabel *expressLabel = [[UILabel alloc] init];
        expressLabel.text = @"快递信息";
        [expressView addCustomSublabel:expressLabel intervalTop:0 font:[UIFont systemFontOfSize:14.0f]];
        
        UILabel *expressLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, expressView.frame.size.width, 0.25f)];
        [expressView addCustomSublabel:expressLine intervalTop:10];
        expressLine.backgroundColor = [UIColor grayColor];
        
        UILabel *expressNumber = [[UILabel alloc] init];
        expressNumber.text = [NSString stringWithFormat:@"快递单号: %@", [dic objectForKey:@"expressNumber"]];
        [expressView addCustomSublabel:expressNumber intervalTop:10 font:[UIFont systemFontOfSize:14.0f]];
        
        UILabel *expressCompany = [[UILabel alloc] init];
        expressCompany.text = [NSString stringWithFormat:@"快递公司: %@", [dic objectForKey:@"expressCompany"]];
        [expressView addCustomSublabel:expressCompany intervalTop:10 font:[UIFont systemFontOfSize:14.0f]];
        
        
    }
    
    
    
    /******  作品信息  **********/
    LCView *artworkView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
    [artworkView setPaddingTop:6 paddingBottom:6 paddingLeft:10 paddingRight:10];
    artworkView.userInteractionEnabled = YES;
    [artworkView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagArtworkDetail:)]];
    [_topView addCustomSubview:artworkView intervalTop:10];
    artworkView.backgroundColor = [UIColor whiteColor];
    
    LCView *artworkView1 = [[LCView alloc] initWithFrame:CGRectMake(0, 0, artworkView.frame.size.width, 0)];
    [artworkView addCustomSubview:artworkView1 intervalTop:0];
    
    UILabel *orderCode = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, artworkView1.frame.size.width*0.65, 0)];
    orderCode.text = [NSString stringWithFormat:@"订单号: %@", [dic objectForKey:@"code"]];
    [artworkView1 addCustomSublabel:orderCode intervalLeft:0 font:[UIFont systemFontOfSize:14.0f]];
    
    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, artworkView1.frame.size.width*0.35, 0)];
    status.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"orderStatusZh"]];
    status.textAlignment = NSTextAlignmentRight;
    [artworkView1 addCustomSublabel:status intervalLeft:0 font:[UIFont systemFontOfSize:14.0f]];
    
    UILabel *artLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, artworkView.frame.size.width, 0.25f)];
    [artworkView addCustomSublabel:artLine intervalTop:6];
    artLine.backgroundColor = [UIColor grayColor];
    
    LCView *artworkView2 = [[LCView alloc] initWithFrame:CGRectMake(0, 0, artworkView.frame.size.width, 0)];
    [artworkView addCustomSubview:artworkView2 intervalTop:6];
    
    HMNetImageView *image = [[HMNetImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    image.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, [dic objectForKey:@"image"]];
    [image load];
    [artworkView2 addCustomSubview:image intervalLeft:0];
    
    LCView *artworkView22 = [[LCView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [artworkView2 addCustomSubview:artworkView22 intervalLeft:10];
    
    
    UILabel *artName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 30)];
    artName.text = [dic objectForKey:@"artName"];
    [artworkView22 addCustomSublabel:artName intervalTop:0 font:[UIFont systemFontOfSize:14.0f]];
    
    UILabel *artist = [[UILabel alloc] init];
    artist.text = [NSString stringWithFormat:@"作   者: %@", [dic objectForKey:@"artist"]];
    [artworkView22 addCustomSublabel:artist intervalTop:3 font:[UIFont systemFontOfSize:14.0f]];
    
    
    /**********支付信息***************/
    LCView *paymentView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
    [paymentView setPaddingTop:6 paddingBottom:6 paddingLeft:10 paddingRight:10];
    [_topView addCustomSubview:paymentView intervalTop:10];
    paymentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *payLabel = [[UILabel alloc] init];
    payLabel.text = @"支付信息";
    [paymentView addCustomSublabel:payLabel intervalTop:0 font:[UIFont systemFontOfSize:14.0f]];
    
    UILabel *payLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, paymentView.frame.size.width, 0.25f)];
    [paymentView addCustomSublabel:payLine intervalTop:10];
    payLine.backgroundColor = [UIColor grayColor];
    
//    UILabel *pinkage = [[UILabel alloc] init];
//    if([[dic objectForKey:@"pinkage"] boolValue]){
//        pinkage.text = [NSString stringWithFormat:@"运    费: 免邮"];
//    }else{
//        pinkage.text = [NSString stringWithFormat:@"运    费: 到付"];
//    }
//    [paymentView addCustomSublabel:pinkage intervalTop:10 font:[UIFont systemFontOfSize:14.0f]];
    
    UILabel *auctionPrice = [[UILabel alloc] init];
    auctionPrice.text = [NSString stringWithFormat:@"竞买金额: ￥%@", [dic objectForKey:@"auctionPrice"]];
    [paymentView addCustomSublabel:auctionPrice intervalTop:10 font:[UIFont systemFontOfSize:14.0f]];
    
    UILabel *serviceAmount = [[UILabel alloc] init];
    serviceAmount.text = [NSString stringWithFormat:@"服务佣金: ￥%@", [dic objectForKey:@"serviceAmount"]];
    [paymentView addCustomSublabel:serviceAmount intervalTop:10 font:[UIFont systemFontOfSize:14.0f]];
    
    UILabel *createDate = [[UILabel alloc] init];
    createDate.text = [NSString stringWithFormat:@"竞拍时间: %@", [dic objectForKey:@"createDate"]];
    [paymentView addCustomSublabel:createDate intervalTop:10 font:[UIFont systemFontOfSize:14.0f]];
    
    if([dic objectForKey:@"payTime"]){
        UILabel *payDate = [[UILabel alloc] init];
        payDate.text = [NSString stringWithFormat:@"支付时间: %@", [dic objectForKey:@"payTime"]];
        [paymentView addCustomSublabel:payDate intervalTop:10 font:[UIFont systemFontOfSize:14.0f]];
        
    }
    
    if([dic objectForKey:@"deliveryTime"]){
        UILabel *deliveryTime = [[UILabel alloc] init];
        deliveryTime.text = [NSString stringWithFormat:@"发货时间: %@", [dic objectForKey:@"deliveryTime"]];
        [paymentView addCustomSublabel:deliveryTime intervalTop:10 font:[UIFont systemFontOfSize:14.0f]];
        
    }
    
    NSInteger orderStatus = [[dic objectForKey:@"orderStatus"] integerValue];
    if (orderStatus == 4) {
        UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
        paybut.frame = CGRectMake(200, 0, 110, 30);
        paybut.tag = 2004;
        [paybut setTitle:@"确认收货" forState:UIControlStateNormal];
        [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
        paybut.userInteractionEnabled = YES;
        [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSignFor:)]];
        [_topView addCustomSubview:paybut intervalTop:10];
    }else if(orderStatus == 5){
        BOOL isSale = [[dic objectForKey:@"isSale"] boolValue];
        if (!isSale) {
            UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
            paybut.frame = CGRectMake(200, 0, 110, 30);
            paybut.tag = 2005;
            [paybut setTitle:@"二次销售" forState:UIControlStateNormal];
            [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
            paybut.userInteractionEnabled = YES;
            [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSales:)]];
            [_topView addCustomSubview:paybut intervalTop:10];
        }
    }
    
    [_topView resize];
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.origin.y +_topView.frame.size.height+10);
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
    [queryParam setValue:[NSNumber numberWithInteger:_orderId] forKey:@"id"];
    
    _requestId = [net asynRequest:interfaceMemberAuctOrderDetail with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    [_topView removeFromSuperview];
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
        
        [self initPage];
    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
    }
}

-(void) tagArtworkDetail:(id)sender{
    HMArtworkDetail *ctrl = [[HMArtworkDetail alloc] initWithNibName:nil bundle:nil];
    ctrl.artworkId = [[dic objectForKey:@"artwork"] integerValue];
    [self.navigationController pushViewController:ctrl animated:YES];
}

-(void) tagSignFor:(id)sender{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
    [queryParam setValue:[NSNumber numberWithInteger:_orderId] forKey:@"orderId"];
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    
    _requestId = [net asynRequest:interfaceMemberAuctOrderSingFor with:queryParam needSSL:NO target:self action:@selector(dealSignFor:result:)];
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
}

- (void)dealSignFor:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        NSLog(@"%@", ret);
        [self query];
    } else {
        [HMUtility alert:@"操作失败!" title:@"提示"];
        //[HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(tagSignFor:)];
    }
    
}

-(void) tagSales:(id)sender{
    
    HMSalesRequest *ctrl = [[HMSalesRequest alloc] initWithNibName:nil bundle:nil];
    ctrl.orderId = _orderId;
    ctrl.artName = [dic objectForKey:@"artName"];
    [self.navigationController pushViewController:ctrl animated:YES];
    
}


@end
