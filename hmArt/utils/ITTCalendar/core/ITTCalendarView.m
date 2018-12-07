//
//  ITTCalendarView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ITTCalendarView.h"
#import "ITTCalMonth.h"
#import "ITTCalDay.h"
#import "ITTCalendarViewHeaderView.h"

#define MARGIN_LEFT                              5
#define MARGIN_TOP                               9
#define PADDING_VERTICAL                         5
#define PADDING_HORIZONTAL                       3

@interface ITTCalendarView()
{
    NSTimeInterval          _swipeTimeInterval;
    NSTimeInterval          _begintimeInterval;
}

@property (retain, nonatomic) ITTCalMonth *calMonth;
@property (retain, nonatomic) IBOutlet UIView *weekHintView;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet ITTCalendarScrollView *gridScrollView;

- (void)initParameters;
- (void)addGridViewAtRow:(ITTCalendarGridView*)gridView row:(NSUInteger) row column:(NSUInteger)column;
- (void)layoutGridCells;
- (void)recyleAllGridViews;
- (void)updateSelectedGridViewState;

- (BOOL)isGridViewSelectedEnableAtRow:(NSUInteger)row column:(NSUInteger)column;

- (ITTCalendarGridView*)getGridViewAtRow:(NSUInteger) row column:(NSUInteger)column;

- (NSUInteger)getRows;
- (NSUInteger)getMonthDayAtRow:(NSUInteger)row column:(NSUInteger)column;

- (NSString*)findMonthDescription;
- (NSArray*)findWeekTitles;

- (ITTCalendarViewHeaderView*)findHeaderView;
- (ITTCalendarViewFooterView*)findFooterview;

- (ITTCalendarGridView*)gridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(ITTCalDay*)calDay;
- (ITTCalendarGridView*)disableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(ITTCalDay*)calDay;
- (CGRect)getFrameForRow:(NSUInteger)row column:(NSUInteger)column;

@end

@implementation ITTCalendarView

@synthesize appear;
@synthesize selectedDate;
@synthesize selectedPeriod = _selectedPeriod;
@synthesize calMonth = _calMonth;
@synthesize weekHintView = _weekHintView;
@synthesize selectedDay = _selectedDay;
@synthesize date = _date;
@synthesize minimumDate = _minimumDate;
@synthesize maximumDate = _maximumDate;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;
@synthesize gridScrollView = _gridScrollView;
@synthesize gridSize;


#pragma mark - private methods
- (void)initParameters
{
    _gridSize = CGSizeMake(39, 31);    
    _date = [NSDate date];    
    _calMonth = [[ITTCalMonth alloc] initWithDate:_date];            
    _gridViewsArray = [[NSMutableArray alloc] init];  
    _monthGridViewsArray = [[NSMutableArray alloc] init];  
    _recyledGridSetDic = [[NSMutableDictionary alloc] init];
    _hideYear = YES;
    
    NSUInteger n = 6;
    for (NSUInteger index = 0; index < n; index++) {
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        [_gridViewsArray addObject:rows];
    }    
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    ITTCalMonth *cm = [[ITTCalMonth alloc] initWithDate:_date];
    self.calMonth = cm;
    _selectedDay = [[ITTCalDay alloc] initWithDate:date];
}

- (void)setMaximumDate:(NSDate *)maximumDate
{
    _maximumDate = maximumDate ;
    _maximumDay = [[ITTCalDay alloc] initWithDate:_maximumDate];
    
    _firstLayout = TRUE;    
    [self recyleAllGridViews];  
    [self setNeedsLayout];
}

- (void)setMinimumDate:(NSDate *)minimumDate
{
    _minimumDate = minimumDate;
    _minimumDay = [[ITTCalDay alloc] initWithDate:_minimumDate];
    
    _firstLayout = TRUE;
    [self recyleAllGridViews];
    [self setNeedsLayout];
}

- (void)setCalMonth:(ITTCalMonth *)calMonth
{
    [self recyleAllGridViews];      
    _calMonth = calMonth;
    _firstLayout = TRUE;    
    [self setNeedsLayout];
}

