//
//  CalendarView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"
#import "ITTCalendarViewDataSource.h"
#import "ITTCalendarViewDelegate.h"
#import "ITTCalendarGridView.h"
#import "ITTCalendarViewHeaderView.h"
#import "ITTCalendarViewFooterView.h"
#import "ITTCalendarScrollView.h"

#define CALENDAR_VIEW_HEIGHT_WITHOUT_FOOTER_VIEW 264
#define CALENDAR_VIEW_HEIGHT                     340

@class CalDay;
@class ITTCalMonth;

@interface ITTCalendarView : UIView<ITTCalendarGridViewDelegate, 
ITTCalendarViewHeaderViewDelegate, ITTCalendarViewFooterViewDelegate, ITTCalendarScrollViewDelegate>
{
    BOOL                    _moved;
    BOOL                    _firstLayout;
    
    PeriodType              _selectedPeriod;    
    GridIndex               _previousSelectedIndex;
    
    CGSize                  _gridSize;
    
    NSDate                  *_date;
    NSDate                  *_minimumDate;
    NSDate                  *_maximumDate;
    
    ITTCalDay               *_minimumDay;
    ITTCalDay               *_maximumDay;
    ITTCalDay               *_selectedDay;
    
    ITTCalMonth                *_calMonth;
    
    ITTCalendarViewHeaderView  *_calendarHeaderView;
    ITTCalendarViewFooterView  *_calendarFooterView;
    
    UIView                  *_parentView;
    
    NSMutableArray          *_gridViewsArray;                   //two-dimensional array
    NSMutableArray          *_monthGridViewsArray;
    NSMutableDictionary     *_recyledGridSetDic;
    //NSMutableDictionary     *_selectedGridViewIndicesDic;
    //NSMutableDictionary     *_selectedDayDic;
    
    id<ITTCalendarViewDataSource>  _dataSource;
    id<ITTCalendarViewDelegate>    _delegate;
}
@property (nonatomic, strong) id<ITTCalendarViewDataSource> dataSource;
@property (nonatomic, strong) id<ITTCalendarViewDelegate>   delegate;

@property (nonatomic) PeriodType selectedPeriod;

@property (nonatomic) BOOL appear;

@property (nonatomic) CGSize gridSize;

@property (nonatomic) BOOL hideYear;
/*
 * default date is current date
 */
@property (nonatomic, strong) NSDate *date;              
/*
 * The minimum date that a date calendar view can show
 */
@property (nonatomic, strong) NSDate *minimumDate;          
/*
 * The maximum date that a date calendar view can show
 */
@property (nonatomic, strong) NSDate *maximumDate;
/*
 * The selected calyday on calendar view
 */
@property (strong, nonatomic, readonly) ITTCalDay *selectedDay;
/*
 * The selected date on calendar view
 */
@property (strong, nonatomic, readonly) NSDate *selectedDate;

- (void)nextMonth;
- (void)previousMonth;
- (void)showInView:(UIView*)view;
- (void)hide;

- (ITTCalendarGridView*)dequeueCalendarGridViewWithIdentifier:(NSString*)identifier;
@property (strong, nonatomic) IBOutlet UIButton *nextMonthButton;
@property (strong, nonatomic) IBOutlet UIButton *previousMonthButton;
@property (strong, nonatomic) IBOutlet UILabel *monthLabel;
@property (strong, nonatomic) IBOutlet UIButton *prevYearButton;
@property (strong, nonatomic) IBOutlet UIButton *nextYearButton;

- (IBAction)nextYearButtonDown:(id)sender;
+ (id)viewFromNib;
- (IBAction)prevYearButtonDown:(id)sender;

- (IBAction)prevMonthBtnDown:(id)sender;
- (IBAction)nextMonthBtnDown:(id)sender;
@end
