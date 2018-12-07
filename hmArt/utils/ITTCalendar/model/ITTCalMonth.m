//
//  ITTCalMonth.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTCalMonth.h"
#import "CalendarDateUtil.h"
#import "ITTCalDay.h"

#define FIRST_MONTH_OF_YEAR  1
#define LAST_MONTH_OF_YEAR  12

@interface ITTCalMonth()
- (void)caculateMonth;
@end

@implementation ITTCalMonth

@synthesize days;

- (void)caculateMonth
{    
    _numberOfDays = [CalendarDateUtil numberOfDaysInMonth:[_today getMonth] year:[_today getYear]];
    _year = [_today getYear];
    _month = [_today getMonth];    
    daysOfMonth = [[NSMutableArray alloc] init];
    for (NSInteger day = 1; day <= _numberOfDays; day++)
    {
        ITTCalDay *calDay = [[ITTCalDay alloc] initWithYear:_year month:_month day:day];
        [daysOfMonth addObject:calDay];
    }
}

- (ITTCalMonth*)nextMonth
{
    NSUInteger year = _year;
    NSUInteger month = _month + 1;
    NSUInteger day = 1;
    if (month > LAST_MONTH_OF_YEAR) 
    {
        year++;
        month = 1;
    }
    ITTCalMonth *calMonth = [[ITTCalMonth alloc] initWithMonth:month year:year day:day];
    return calMonth;
}

- (ITTCalMonth*)previousMonth
{
    NSUInteger year = _year;
    NSUInteger month = _month - 1;
    NSUInteger day = 1;
    if (month < FIRST_MONTH_OF_YEAR) 
    {
        year--;
        month = 12;
    }
    ITTCalMonth *calMonth = [[ITTCalMonth alloc] initWithMonth:month year:year day:day];
    return calMonth;    
}

- (ITTCalMonth*)nextYear
{
    NSUInteger year = _year + 1;
    NSUInteger month = _month;
    NSUInteger day = 1;
    ITTCalMonth *calMonth = [[ITTCalMonth alloc] initWithMonth:month year:year day:day];
    return calMonth;
}

- (ITTCalMonth*)previousYear
{
    NSUInteger year = _year - 1;
    NSUInteger month = _month;
    NSUInteger day = 1;
    ITTCalMonth *calMonth = [[ITTCalMonth alloc] initWithMonth:month year:year day:day];
    return calMonth;
}

- (id)initWithMonth:(NSUInteger)month
{
    self = [super init];
    if (self)
    {
        _today = [[ITTCalDay alloc] initWithYear:[CalendarDateUtil getCurrentYear] month:month day:1];
        [self caculateMonth];                
    }
    return self;    
}

- (id)initWithMonth:(NSUInteger)month year:(NSUInteger)year
{
    self = [super init];
    if (self)
    {
        _today = [[ITTCalDay alloc] initWithYear:year month:month day:1];
        [self caculateMonth];                
    }
    return self;
}

- (id)initWithDate:(NSDate*)d
{
    self = [super init];
    if (self)
    {
        _today = [[ITTCalDay alloc] initWithDate:d];
        [self caculateMonth];
    }
    return self;    
}

- (id)initWithMonth:(NSUInteger)month year:(NSUInteger)year day:(NSUInteger)day
{
    self = [super init];
    if (self)
    {
        _today = [[ITTCalDay alloc] initWithYear:year month:month day:day];
        [self caculateMonth];        
    }
    return self;    
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"year:%lu month:%lu number of days in month:%lu", 
            (unsigned long)_year, (unsigned long)_month, (unsigned long)_numberOfDays];
}

- (NSUInteger)days
{
    return _numberOfDays;
}

- (NSUInteger)getYear
{
    return _year;    
}

- (NSUInteger)getMonth
{
    return _month;
}

- (ITTCalDay*)calDayAtDay:(NSUInteger)day
{
    NSInteger index = day - 1;
    NSAssert(!(index < 0||index > 31), @"invalid day index %ld", (long)index);
    return [daysOfMonth objectAtIndex:index];
}

- (ITTCalDay*)firstDay
{
    return [daysOfMonth objectAtIndex:0];    
}

- (ITTCalDay*)lastDay
{
    return [daysOfMonth objectAtIndex:_numberOfDays - 1];        
}

- (NSComparisonResult)compare:(ITTCalMonth *)another
{
    if (_year < [another getYear]) 
        return NSOrderedAscending;
    else if (_year > [another getYear])
        return NSOrderedDescending;
    else {
        if (_month < [another getMonth]) {
            return NSOrderedAscending;
        } else if (_month > [another getMonth])
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }
}

@end