- (NSUInteger)getRows
{
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    NSUInteger row = (offsetRow + _calMonth.days - 1)/NUMBER_OF_DAYS_IN_WEEK;
    return row + 1;    
}

- (NSUInteger) getMonthDayAtRow:(NSUInteger)row column:(NSUInteger)column
{
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    NSUInteger day = (row * NUMBER_OF_DAYS_IN_WEEK + 1 - offsetRow) + column;
    return day;
}

- (BOOL)isValidGridViewIndex:(GridIndex)index
{
    BOOL valid = TRUE;
    if (index.column < 0||
        index.row < 0||
        index.column >= NUMBER_OF_DAYS_IN_WEEK||
        index.row >= [self getRows]) {
        valid = FALSE;
    }
    return valid;
}

- (GridIndex)getGridViewIndex:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet*)touches
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:calendarScrollView];
    GridIndex index;
    NSInteger row = (location.y - MARGIN_TOP + PADDING_VERTICAL)/(PADDING_VERTICAL + _gridSize.height);
    NSInteger column = (location.x - MARGIN_LEFT + PADDING_HORIZONTAL)/(PADDING_HORIZONTAL + _gridSize.width);
    //ITTDINFO(@"row %d column %d", row, column);
    index.row = row;
    index.column = column;
    return index;
}

- (NSString*)findMonthDescription
{
    /*NSString *title = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:titleForMonth:)]) {
        title = [_dataSource calendarView:self titleForMonth:_calMonth];
    }
    if (!title||![title length]) {        
        title = [NSString stringWithFormat:@"%d年%d月", [_calMonth getYear], [_calMonth getMonth]];        
    }*/
    NSString *title = [NSString stringWithFormat:@"%d年%d月", [_calMonth getYear], [_calMonth getMonth]];
    return title;
}

- (NSArray*)findWeekTitles
{
    NSArray *titles = nil; 
    if (_dataSource && [_dataSource respondsToSelector:@selector(weekTitlesForCalendarView:)]) {
        titles = [_dataSource weekTitlesForCalendarView:self];
    }
    if (!titles||![titles count]) {
        titles = [NSArray arrayWithObjects:@"日", @"一", @"二", @"三", @"四", @"五", @"六", nil];
    }
    return titles;
}

- (void)recyleAllGridViews
{
    /*
     * recyled all grid views
     */    
    NSMutableSet *recyledGridSet;
    for (NSMutableArray *rowGridViewsArray in _gridViewsArray) {
        for (ITTCalendarGridView *gridView in rowGridViewsArray) {
            recyledGridSet = [_recyledGridSetDic objectForKey:gridView.identifier];
            if (!recyledGridSet) {    
                recyledGridSet = [[NSMutableSet alloc] init];
                [_recyledGridSetDic setObject:recyledGridSet forKey:gridView.identifier];
            }
            gridView.selected = FALSE;
            [gridView removeFromSuperview];
            [recyledGridSet addObject:gridView];
        }     
        [rowGridViewsArray removeAllObjects];
    }
    [_monthGridViewsArray removeAllObjects];
}

- (ITTCalendarGridView*)getGridViewAtRow:(NSUInteger) row column:(NSUInteger)column
{
    ITTCalendarGridView *gridView = nil;
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    gridView = [rowGridViewsArray objectAtIndex:column];
    return gridView;
}

- (BOOL)isGridViewSelectedEnableAtRow:(NSUInteger)row column:(NSUInteger)column
{
    BOOL selectedEnable = TRUE;    
    NSUInteger day = [self getMonthDayAtRow:row column:column];
    if (day < 1 || day > _calMonth.days) {
        selectedEnable = FALSE;
    }
    else {
        ITTCalDay *calDay = [_calMonth calDayAtDay:day];
        if([self isEarlyerMinimumDay:calDay] || [self isAfterMaximumDay:calDay])
        {
            selectedEnable = FALSE;
        }        
    }
    return selectedEnable;
}

