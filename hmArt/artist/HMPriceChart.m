//
//  HMPriceChart.m
//  hmArt
//
//  Created by wangyong on 13-7-26.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMPriceChart.h"

@implementation HMPriceChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        linesLayer = [[CALayer alloc] init];
        linesLayer.masksToBounds = YES;
        linesLayer.contentsGravity = kCAGravityLeft;
        linesLayer.backgroundColor = [[UIColor whiteColor] CGColor];
        
        [self.layer addSublayer:linesLayer];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 50, 21)];
        lbl.text = @"单位:元";
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.font = [UIFont systemFontOfSize:14];
        [self addSubview:lbl];
        
        hInteval = 50;
        _popView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 60, 30)];
        [_popView setBackgroundColor:[UIColor blackColor]];
        [_popView setAlpha:0.0f];
        
        _showLabel = [[UILabel alloc]initWithFrame:_popView.frame];
        [_showLabel setTextAlignment:NSTextAlignmentCenter];
        
        [_popView addSubview:_showLabel];
        [self addSubview:_popView];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMe:)];
        recognizer.numberOfTapsRequired = 1;
        recognizer.numberOfTouchesRequired = 1;
        recognizer.cancelsTouchesInView = YES;
        [self addGestureRecognizer:recognizer];
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

- (void)drawRect:(CGRect)rect
{
    [self setClearsContextBeforeDrawing: YES];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //画背景线条------------------
    CGColorRef backColorRef = [UIColor blackColor].CGColor;
    CGFloat backLineWidth = 2.f;
    CGFloat backMiterLimit = 0.f;
    
    CGContextSetLineWidth(context, backLineWidth);//主线宽度
    CGContextSetMiterLimit(context, backMiterLimit);//投影角度
    
    CGContextSetShadowWithColor(context, CGSizeMake(3, 5), 8, backColorRef);//设置双条线
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetLineCap(context, kCGLineCapRound );
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    
    
    long x = 320 ;
    long y = 460 ;
    //画纵轴，上点（30，30），下点（30，307）或(30,395)
    CGPoint upPoint = CGPointMake(30, 30);
    CGPoint zeroPoint = CGPointMake(30, 320);
    CGContextMoveToPoint(context, zeroPoint.x, zeroPoint.y);
    CGContextAddLineToPoint(context, upPoint.x, upPoint.y);
    
    NSInteger totalCount = _array.count + 1;
    if (totalCount * 50 > 320) {
        x = totalCount * 50;
    }
    CGPoint rightPoint = CGPointMake(x, 320);
    CGContextMoveToPoint(context, zeroPoint.x, zeroPoint.y);
    CGContextAddLineToPoint(context, rightPoint.x, rightPoint.y);
    
    for (int i=0; i<_hDesc.count; i++) {
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(i*hInteval+30, 325, 40, 21)];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = YES;
//        label.minimumFontSize = 6.0f;
        NSString *s =[self getSellDate:[HMUtility getString:[_hDesc objectAtIndex:i]]] ;
        [label setText:s];
        
        [self addSubview:label];
    }
    
    
    //    //画点线条------------------
    CGColorRef pointColorRef = [UIColor colorWithRed:24.0f/255.0f green:116.0f/255.0f blue:205.0f/255.0f alpha:1.0].CGColor;
    CGFloat pointLineWidth = 1.5f;
    CGFloat pointMiterLimit = 5.0f;
    
    CGContextSetLineWidth(context, pointLineWidth);//主线宽度
    CGContextSetMiterLimit(context, pointMiterLimit);//投影角度
    
    
    CGContextSetShadowWithColor(context, CGSizeMake(3, 5), 8, pointColorRef);//设置双条线
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    CGContextSetLineCap(context, kCGLineCapRound );
    
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    
	//绘图
    
    y = [self getPosY:[[_array objectAtIndex:0] integerValue]];
	CGPoint p1 = CGPointMake(50, y);
    //添加触摸点
    /*
    UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [bt setBackgroundColor:[UIColor redColor]];
    
    [bt setFrame:CGRectMake(0, 0, 10, 10)];
    
    [bt setCenter:p1];
    
    bt.tag = 1;
    
    [bt addTarget:self action:@selector(btAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:bt];
    */
	CGContextMoveToPoint(context, p1.x, p1.y);
	for (int i = 0; i<[_array count]; i++)
	{
		x = (i + 1) * 50;
        y = [self getPosY:[[_array objectAtIndex:i] integerValue]];
        CGPoint goPoint = CGPointMake(x, y);
        CGContextMoveToPoint(context, goPoint.x, 320);
		CGContextAddLineToPoint(context, goPoint.x, goPoint.y);;
        /*
        //添加触摸点
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [bt setBackgroundColor:[UIColor redColor]];
        
        [bt setFrame:CGRectMake(0, 0, 10, 10)];
        
        [bt setCenter:goPoint];
        
        bt.tag = i + 1;
        
        [bt addTarget:self
               action:@selector(btAction:)
     forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:bt];*/
	}
	CGContextStrokePath(context);
    
}

- (NSString *)getSellDate:(NSString *)sell
{
    if (sell.length < 2) return sell;
    NSString *temp = [sell stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return [temp substringFromIndex:2];
}

- (CGFloat)getPosY:(NSInteger)price
{
    if (_array.count == 1) {
        return 200.0;
    }
    return (300.0 -   (price - _rangeLo) * 250.0 / (_rangeHi - _rangeLo));
}
- (void)btAction:(id)sender
{
    NSInteger tag = [sender tag];
    UIButton *bt = (UIButton*)sender;
    _popView.center = CGPointMake(bt.center.x, bt.center.y - _popView.frame.size.height/2);
    [_popView setAlpha:1.0f];
    _showLabel.text = [NSString stringWithFormat:@"%@", [_array objectAtIndex:(tag-1)]];
}
- (void)tapMe:(UITapGestureRecognizer *)recognizer
{
    [_popView setAlpha:0.0f];
}
@end
