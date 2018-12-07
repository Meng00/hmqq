//
//  HMMemberFeedback.h
//  hmArt
//
//  Created by wangyong on 14-8-15.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"
#import "HMUtility.h"
#import "PullTableView.h"
#import "HMGlobal.h"
#import "GCPlaceholderTextView.h"
#import "LCNetworkInterface.h"
@interface HMMemberFeedback : HMInputController<UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate>
{
    unsigned int _requestId;
    unsigned int _requestqueryId;
    NSMutableArray *_resultArray;
    
    //分页参数
    NSInteger _pageIndex;
    NSInteger _pageSize;
    NSInteger _pageCount;
    
}
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet GCPlaceholderTextView *feedbackText;
- (IBAction)buttonClick:(id)sender;
@property (strong, nonatomic) IBOutlet PullTableView *resultTable;
@end