- (NSString*) getSelectedDayKey:(NSInteger)row column:(NSInteger)column
{
    NSUInteger day = [self getMonthDayAtRow:row column:column];
    ITTCalDay *cday = [_calMonth calDayAtDay:day];
    return [NSString stringWithFormat:@"%04d%02d%02d", [cday getYear], [cday getMonth], [cday getDay]];
}

- (NSString*) getSelectedDayKey:(ITTCalDay *)calDay
{
    return [NSString stringWithFormat:@"%04d%02d%02d", [calDay getYear], [calDay getMonth], [calDay getDay]];
}

/*
 * update grid state
 */
- (void)updateSelectedGridViewState
{
    ITTCalendarGridView *gridView = nil;
    NSInteger rows = [self getRows];
    for (NSInteger row = 0; row < rows; row++) {
        for (NSInteger column = 0; column < NUMBER_OF_DAYS_IN_WEEK; column++) {
            gridView = [self getGridViewAtRow:row column:column];
            NSInteger day = [self getMonthDayAtRow:row column:column];
            if (day >= 1 && day <= _calMonth.days) {
                ITTCalDay *choosenDay = [_calMonth calDayAtDay:day];
                if ([self isEqualSelectDay:choosenDay]) {
                    gridView.selected = TRUE;
                } else
                    gridView.selected = FALSE;
            }
        }
    }
}

- (BOOL)isEarlyerMinimumDay:(ITTCalDay*)calDay
{
    BOOL early = FALSE;
    if (_minimumDate) {        
        if (NSOrderedAscending == [calDay compare:_minimumDay]) {
            early = TRUE;
        }
    }
    return early;
}

- (BOOL)isAfterMaximumDay:(ITTCalDay*)calDay
{
    BOOL after = FALSE;
    if (_maximumDate) {        
        if (NSOrderedDescending == [calDay compare:_maximumDay]) {
            after = TRUE;
        }
    }
    return after;
    
}

- (BOOL)isEqualSelectDay:(ITTCalDay*)calDay
{
    BOOL equal = FALSE;
    if (_selectedDay) {
        if (NSOrderedSame == [calDay compare:_selectedDay]) {
            equal = TRUE;
        }
    }
    return equal;
}
- (void)addGridViewAtRow:(ITTCalendarGridView*)gridView row:(NSUInteger) row
                   column:(NSUInteger)column
{
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    NSInteger count = [rowGridViewsArray count];
    if (column > count||column < count) {
        if (column > count) {
            NSInteger offsetCount = column - count + 1;
            for (NSInteger offset = 0; offset < offsetCount; offset++) {
                [rowGridViewsArray addObject:[NSNull null]];
            }            
        }
        [rowGridViewsArray replaceObjectAtIndex:column withObject:gridView];        
    }    
    else if (column == count) {        
        [rowGridViewsArray insertObject:gridView atIndex:column];
    }
}
/*
 *绘制日期gridview
 */
