//
//  HMSalesRequest.m
//  hmArt
//
//  Created by 刘学 on 15/7/20.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMSalesRequest.h"

@interface HMSalesRequest ()

@end

@implementation HMSalesRequest

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"二次销售";
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
    self.inputform = _scrollView;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
    
    _requestId = [net asynRequest:interfaceMemberAuctOrderSales with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
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
        
        [self initPage];
    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
    }
}

-(void)initPage
{
    
    
    [_topView removeFromSuperview];
    _topView = [[LCView alloc] initWithFrame:CGRectMake(0, 2, 320, 0)];
    [_scrollView addSubview:_topView];
    _topView.backgroundColor = [UIColor clearColor];
    
    LCView *titleView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
    [titleView setPaddingTop:16 paddingBottom:6 paddingLeft:10 paddingRight:10];
    [_topView addCustomSubview:titleView intervalTop:0];
    titleView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *incoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"misc_help.png"]];
    [titleView addCustomSubview:incoImage intervalLeft:0];
    
    UILabel *remark = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
    remark.text = @" >> 查看二次销售须知";
    remark.tag = 1001;
    remark.textColor = [UIColor redColor];
    remark.userInteractionEnabled = YES;
    [remark addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagRecharge:)]];
    [titleView addCustomSublabel:remark intervalLeft:10];
    
    LCView *balanceView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
    [balanceView setPaddingTop:6 paddingBottom:6 paddingLeft:10 paddingRight:10];
    [_topView addCustomSubview:balanceView intervalTop:0];
    balanceView.backgroundColor = [UIColor whiteColor];
    
    UILabel *balance = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
    balance.text = [NSString stringWithFormat:@"当前余额：￥%@", [dic objectForKey:@"balance"]];
    [balanceView addCustomSublabel:balance intervalLeft:0];
    
    UILabel *recharge = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 0)];
    recharge.text = [NSString stringWithFormat:@"去充值"];
    recharge.tag = 1002;
    recharge.textAlignment = NSTextAlignmentRight;
    recharge.userInteractionEnabled = YES;
    [recharge addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagRecharge:)]];
    [balanceView addCustomSublabel:recharge intervalLeft:0];
    
    
    LCView *orderView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
    [orderView setPaddingTop:3 paddingBottom:10 paddingLeft:10 paddingRight:10];
    [_topView addCustomSubview:orderView intervalTop:2];
    orderView.backgroundColor = [UIColor whiteColor];
    
    UILabel *artName = [[UILabel alloc] init];
    artName.text = [NSString stringWithFormat:@"%@", self.artName];
    [orderView addCustomSublabel:artName intervalTop:0];
    
    UIView *line0 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [orderView addCustomSubview:line0 intervalTop:3];
    line0.backgroundColor = [UIColor grayColor];
    
    LCView *initPriceView = [[LCView alloc] init];
    [orderView addCustomSubview:initPriceView intervalTop:10];
    
    UILabel *initPriceTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 0)];
    initPriceTitle.text = @"起拍价：";
    [initPriceView addCustomSublabel:initPriceTitle intervalLeft:0];
    
    _initPriceField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    _initPriceField.borderStyle = UITextBorderStyleNone;
    _initPriceField.keyboardType = UIKeyboardTypeNumberPad;
    _initPriceField.delegate = self;
    _initPriceField.placeholder = @"请输入起拍价";
    _initPriceField.tag = 1004;
    [initPriceView addCustomSubview:_initPriceField intervalLeft:5];
    [self addInput:_initPriceField sequence:1 name:nil];
    
    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
    [orderView addCustomSubview:line1 intervalTop:3];
    line1.backgroundColor = [UIColor grayColor];
    
    LCView *incrementView = [[LCView alloc] init];
    [orderView addCustomSubview:incrementView intervalTop:10];
    
    UILabel *incrementTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 0)];
    incrementTitle.text = @"加价幅度：";
    [incrementView addCustomSublabel:incrementTitle intervalLeft:0];
    
    _incrementField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    _incrementField.borderStyle = UITextBorderStyleNone;
    _incrementField.keyboardType = UIKeyboardTypeNumberPad;
    _incrementField.delegate = self;
    _incrementField.placeholder = @"请输入加价幅度";
    _incrementField.tag = 1005;
    [incrementView addCustomSubview:_incrementField intervalLeft:5];
    [self addInput:_incrementField sequence:1 name:nil];
    
    LCView *fees = [[LCView alloc] init];
    [fees setPaddingTop:0 paddingBottom:5 paddingLeft:5 paddingRight:5];
    [_topView addCustomSubview:fees intervalTop:10];
    
    UILabel *feeLable = [[UILabel alloc] init];
    feeLable.text = @"服务费说明：";
    feeLable.textColor = [UIColor redColor];
    [fees addCustomSublabel:feeLable intervalTop:0];
    
    NSArray *feesArray = [dic objectForKey:@"fees"];
    for (signed i = 0; i < feesArray.count; i++) {
        if(i < feesArray.count - 1){
            NSDictionary *d = [feesArray objectAtIndex:i];
            NSDictionary *d2 = [feesArray objectAtIndex:i+1];
            UILabel *f = [[UILabel alloc] init];
            f.text = [NSString stringWithFormat:@"起拍价%@-%@ 收取￥%@元服务费",[d objectForKey:@"amount"],[d2 objectForKey:@"amount"],[d objectForKey:@"ratio"]];
            f.textColor = [UIColor grayColor];
            [fees addCustomSublabel:f intervalTop:5];
        }else{
            NSDictionary *d = [feesArray objectAtIndex:i];
            UILabel *f = [[UILabel alloc] init];
            f.text = [NSString stringWithFormat:@"起拍价 %@及以上 收取￥%@元服务费",[d objectForKey:@"amount"],[d objectForKey:@"ratio"]];
            f.textColor = [UIColor grayColor];
            [fees addCustomSublabel:f intervalTop:5];
        }
    }
    
    UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
    paybut.frame = CGRectMake(10, 0, 300, 25);
    paybut.tag = 1001;
    [paybut setTitle:@"提交申请" forState:UIControlStateNormal];
    [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
    paybut.userInteractionEnabled = YES;
    [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sales:)]];
    [_topView addCustomSubview:paybut intervalTop:10];
    

    
    [_topView resize];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.origin.y +_topView.frame.size.height+10);
    
}

