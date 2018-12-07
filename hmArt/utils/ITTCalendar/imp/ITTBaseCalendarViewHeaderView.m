//
//  BaseCalendarViewHeaderView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTBaseCalendarViewHeaderView.h"

@interface ITTBaseCalendarViewHeaderView()

@property (retain, nonatomic) IBOutlet UILabel *monthLabel;

@end

@implementation ITTBaseCalendarViewHeaderView
@synthesize monthLabel;

- (IBAction)onCancelChoseDateButtonTouched:(id)sender 
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewHeaderViewDidCancel:)]) {
        [_delegate calendarViewHeaderViewDidCancel:self];
    }
}

- (IBAction)onChoseDateButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewHeaderViewDidSelection:)]) {
        [_delegate calendarViewHeaderViewDidSelection:self];
    }
}

- (IBAction)onPreviousMonthButtonTouched:(id)sender 
{    
    if (_delegate && [_delegate respondsToSelector:
                      @selector(calendarViewHeaderViewPreviousMonth:)]) {
        [_delegate calendarViewHeaderViewPreviousMonth:self];
    }    
}

- (IBAction)onNextMonthButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewHeaderViewNextMonth:)]) {
        [_delegate calendarViewHeaderViewNextMonth:self];
    }
}

- (IBAction)onPreviousYearButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:
                      @selector(calendarViewHeaderViewPreviousYear:)]) {
        [_delegate calendarViewHeaderViewPreviousYear:self];
    }
}

- (IBAction)onNextYearButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewHeaderViewNextYear:)]) {
        [_delegate calendarViewHeaderViewNextYear:self];
    }
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.monthLabel.text = title;
}


@end