- (void)layoutGridCells
{
    NSInteger count;
    NSInteger row = 0;
    NSInteger column = 0;
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;    
    CGRect frame = CGRectZero;
    ITTCalDay *calDay;
    ITTCalendarGridView *gridView = nil;
    /*
     * layout grid view before selected month on calendar view
    */ 
    calDay = [_calMonth firstDay];
    if ([calDay getWeekDay] > 1) {
        count = [calDay getWeekDay];
        ITTCalMonth *previousMonth = [_calMonth previousMonth];
        row = 0;
        for (NSInteger day = previousMonth.days; count > 0 && day >= 1; day--) {
            calDay = [previousMonth calDayAtDay:day];
            column = [calDay getWeekDay] - 1;                        
            gridView = [self disableGridViewAtRow:row column:column calDay:calDay];
            gridView.delegate = self;
            gridView.calDay = calDay;
            gridView.row = row;
            gridView.column = column;            
            frame = [self getFrameForRow:row column:column];        
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];   
            [self addGridViewAtRow:gridView row:row column:column];
            count--;
        }
    }
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    for (NSInteger day = 1; day <= _calMonth.days; day++) {
        calDay = [_calMonth calDayAtDay:day];
        row = (offsetRow + day - 1)/NUMBER_OF_DAYS_IN_WEEK;
        column = [calDay getWeekDay] - 1;

        gridView = [self gridViewAtRow:row column:column calDay:calDay];
        gridView.delegate = self;
        gridView.calDay = calDay;
        gridView.row = row;
        gridView.column = column;
        gridView.selectedEanable = ([self isEarlyerMinimumDay:calDay] || [self isAfterMaximumDay:calDay]) ? FALSE:TRUE;
        if ([self isEqualSelectDay:calDay]) {
            gridView.selected = TRUE;
        }
        frame = [self getFrameForRow:row column:column];
        gridView.frame = frame;
        [gridView setNeedsLayout];
        [self.gridScrollView addSubview:gridView];   
        [_monthGridViewsArray addObject:gridView];
        [self addGridViewAtRow:gridView row:row column:column];
        if (CGRectGetMaxX(frame) > maxWidth) {
            maxWidth = CGRectGetMaxX(frame);
        }
        if (CGRectGetMaxY(frame) > maxHeight) {
            maxHeight = CGRectGetMaxY(frame);
        }        
    }
    self.gridScrollView.contentSize = CGSizeMake(maxWidth, maxHeight + 5);
    /*
     * layout grid view after selected month on calendar view
     */
    calDay = [_calMonth lastDay];
    if ([calDay getWeekDay] < NUMBER_OF_DAYS_IN_WEEK) {
        NSUInteger days = NUMBER_OF_DAYS_IN_WEEK - [calDay getWeekDay];
        ITTCalMonth *previousMonth = [_calMonth nextMonth];
        for (NSInteger day = 1; day <= days; day++) {
            calDay = [previousMonth calDayAtDay:day];
            column = [calDay getWeekDay] - 1;                        
            gridView = [self disableGridViewAtRow:row column:column calDay:calDay];
            gridView.delegate = self;
            gridView.calDay = calDay;
            gridView.row = row;
            gridView.column = column;
            frame = [self getFrameForRow:row column:column];        
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];   
            [self addGridViewAtRow:gridView row:row column:column];
        }
    }
}

- (CGRect)getFrameForRow:(NSUInteger)row column:(NSUInteger)column
{
    CGFloat x = MARGIN_LEFT + (column - 1)*PADDING_HORIZONTAL + column*_gridSize.width;
    CGFloat y = MARGIN_TOP + (row - 1)*PADDING_VERTICAL + row*_gridSize.height;
    CGRect frame = CGRectMake(x, y, _gridSize.width, _gridSize.height);
    return frame;
}

- (ITTCalendarViewHeaderView*)findHeaderView
{
    ITTCalendarViewHeaderView *headerView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(headerViewForCalendarView:)]) {
        headerView = [_dataSource headerViewForCalendarView:self];
    }
    return headerView;
}

- (ITTCalendarViewFooterView*)findFooterview
{
    ITTCalendarViewFooterView *footerView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(footerViewForCalendarView:)]) {
        footerView = [_dataSource footerViewForCalendarView:self];
    }
    return footerView;    
}

