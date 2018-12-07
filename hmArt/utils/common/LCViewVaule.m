//
//  LCViewVaule.m
//  lifeassistant
//
//  Created by 刘学 on 14-6-16.
//
//

#import "LCViewVaule.h"

@implementation LCViewVaule

@synthesize view;
@synthesize interval;
@synthesize maxShowHeight;
@synthesize maxShowWidth;
@synthesize minShowHeight;

-(id) initViewValue:(UIView *)_view interval:(float)_interval{
    self = [super init];
    if (self) {
        self.view = _view;
        self.interval = _interval;
        
    }
    return self;
}

-(id) initViewValue:(UIView *)_view interval:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMinShowWidth:(float)_minShowWidth textMaxShowHeight:(float)_maxShowHeight textMinShowHeight:(float)_minShowHeight font:(UIFont *)_font
{
    self = [super init];
    if (self) {
        self.view = _view;
        self.interval = _interval;
        self.maxShowWidth = _maxShowWidth;
        self.minShowWidth = _minShowWidth;
        self.maxShowHeight = _maxShowHeight;
        self.minShowHeight = _minShowHeight;
    }
    return self;
}

@end