- (void)sales:(id)sender
{
    if (_initPriceField.text.length == 0) {
        [HMUtility showTipInView:self.view withText:@"请输入起拍价"];
        return;
    }
    if (_incrementField.text.length == 0) {
        [HMUtility showTipInView:self.view withText:@"请输入加价幅度"];
        return;
    }
    NSMutableString *tips = nil;
    NSArray *feesArray = [dic objectForKey:@"fees"];
    NSInteger price = [_initPriceField.text integerValue];
    for (signed i = feesArray.count-1; i > -1; i--) {
        if (price >= [[[feesArray objectAtIndex:i] objectForKey:@"amount"] integerValue]) {
            tips = [NSMutableString stringWithFormat:@"您本次需要支付￥%i元服务费。请确保您的账号余额充足，以免影响审核。",[[[feesArray objectAtIndex:i] objectForKey:@"ratio"] integerValue]];
            break;
        }
    }
    
    [LCAlertView showWithTitle:@"提示" message:tips cancelTitle:@"去充值"
        cancelBlock:^{
            HMRecharge *ctrl = [[HMRecharge alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:ctrl animated:YES];
            
        } otherTitle:@"提交申请" otherBlock:^{
        LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
        
        if (_requestId != 0) {
            [net cancelRequest:_requestId];
        }
        
        NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];
        [queryParam setValue:[HMGlobalParams sharedInstance].mobile forKey:@"username"];
        [queryParam setValue:[NSNumber numberWithInteger:_orderId] forKey:@"orderId"];
        [queryParam setValue:[NSNumber numberWithDouble:[_initPriceField.text doubleValue]] forKey:@"initPrice"];
            [queryParam setValue:[NSNumber numberWithDouble:[_incrementField.text doubleValue]] forKey:@"increment"];
            _requestId = [net asynRequest:interfaceMemberAuctOrderSalesSubmit with:queryParam needSSL:NO target:self action:@selector(dealSales:result:)];
        [_activity startAnimating];
        [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];

        }
    ];
    
    
}

- (void)dealSales:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        //NSDictionary *ret = result.value;
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        [HMUtility alert:result.message title:@"提示"];
    }
}


-(void) tagRecharge:(id)sender{
    
    UIView *view = [sender view];
    NSInteger tag = view.tag;
    
    if(tag == 1002){
        HMRecharge *ctrl = [[HMRecharge alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:ctrl animated:YES];
    }else if(tag == 1001){
        LCWebView *web = [[LCWebView alloc] initWithNibName:nil bundle:nil];
        web.url = kUrlSalesNotice;
        web.title = @"二次销售须知";
        [self.navigationController pushViewController:web animated:YES];
    }
}

@end