- (ITTCalendarGridView*)gridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(ITTCalDay*)calDay
{
    ITTCalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarGridViewForRow:column:calDay:)]) {
        gridView = [_dataSource calendarView:self calendarGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;
}

- (ITTCalendarGridView*)disableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(ITTCalDay*)calDay
{
    ITTCalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarDisableGridViewForRow:column:calDay:)]) {
        gridView = [_dataSource calendarView:self calendarDisableGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;    
}


- (BOOL) appear
{
    return (self.alpha > 0);
}

- (void)animationChangeMonth:(BOOL)next
{
    UIViewAnimationTransition options;
    if (next){
        options = UIViewAnimationTransitionCurlUp;          
    }
    else {      
        options = UIViewAnimationTransitionCurlDown;        
    }
    _nextMonthButton.hidden = YES;
    _previousMonthButton.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationTransition:options forView:self.gridScrollView cache:TRUE]; 
        if (next) {
            self.calMonth = [_calMonth nextMonth];     
        }
        else {
            self.calMonth = [_calMonth previousMonth];                 
        }
    } completion:^(BOOL finished)
     {
         if (finished)
         {
             [self resetMonthButton];
         }
     }];
}
- (void)resetMonthButton
{
    ITTCalMonth *minMonth = [[ITTCalMonth alloc] initWithDate:_minimumDate];
    ITTCalMonth *maxMonth = [[ITTCalMonth alloc] initWithDate:_maximumDate];
    NSComparisonResult cr = [self.calMonth compare:minMonth];
    if (cr == NSOrderedSame || cr == NSOrderedAscending) {
        _previousMonthButton.hidden   = YES ;
        _prevYearButton.hidden = YES;
    } else {
        _previousMonthButton.hidden = NO;
        _prevYearButton.hidden = _hideYear;
    }
    
    NSComparisonResult cr1 = [self.calMonth compare:maxMonth];
    if (cr1 == NSOrderedSame || cr1 == NSOrderedDescending) {
        _nextMonthButton.hidden =YES;
        _nextYearButton.hidden = YES;
    } else {
        _nextMonthButton.hidden = NO;
        _nextYearButton.hidden = _hideYear;
    }
    
}
- (void)animationChangeYear:(BOOL)next
{
    UIViewAnimationTransition options;
    if (next){
        options = UIViewAnimationTransitionCurlUp;
    }
    else {
        options = UIViewAnimationTransitionCurlDown;
    }
    _nextYearButton.hidden = FALSE;
    _prevYearButton.hidden = FALSE;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationTransition:options forView:self.gridScrollView cache:TRUE];
        if (next) {
            self.calMonth = [_calMonth nextYear];
        }
        else {
            self.calMonth = [_calMonth previousYear];
        }
    } completion:^(BOOL finished)
     {
         if (finished)
         {
             [self resetMonthButton];
         }
     }];
}

- (void)layoutSubviews
{
    if (_firstLayout) {
        [self layoutGridCells];    
        /*
         * layout header view
         
        if (!_calendarHeaderView)
        {
            ITTCalendarViewHeaderView *calendarHeaderView = [self findHeaderView];
            if (!calendarHeaderView) {
                if (_calendarHeaderView) {
                    [_calendarHeaderView removeFromSuperview];
                }
                CGRect frame = calendarHeaderView.bounds;
                frame.origin.x = (CGRectGetWidth(self.headerView.bounds) - CGRectGetWidth(frame))/2;
                frame.origin.y = (CGRectGetHeight(self.headerView.bounds) - CGRectGetHeight(frame))/2;        
                calendarHeaderView.delegate = self;
                calendarHeaderView.frame = frame;
                [calendarHeaderView.layer setShadowColor:[UIColor clearColor].CGColor];
                [calendarHeaderView.layer setShadowOpacity:0];
                [calendarHeaderView.layer setBorderWidth:0];
            
                _calendarHeaderView = calendarHeaderView;
                [self.headerView addSubview:_calendarHeaderView];    
            }               
        }   
         */
        /*
         * layout footer view
         */
        if (!_calendarFooterView) {
            ITTCalendarViewFooterView *calendarFooterView = [self findFooterview];
            if (calendarFooterView) {
                if (_calendarFooterView) {
                    [_calendarFooterView removeFromSuperview];
                }
                CGRect frame = calendarFooterView.bounds;
                frame.origin.x = (CGRectGetWidth(self.footerView.bounds) - CGRectGetWidth(frame))/2;
                frame.origin.y = (CGRectGetHeight(self.footerView.bounds) - CGRectGetHeight(frame))/2;        
                calendarFooterView.delegate = self;
                calendarFooterView.frame = frame;
                _calendarFooterView = calendarFooterView;
                [self.footerView addSubview:_calendarFooterView];    
            }        
            else {
                CGRect frame = self.frame;

                if (_gridScrollView.contentSize.height > 200) {
                    frame.size.height = CALENDAR_VIEW_HEIGHT_WITHOUT_FOOTER_VIEW + 36.0;
                }else{
                    frame.size.height = CALENDAR_VIEW_HEIGHT_WITHOUT_FOOTER_VIEW;
                }
                CGRect scrollFrame = _gridScrollView.frame;
                scrollFrame.size.height = _gridScrollView.contentSize.height + 1.0;
                _gridScrollView.frame = scrollFrame;
                self.frame = frame;
            }
        }               
        /*
         * layout week hint labels
         */
        for (UIView *subview in self.weekHintView.subviews) {
            /*
             * subview is not background imageview
             */
            if (![subview isKindOfClass:[UIImageView class]]) {
                [subview removeFromSuperview];
            }
        }
        CGFloat totalWidth = self.gridScrollView.contentSize.width;
        CGFloat width = totalWidth/NUMBER_OF_DAYS_IN_WEEK;
        CGFloat marginX = 0;
        NSArray *titles = [self findWeekTitles];
        for (NSInteger i = 0; i < NUMBER_OF_DAYS_IN_WEEK; i++) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(marginX, 0, width, CGRectGetHeight(self.weekHintView.bounds))];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:14];
            label.text = [titles objectAtIndex:i];
            label.backgroundColor = [UIColor clearColor];
            label.adjustsFontSizeToFitWidth = TRUE;
            [self.weekHintView addSubview:label];
            marginX += width;            
        }
        _firstLayout = FALSE;
    }
    //_calendarHeaderView.title = [self findMonthDescription];
    _monthLabel.text = [self findMonthDescription];
    [self resetMonthButton];
}

