//
//  HMMemberFeedback.m
//  hmArt
//
//  Created by wangyong on 14-8-15.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMMemberFeedback.h"

@interface HMMemberFeedback ()

@end

@implementation HMMemberFeedback

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"意见反馈";
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
    [HMUtility navBar:self.navigationController.navigationBar backImage:@"home_bg.png" backTag:HM_SYS_NAVIBARBG_TAG];
    

    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
 
    CGRect rectForm = _formView.frame;
    rectForm.size.height = rect.size.height - 20;
    _formView.frame = rectForm;
    _formView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _formView.layer.borderWidth = 1.0;

    CGRect rectTable = _resultTable.frame;
    rectTable.size.height = rectForm.size.height - rectTable.origin.y - 5;
    _resultTable.frame = rectTable;

    [_scrollView setContentSize:CGSizeMake(rect.size.width, 180)];

    _pageSize = 10;
    _pageIndex = 1;
    _resultTable.tableHeaderView = nil;
    _resultTable.disableRefreshing = YES;
    _resultTable.disableLoadingMore = YES;
    _resultTable.backgroundColor = [UIColor clearColor];
    
    self.inputform = (UIScrollView *)_resultTable;
    [self addInput:_feedbackText sequence:1 name:@"feedback"];

    _feedbackText.placeholder = @"请输入您的建议，字数5～150字";
    _feedbackText.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _feedbackText.layer.borderWidth = 1.0;
    
     _resultArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self query];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestqueryId != 0) {
        [net cancelRequest:_requestqueryId];
    }
    HMGlobalParams *params = [HMGlobalParams sharedInstance];//是否登录是否统一处理
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 2];
    [queryParam setValue:params.mobile  forKey:@"username"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageIndex] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:_pageSize] forKey:@"pageSize"];
    _requestId = [net asynRequest:interfaceFeebackList with:queryParam needSSL:NO target:self action:@selector(queryList:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)queryList:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestqueryId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *ret = result.value;
        if (_pageIndex == 1) {
            [_resultArray removeAllObjects];
        }
        
        NSArray *data = [ret objectForKey:@"obj"];
        
        for (unsigned int i = 0; i < data.count; ++i) {
            [_resultArray addObject:[data objectAtIndex:i]];
        }
        _pageCount = [[ret objectForKey:@"pageCount"] integerValue];
        if (_pageIndex < _pageCount) {
            _resultTable.disableLoadingMore = NO;
            [_resultTable setLoadingMoreText:[NSString stringWithFormat:@"第%ld页/共%ld页 上拉加载下一页", (long)_pageIndex, (long)_pageCount] forState:EGOOPullNormal];
        }else{
            _resultTable.disableLoadingMore = YES;
        }
        
        [_resultTable reloadData];
        _resultTable.pullTableIsLoadingMore = NO;
        
    } else {
        if (result.message && result.message.length > 0) {
            [HMUtility showTip:result.message inView:self.view];
        }else{
            [HMUtility showTip:@"%@查询失败!" inView:self.view];
        }
    }
}



#pragma mark -
#pragma mark tableview datasource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _resultArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 列寬
    CGFloat contentWidth = _resultTable.frame.size.width - 20;
    // 用何種字體進行顯示
    UIFont *font = [UIFont systemFontOfSize:14];
    
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    // 該行要顯示的內容
    NSMutableString *ms = [[NSMutableString alloc] initWithCapacity:10];
    [ms appendFormat:@"   我：%@", [dic objectForKey:@"content"]];
    NSString *reply = [HMUtility getString:[dic objectForKey:@"reply"]];
    if (reply.length > 0) {
        [ms appendFormat:@"\n    回复：%@", reply];
    }
    
    // 計算出顯示完內容需要的最小尺寸
    CGSize size = [ms sizeWithFont:font constrainedToSize:CGSizeMake(contentWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    
    if (size.height < 44) {
        return 44;
    }
    // 這裏返回需要的高度
    return size.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"hmArtistCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
//        UILabel *lblQuestion = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, cell.frame.size.width-10, 21)];
//        lblQuestion.textAlignment = NSTextAlignmentLeft;
//        lblQuestion.numberOfLines = 0;
//        lblQuestion.lineBreakMode = NSLineBreakByWordWrapping;
//        lblQuestion.tag = 1001;
//        [cell.contentView addSubview:lblQuestion];
    }
    NSDictionary *dic = [_resultArray objectAtIndex:indexPath.row];
    NSMutableString *ms = [[NSMutableString alloc] initWithCapacity:10];
    [ms appendFormat:@"   我：%@", [dic objectForKey:@"content"]];
    NSString *reply = [HMUtility getString:[dic objectForKey:@"reply"]];
    if (reply.length > 0) {
        [ms appendFormat:@"\n    回复：%@", reply];
    }
    cell.textLabel.text = ms;
    return cell;
}

#pragma mark -
#pragma mark pullableTable methods
- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    _pageIndex++;
    if (_pageIndex > _pageCount) {
        return;
    }
  [self query];
}

- (IBAction)buttonClick:(id)sender {
    NSString *content = _feedbackText.text;
    
    if ([HMTextChecker checkIsEmpty:content]) {
        [HMUtility alert:@"意见不可为空" title:@"提示"];
        return;
    }
    if (![HMTextChecker checkLength:content min:5 max:150]) {
        [HMUtility alert:@"输入字数5～150" title:@"提示"];
        return;
    }
    HMGlobalParams *userInfo= [HMGlobalParams sharedInstance];//是否登录是否统一处理
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 2];
    [queryParam setValue:userInfo.mobile  forKey:@"username"];
    [queryParam setValue:content  forKey:@"content"];
    
    _requestId = [net asynRequest:interfaceFeebackSub with:queryParam needSSL:NO target:self action:@selector(Submit:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];

    
}
- (void)Submit:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    _requestId = 0;
    [HMUtility dismissModalView:_activity];
    if (result.result == HM_SYS_INTERFACE_SUCCESS) {
        _feedbackText.text = @"";
        [HMUtility alert:@"意见反馈成功" title:@"提示"];
        [self query];
        
    }else{
        [HMUtility alert:result.message title:@"提示"];
    }
}
@end
