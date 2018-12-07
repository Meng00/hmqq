//
//  HMAuctSearch.m
//  hmArt
//
//  Created by 刘学 on 15/7/31.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import "HMAuctSearch.h"

@interface HMAuctSearch ()

@end

@implementation HMAuctSearch

@synthesize curTimeIndex;
@synthesize curSortIndex;
@synthesize curPriceIndex;
@synthesize keyword;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"搜索";
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
    
    
    _topView = [[LCView alloc] initWithFrame:CGRectMake(4, 5, 312, 0)];
    [_topView setPaddingTop:10 paddingBottom:10 paddingLeft:10 paddingRight:10];
    [_scrollView addSubview:_topView];
    _topView.backgroundColor = [UIColor whiteColor];
    
    if(!curTimeIndex)curTimeIndex = 0;
    if(!curSortIndex)curSortIndex = 0;
    if(!curPriceIndex)curPriceIndex = 0;
    
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
    
    _requestId = [net asynRequest:interfaceAuctLabelSearch with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
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
        
        dic = [ret objectForKey:@"obj"];
        
        
        _timeArray = [[NSMutableArray alloc] initWithCapacity:1];
        NSArray *data = [dic objectForKey:@"timeLabel"];
        for (unsigned int i = 0; i < data.count; ++i) {
            [_timeArray addObject:[[data objectAtIndex:i] objectForKey:@"name"]];
        }
        
        _sortArray = [[NSMutableArray alloc] initWithCapacity:1];
        _data1 = [[NSMutableArray alloc] initWithCapacity:1];
        data = [dic objectForKey:@"sortLabel"];
        for (unsigned int i = 0; i < data.count; ++i) {
            [_sortArray addObject:[[data objectAtIndex:i] objectForKey:@"name"]];
            
        }

        _priceArray = [dic objectForKey:@"priceLabel"];
        
        _data1 = _sortArray;
        _data2 = _priceArray;
        _data3 = _timeArray;
        _data4 = [NSMutableArray arrayWithObjects:@"所有来源", @"平台自营", @"签约商家", @"二次销售", nil];
        
        menu = [[JSDropDownMenu alloc] initWithOrigin:CGPointMake(0, 10) andHeight:35];
        menu.indicatorColor = [UIColor colorWithRed:175.0f/255.0f green:175.0f/255.0f blue:175.0f/255.0f alpha:1.0];
        menu.separatorColor = [UIColor colorWithRed:210.0f/255.0f green:210.0f/255.0f blue:210.0f/255.0f alpha:1.0];
        menu.textColor = [UIColor colorWithRed:83.f/255.0f green:83.f/255.0f blue:83.f/255.0f alpha:1.0f];
        menu.dataSource = self;
        menu.delegate = self;
        
        //[_scrollView addSubview:menu];
        CGRect frame = _topView.frame;
        //frame.origin.y = 55;
        //_topView.frame = frame;
        
        LCView *timeLabelView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
        timeLabelView.tag = 1001;
        timeLabelView.userInteractionEnabled = YES;
        [timeLabelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onclickBut:)]];
        [_topView addCustomSubview:timeLabelView intervalTop:0];
        
        UILabel *timeLabelTitle = [[UILabel alloc] init];
        timeLabelTitle.text = @"类   别: ";
        [timeLabelView addCustomSublabel:timeLabelTitle intervalLeft:0];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
        _timeLabel.text = [NSString stringWithFormat:@"全部"];
        [timeLabelView addCustomSublabel:_timeLabel intervalLeft:10];
        
        UIImageView *timeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        timeImage.image = [UIImage imageNamed:@"right_arrow.png"];
        [timeLabelView addCustomSubview:timeImage intervalLeft:10];
        
        UIView *line00 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        [_topView addCustomSubview:line00 intervalTop:10];
        line00.backgroundColor = [UIColor grayColor];
        
        LCView *priceLabelView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
        priceLabelView.tag = 1002;
        priceLabelView.userInteractionEnabled = YES;
        [priceLabelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onclickBut:)]];
        [_topView addCustomSubview:priceLabelView intervalTop:10];
        
        UILabel *priceLabelTitle = [[UILabel alloc] init];
        priceLabelTitle.text = @"价   格: ";
        [priceLabelView addCustomSublabel:priceLabelTitle intervalLeft:0];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
        _priceLabel.text = [NSString stringWithFormat:@"全部"];
        [priceLabelView addCustomSublabel:_priceLabel intervalLeft:10];
        
        UIImageView *priceImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        priceImage.image = [UIImage imageNamed:@"right_arrow.png"];
        [priceLabelView addCustomSubview:priceImage intervalLeft:10];
        
        UIView *line01 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        [_topView addCustomSubview:line01 intervalTop:10];
        line01.backgroundColor = [UIColor grayColor];
        
        LCView *sortLabelView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
        sortLabelView.tag = 1003;
        sortLabelView.userInteractionEnabled = YES;
        [sortLabelView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onclickBut:)]];
        [_topView addCustomSubview:sortLabelView intervalTop:10];
        
        UILabel *sortLabelTitle = [[UILabel alloc] init];
        sortLabelTitle.text = @"属   性: ";
        [sortLabelView addCustomSublabel:sortLabelTitle intervalLeft:0];
        
        _sortLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
        _sortLabel.text = [NSString stringWithFormat:@"全部"];
        [sortLabelView addCustomSublabel:_sortLabel intervalLeft:10];
        
        UIImageView *sortImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
        sortImage.image = [UIImage imageNamed:@"right_arrow.png"];
        [sortLabelView addCustomSubview:sortImage intervalLeft:10];
        
        UIView *line02 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 1)];
        [_topView addCustomSubview:line02 intervalTop:10];
        line02.backgroundColor = [UIColor grayColor];
        
        LCView *artworkView = [[LCView alloc] initWithFrame:CGRectMake(0, 0, _topView.frame.size.width, 0)];
        [_topView addCustomSubview:artworkView intervalTop:10];
        
        UILabel *artworkLabel = [[UILabel alloc] init];
        artworkLabel.text = @"关键字: ";
        [artworkView addCustomSublabel:artworkLabel intervalLeft:0];
        
        _artworkField = [[UITextField alloc]  initWithFrame:CGRectMake(0, 0, 0, 20)];
        _artworkField.borderStyle = UITextBorderStyleNone;
        _artworkField.delegate = self;
        _artworkField.placeholder = @"请输入作品或作者名称";
        _artworkField.tag = 2001;
        [artworkView addCustomSubview:_artworkField intervalLeft:10];
        [self addInput:_artworkField sequence:1 name:nil];
        
        
        UIButton *paybut = [UIButton buttonWithType:UIButtonTypeCustom];
        paybut.frame = CGRectMake(10, 0, 300, 35);
        paybut.tag = 3001;
        [paybut setTitle:@"搜索" forState:UIControlStateNormal];
        [paybut setBackgroundImage:[UIImage imageNamed:@"btn_bg_brown.png"] forState:UIControlStateNormal];
        paybut.userInteractionEnabled = YES;
        [paybut addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onclickBut:)]];
        [_topView addCustomSubview:paybut intervalTop:10];
        
        [_topView resize];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _topView.frame.origin.y +_topView.frame.size.height+10);
    
        _timeLabel.text = [_timeArray objectAtIndex:curTimeIndex];
        _sortLabel.text = [_sortArray objectAtIndex:curSortIndex];
        _priceLabel.text = [_priceArray objectAtIndex:curPriceIndex];
        _artworkField.text = keyword;
        
    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
    }
}

