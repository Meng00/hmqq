//
//  CalendarViewHeaderView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTCalendarViewHeaderView.h"

@implementation ITTCalendarViewHeaderView

@synthesize title = _title;
@synthesize delegate = _delegate;
@synthesize previousMonthButton;
@synthesize nextMonthButton;
@synthesize previousYearButton;
@synthesize nextYearButton;

- (void)dealloc
{
    _delegate = nil;
    _title = nil;
}

+ (ITTCalendarViewHeaderView*) viewFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil] objectAtIndex:0];
}
@end