- (void)swipe:(UISwipeGestureRecognizer*)gesture
{
    if (fabs(_swipeTimeInterval - NSTimeIntervalSince1970) > 1.0) {
        if (_swipeTimeInterval < 2.0) {
            if (UISwipeGestureRecognizerDirectionLeft == gesture.direction) {
                [self nextMonth];
            }
            else {
                [self previousMonth];
            }            
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.alpha = 0.0;
    self.multipleTouchEnabled = TRUE;
    self.gridScrollView.calendarDelegate = self;    
    _firstLayout = TRUE;
    _selectedPeriod = PeriodTypeAllDay;
    _minimumDate = [NSDate date];
    _minimumDay = [[ITTCalDay alloc] initWithDate:_minimumDate];    
    _previousSelectedIndex.row = NSNotFound;
    _previousSelectedIndex.column = NSNotFound;
    [self initParameters];
    
    /*[self.headerView.layer setShadowColor:[UIColor clearColor].CGColor];
    [self.headerView.layer setShadowOpacity:0];
    [self.headerView.layer setBorderWidth:0];*/

    /*
     * add left and right swipe gesture
     */
    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:leftSwipeGesture];
    
    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightSwipeGesture];
}

- (void)dealloc 
{
    _minimumDate = nil;
    _delegate = nil;
    _dataSource = nil;
    _calendarHeaderView = nil;
    _selectedDay = nil;    
    _recyledGridSetDic = nil;    
    _gridViewsArray = nil;
    _monthGridViewsArray = nil;        
    _headerView = nil;
    _footerView = nil;    
    _gridScrollView = nil;
    _minimumDay = nil;    
    _maximumDate = nil;
    _maximumDay = nil;
}

#pragma mark - public methods
- (IBAction)nextYearButtonDown:(id)sender {
    [self nextYear];
}

+ (id)viewFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"ITTCalendarView" owner:self options:nil] objectAtIndex:0];
}

- (IBAction)prevYearButtonDown:(id)sender {
    [self previousYear];
}

- (IBAction)prevMonthBtnDown:(id)sender {
    [self previousMonth];
}

- (IBAction)nextMonthBtnDown:(id)sender {
    [self nextMonth];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (ITTCalendarGridView*)dequeueCalendarGridViewWithIdentifier:(NSString*)identifier
{
    ITTCalendarGridView *gridView = nil;
    NSMutableSet *recyledGridSet = [_recyledGridSetDic objectForKey:identifier];
    if (recyledGridSet) {
        gridView = [recyledGridSet anyObject];
        if (gridView) {
            [recyledGridSet removeObject:gridView];
        }
    }
    return gridView;
}

- (NSDate*)selectedDate
{
    return _selectedDay.date;
}

- (void)hide
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 0.0;
        _parentView.alpha = 0.0;
    }];
}

