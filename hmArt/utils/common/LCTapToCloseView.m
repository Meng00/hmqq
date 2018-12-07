//
//  LCTapToCloseView.m
//  uni114
//
//  Created by Administrator on 12-12-2.
//
//

#import "LCTapToCloseView.h"

@implementation LCTapToCloseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    _target = nil;
    _action = nil;
}

#pragma mark -
#pragma mark 处理点击事件
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_target respondsToSelector:_action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_action];
#pragma clang diagnostic pop
    }
    [self removeFromSuperview];
}

@end
