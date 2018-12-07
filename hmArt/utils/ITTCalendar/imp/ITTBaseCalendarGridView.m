//
//  BaseCalendarGridView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 itotemstudio. All rights reserved.
//

#import "ITTBaseCalendarGridView.h"

@interface ITTBaseCalendarGridView()

@property (retain, nonatomic) IBOutlet UIButton *gridButton;

@end

@implementation ITTBaseCalendarGridView

@synthesize gridButton;

- (IBAction)onGridButtonTouched:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(calendarGridViewDidSelectGrid:)]) {
        [_delegate ittCalendarGridViewDidSelectGrid:self];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)select
{
    self.selected = TRUE;
    self.gridButton.selected = TRUE; 
    self.gridButton.userInteractionEnabled = FALSE;
}

- (void)deselect
{
    self.selected = FALSE;
    self.gridButton.selected = FALSE;
    self.gridButton.userInteractionEnabled = TRUE;    
}

- (void)layoutSubviews
{
    NSString *title = [NSString stringWithFormat:@"%lu", (unsigned long)[_calDay getDay]];
    if (_selectedEanable) {
        if (self.selected) {
            self.gridButton.highlighted = NO;
            self.gridButton.selected = YES;
            [self.gridButton setTitleColor:[UIColor colorWithRed:85/255.0 green:71/255.0 blue:71/255.0 alpha:1] forState:UIControlStateNormal];
        }else{
            self.gridButton.highlighted = YES;
            self.gridButton.selected = NO;
            [self.gridButton setTitleColor:[UIColor colorWithRed:85/255.0 green:71/255.0 blue:71/255.0 alpha:1] forState:UIControlStateHighlighted];
        }
    }
    else {
        self.gridButton.selected = FALSE;
        self.gridButton.highlighted = NO;
        [self.gridButton setTitleColor:[UIColor colorWithRed:176/255.0 green:175/255.0 blue:173/255.0 alpha:1] forState:UIControlStateNormal];
    }
    [self.gridButton setTitle:title forState:UIControlStateNormal];
    [self.gridButton setTitle:title forState:UIControlStateHighlighted];

    
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self setNeedsLayout];
}

- (void)dealloc 
{
    [gridButton release];
    [super dealloc];
}
@end