#pragma mark - 点击事件
#pragma mark 点击触发事件函数
-(void)onclickBut:(UITapGestureRecognizer *)sender {

    UIView *view = [sender view];
    NSInteger tag = view.tag;
    if(tag == 1001){//
        LCGlobalSelector *ctrl = [[LCGlobalSelector alloc] initWithNibName:nil bundle:nil];
        ctrl.title = @"选择搜索类别";
        ctrl.selectedIndex = curTimeIndex;
        ctrl.dataSource = self;
        ctrl.delegate = self;
        _curSelector = 1;
        [self.navigationController pushViewController:ctrl animated:YES];
        
    }else if(tag == 1002){//
        LCGlobalSelector *ctrl = [[LCGlobalSelector alloc] initWithNibName:nil bundle:nil];
        ctrl.title = @"选择搜索价格";
        ctrl.selectedIndex = curPriceIndex;
        ctrl.dataSource = self;
        ctrl.delegate = self;
        _curSelector = 3;
        [self.navigationController pushViewController:ctrl animated:YES];
        
    }else if(tag == 1003){
        LCGlobalSelector *ctrl = [[LCGlobalSelector alloc] initWithNibName:nil bundle:nil];
        ctrl.title = @"选择搜索属性";
        ctrl.selectedIndex = curSortIndex;
        ctrl.dataSource = self;
        ctrl.delegate = self;
        _curSelector = 2;
        [self.navigationController pushViewController:ctrl animated:YES];
        
    }else if(tag == 3001){
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setValue:[NSNumber numberWithInteger:curTimeIndex] forKey:@"curTimeIndex"];
        [param setValue:[NSNumber numberWithInteger:curSortIndex] forKey:@"curSortIndex"];
        [param setValue:[NSNumber numberWithInteger:curPriceIndex] forKey:@"curPriceIndex"];
        
        [param setValue:_artworkField.text forKey:@"keyword"];
        [param setValue:[NSNumber numberWithInteger:[[[[dic objectForKey:@"timeLabel"] objectAtIndex:curTimeIndex] objectForKey:@"id"] integerValue]] forKey:@"timeLabelId"];
        [param setValue:[NSNumber numberWithInteger:[[[[dic objectForKey:@"sortLabel"] objectAtIndex:curSortIndex] objectForKey:@"id"] integerValue]] forKey:@"sortLabelId"];
        [param setValue:[NSNumber numberWithInteger: curPriceIndex] forKey:@"curPriceIndex"];
        
        [self.navigationController popViewControllerAnimated:YES];
        [_delegate auctDidSearch:param];
    }
}


