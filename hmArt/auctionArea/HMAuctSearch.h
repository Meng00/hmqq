//
//  HMAuctSearch.h
//  hmArt
//
//  Created by 刘学 on 15/7/31.
//  Copyright (c) 2015年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMInputController.h"
#import "HMGlobal.h"
#import "LCActionSheet.h"
#import "LCUniverseSelector.h"
#import "ITTCalendarView.h"
#import "LCView.h"
#import "LCGlobalSelector.h"
#import "HMGalleryCategory.h"
#import "JSDropDownMenu.h"

@protocol auctSearchDelegate <NSObject>

@required
- (void)auctDidSearch:(NSDictionary *)conditions;

@end

@interface HMAuctSearch : HMInputController<globalSelectorDataSource, globalSelectorDelegate,JSDropDownMenuDataSource,JSDropDownMenuDelegate>
{
    unsigned int _requestId;
    NSDictionary *dic;
    LCView *_topView;
    
    NSUInteger _curSelector;
    
    NSMutableArray *_timeArray;
    UILabel *_timeLabel;
    
    NSMutableArray *_sortArray;
    UILabel *_sortLabel;
    
    NSMutableArray *_priceArray;
    UILabel *_priceLabel;
    
    UITextField *_artworkField;
    UITextField *_artnameField;
    
    JSDropDownMenu *menu;
    NSMutableArray *_data1;
    NSMutableArray *_data2;
    NSMutableArray *_data3;
    NSMutableArray *_data4;
    
    NSInteger _currentData1Index;
    NSInteger _currentData2Index;
    NSInteger _currentData3Index;
    NSInteger _currentData4Index;
    
}
@property (nonatomic, retain) id <auctSearchDelegate>delegate;
@property (nonatomic) NSInteger curTimeIndex;
@property (nonatomic) NSInteger curSortIndex;
@property (nonatomic) NSInteger curPriceIndex;
@property (copy, nonatomic) NSString *keyword;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end
