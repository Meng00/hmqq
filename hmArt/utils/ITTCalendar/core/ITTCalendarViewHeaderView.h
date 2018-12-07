//
//  CalendarViewHeaderView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ITTCalendarViewHeaderViewDelegate;

@interface ITTCalendarViewHeaderView : UIView
{
    NSString        *_title;
    id<ITTCalendarViewHeaderViewDelegate> _delegate;
}

@property (nonatomic, strong) id<ITTCalendarViewHeaderViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIButton *previousMonthButton;
@property (nonatomic, strong) IBOutlet UIButton *nextMonthButton;

@property (nonatomic, strong) IBOutlet UIButton *previousYearButton;
@property (nonatomic, strong) IBOutlet UIButton *nextYearButton;

@property (nonatomic, strong) NSString *title;

+ (ITTCalendarViewHeaderView*) viewFromNib;

@end

@protocol ITTCalendarViewHeaderViewDelegate <NSObject>
@optional
- (void)calendarViewHeaderViewNextYear:(ITTCalendarViewHeaderView*)calendarHeaderView;
- (void)calendarViewHeaderViewPreviousYear:(ITTCalendarViewHeaderView*)calendarHeaderView;
- (void)calendarViewHeaderViewNextMonth:(ITTCalendarViewHeaderView*)calendarHeaderView;
- (void)calendarViewHeaderViewPreviousMonth:(ITTCalendarViewHeaderView*)calendarHeaderView;
- (void)calendarViewHeaderViewDidCancel:(ITTCalendarViewHeaderView*)calendarHeaderView;
- (void)calendarViewHeaderViewDidSelection:(ITTCalendarViewHeaderView*)calendarHeaderView;
@end