#pragma mark -
#pragma mark global selector
- (NSString *)titleForRow:(NSInteger)row
{
    if (_curSelector == 1) {
        return [_timeArray objectAtIndex:row];
    } else if (_curSelector == 2){
        return [_sortArray objectAtIndex:row];
    } else if (_curSelector == 3){
        return [_priceArray objectAtIndex:row];
    }
    return @"";
}

- (NSInteger)numberOfRows
{
    if (_curSelector == 1) {
        return _timeArray.count;
    } else if (_curSelector == 2){
        return _sortArray.count;
    } else if (_curSelector == 3){
        return _priceArray.count;
    }
    return 0;
    
}

- (void)selectorDidSelect:(NSInteger)row
{
    if (_curSelector == 1) {
        _timeLabel.text = [_timeArray objectAtIndex:row];
        curTimeIndex = row;
    } else if (_curSelector == 2){
        curSortIndex = row;
        _sortLabel.text = [_sortArray objectAtIndex:row];
    } else if (_curSelector == 3){
        curPriceIndex = row;
        _priceLabel.text = [_priceArray objectAtIndex:row];
    }
    
}



#pragma mark -
#pragma mark JSDropDownMenu
- (NSInteger)numberOfColumnsInMenu:(JSDropDownMenu *)menu {
    return 4;
}

-(BOOL)displayByCollectionViewInColumn:(NSInteger)column{
    
    if (column==2) {
        
        return YES;
    }
    
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
        
        return _currentData1Index;
    }else if (column==1) {
        
        return _currentData2Index;
    }else if (column==2) {
        
        return _currentData3Index;
    }else if (column==3) {
        
        return _currentData4Index;
    }
    return 0;
}

- (NSInteger)menu:(JSDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column leftOrRight:(NSInteger)leftOrRight leftRow:(NSInteger)leftRow{
    
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
        case 0: return _data1[0];
            break;
        case 1: return _data2[0];
            break;
        case 2: return _data3[0];
            break;
        case 3: return _data4[0];
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
        
        _currentData1Index = indexPath.row;
        
    } else if(indexPath.column == 1){
        
        _currentData2Index = indexPath.row;
        
    } else if(indexPath.column == 2){
        
        _currentData3Index = indexPath.row;
        
    } else{
        
        _currentData4Index = indexPath.row;
    }
}

@end
