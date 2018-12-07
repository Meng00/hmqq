//
//  HMAuctionSearch.h
//  hmArt
//
//  Created by wangyong on 14-8-15.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"
#import "HMGlobal.h"
#import "HMNetImageView.h"
#import "LCActionSheet.h"
#import "LCUniverseSelector.h"
#import "ITTCalendarView.h"

@protocol auctionsSearchDelegate <NSObject>

@required
- (void)auctionsDidSearch:(NSDictionary *)conditions;

@end

@interface HMAuctionSearch : HMInputController<LCUniverseSelectorDataSource, LCUniverseSelectorDelegate, ITTCalendarViewDelegate>
{
    NSArray *_cityArray;
    unsigned int _requestCityId;
    
    NSInteger _tmpProvinceRow;
    NSInteger _selectedProvinceRow;
    NSInteger _selectedCityRow;
    NSInteger _currentDateTag;
    
    NSString *_selectedCity;
    NSDate *_fromDate;
    NSDate *_toDate;
}

@property (nonatomic, retain) id <auctionsSearchDelegate>delegate;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *formView;
@property (strong, nonatomic) IBOutlet UIView *fromDateView;
@property (strong, nonatomic) IBOutlet UIView *toDateView;
@property (strong, nonatomic) IBOutlet UIView *cityView;
@property (strong, nonatomic) IBOutlet UITextField *authorNameText;
@property (strong, nonatomic) IBOutlet UITextField *paintingNameText;
@property (strong, nonatomic) IBOutlet UITextField *areaNameText;
@property (strong, nonatomic) IBOutlet UILabel *fromDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *toDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *cityLabel;
@property (strong, nonatomic) IBOutlet UILabel *citySelectLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;
- (IBAction)toSearch:(id)sender;
- (IBAction)showDateView:(id)sender;
@end