- (void)showInView:(UIView*)view
{
    if (!_parentView) {
        _parentView = [[UIView alloc] initWithFrame:view.bounds];
       
        _parentView.alpha = 0.0;
        _parentView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapMe = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        
        tapMe.numberOfTapsRequired = 1;
        tapMe.cancelsTouchesInView = NO;
        [_parentView addGestureRecognizer:tapMe];
        [view addSubview:_parentView];
    }
    else {
        if (_parentView.superview == view) {
        }
        else {
            _parentView.alpha = 0.0;
            [_parentView removeFromSuperview];
            _parentView.frame = view.bounds;
            [view addSubview:_parentView];
        }
    }
    if (!self.superview) {
        [view addSubview:self];
    }
    else {
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
        _parentView.alpha = 0.6;
    }];
}
- (void)tapped:(UITapGestureRecognizer*)param
{
    [self hide];
}

- (void)nextMonth
{
    if (!_nextMonthButton.hidden)
        [self animationChangeMonth:TRUE];
}

- (void)previousMonth
{
    if (!_previousMonthButton.hidden)
        [self animationChangeMonth:FALSE];
}
- (void)nextYear
{
    [self animationChangeYear:TRUE];
}

- (void)previousYear
{
    [self animationChangeYear:FALSE];
}

#pragma mark - ITTCalendarViewHeaderViewDelegate
- (void)calendarViewHeaderViewNextYear:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    [self nextYear];
}

- (void)calendarViewHeaderViewPreviousYear:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    [self previousYear];
}

- (void)calendarViewHeaderViewNextMonth:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    [self nextMonth];
}

- (void)calendarViewHeaderViewPreviousMonth:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    [self previousMonth];
}

- (void)calendarViewHeaderViewDidCancel:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    [self hide];
}

- (void)calendarViewHeaderViewDidSelection:(ITTCalendarViewHeaderView*)calendarHeaderView
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectDay:calDay:)]) {
        [_delegate calendarViewDidSelectDay:self calDay:self.selectedDay];
    } 
    [self hide];    
}

#pragma mark - CalendarViewFooterViewDelegate
- (void)calendarViewFooterViewDidSelectPeriod:(ITTCalendarViewFooterView*)footerView periodType:(PeriodType)type
{
    self.selectedPeriod = type;
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectPeriodType:periodType:)]) {
        [_delegate calendarViewDidSelectPeriodType:self periodType:type];
    }
}

#pragma mark - CalendarGridViewDelegate
- (void)ittCalendarGridViewDidSelectGrid:(ITTCalendarGridView*)gridView
{
}

- (void)show
{
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha = 1.0;
    }];
}

#pragma mark - ITTCalendarScrollViewDelegate
- (void)calendarSrollViewTouchesBegan:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moved = FALSE;
    _swipeTimeInterval = NSTimeIntervalSince1970;
    _begintimeInterval = [[touches anyObject] timestamp];
}

- (void)calendarSrollViewTouchesMoved:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    _moved = TRUE;
}

- (void)calendarSrollViewTouchesCancelled:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    _swipeTimeInterval = fabs([[touches anyObject] timestamp] - _begintimeInterval);
}

- (void)calendarSrollViewTouchesEnded:(ITTCalendarScrollView*)calendarScrollView touches:(NSSet *)touches withEvent:(UIEvent *)event
{
    GridIndex index = [self getGridViewIndex:calendarScrollView touches:touches];
    if ([self isValidGridViewIndex:index] && !_moved) {
        if ([self isGridViewSelectedEnableAtRow:index.row column:index.column]) {
            NSInteger day = [self getMonthDayAtRow:index.row column:index.column];
            if (day >= 1 && day <= _calMonth.days) {
                _selectedDay = [_calMonth calDayAtDay:day];
                if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectDay:calDay:)]) {
                    [_delegate calendarViewDidSelectDay:self calDay:self.selectedDay];
                }
                [self hide];
            }
        }
        //[self updateSelectedGridViewState];
    }
    _swipeTimeInterval = fabs([[touches anyObject] timestamp] - _begintimeInterval);

    

}
@end
