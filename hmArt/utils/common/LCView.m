//
//  LCView.m
//  lifeassistant
//
//  Created by liuxue on 13-8-22.
//
//

#import "LCView.h"

@implementation LCView

@synthesize _itemArray2;
@synthesize _itemArray;

@synthesize _paddingBottom;
@synthesize _paddingLeft;
@synthesize _paddingRight;
@synthesize _paddingTop;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initParam];
    }
    return self;
}

- (void) initParam{
    _paddingTop = 0;
    _paddingBottom = 0;
    _paddingLeft = 0;
    _paddingRight = 0;
    
}

-(void)setPaddingTop:(float)top paddingBottom:(float)bottom paddingLeft:(float)left paddingRight:(float)right
{
    _paddingTop = top;
    _paddingBottom = bottom;
    _paddingLeft = left;
    _paddingRight = right;
}

-(void)addCustomSubview:(UIView *)view intervalTop:(float)_interval
{
    if (!_itemArray) {
        _itemArray = [[NSMutableArray alloc] init];
    }
    NSInteger count = _itemArray.count;
    LCViewVaule *lcv = [[LCViewVaule alloc] initViewValue:view interval:_interval];
    
    float x = view.frame.origin.x;
    if (x < _paddingLeft) {
        x = _paddingLeft;
    }
    //float x = _paddingLeft;
    UIView *v = [self getShowView:_itemArray];
    float y = v.frame.origin.y + v.frame.size.height+_interval;
    
    float width = view.frame.size.width;
    if (width <=0 || width > (self.frame.size.width-_paddingRight-x)) {
        width = self.frame.size.width-_paddingRight-x;
    }
    
    view.frame = CGRectMake(x, y, width, view.frame.size.height);
    view.backgroundColor = [UIColor clearColor];
    if(view.tag == 0) view.tag = count;
    [_itemArray addObject:lcv];
    if (!view.hidden) {
        float h = view.frame.origin.y + view.frame.size.height + _paddingBottom;
        if (h > self.frame.size.height) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
        }
    }
    [super addSubview:view];
}

-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval{
    [self addCustomSublabel:label intervalTop:_interval textMaxShowWidth:0];
}
-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval font:(UIFont *)_font{
    [self addCustomSublabel:label intervalTop:_interval textMaxShowWidth:0 textMaxShowHeight:0 font:_font];
}
-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval textMaxShowWidth:(float)_maxShowWidth{
    [self addCustomSublabel:label intervalTop:_interval textMaxShowWidth:_maxShowWidth textMaxShowHeight:0];
}

-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMaxShowHeight:(float)_maxShowHeight
{
    [self addCustomSublabel:label intervalTop:_interval textMaxShowWidth:_maxShowWidth textMaxShowHeight:_maxShowHeight font:nil];
}

-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMaxShowHeight:(float)_maxShowHeight font:(UIFont *)_font
{
    if (!_itemArray) {
        _itemArray = [[NSMutableArray alloc] init];
    }
    NSInteger count = _itemArray.count;
    LCViewVaule *lcv = [[LCViewVaule alloc] initViewValue:label interval:_interval];
    
    UIView *v = [self getShowView:_itemArray];
    float y = v.frame.origin.y + v.frame.size.height+_interval;
    
    if (_maxShowWidth <= 0 || _maxShowWidth > (self.frame.size.width-_paddingLeft-_paddingRight-label.frame.origin.x)) {
        _maxShowWidth = self.frame.size.width-_paddingLeft-_paddingRight-label.frame.origin.x;
    }
    if (_font == nil) {
        _font = [UIFont systemFontOfSize:14.0f];
    }
    label.font = _font;
    CGRect frame = label.frame;
    frame.origin.x = frame.origin.x + _paddingLeft;
    frame.origin.y = frame.origin.y + y + _interval;
    
    CGSize size =  [HMUtility calculateSize:label.text withFont:label.font fixedWidth:_maxShowWidth];
    
    if (size.height > frame.size.height) {
        frame.size.height = size.height;
    }
    if (_maxShowHeight > 0 && frame.size.height > _maxShowHeight) {
        frame.size.height = _maxShowHeight;
    }
    
    if (size.width > frame.size.width) {
        frame.size.width = size.width;
    }else{
        if (_maxShowWidth < frame.size.width) {
            frame.size.width = _maxShowWidth;
        }
    }
    label.frame = frame;
    
    label.lineBreakMode = UILineBreakModeTailTruncation;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    if(label.tag == 0) label.tag = count;
    [_itemArray addObject:lcv];
    if (!label.hidden) {
        float h = label.frame.origin.y + label.frame.size.height + _paddingBottom;
        if (h > self.frame.size.height) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
        }
    }
    [super addSubview:label];
}

-(void)addCustomSubview:(UIView *)view intervalLeft:(float)_interval
{
    if (!_itemArray2) {
        _itemArray2 = [[NSMutableArray alloc] init];
    }
    NSInteger count = _itemArray2.count;
    LCViewVaule *lcv = [[LCViewVaule alloc] initViewValue:view interval:_interval];
    
    float y = _paddingTop+view.frame.origin.y;
    UIView *v = [self getShowView:_itemArray2];
    float x = v.frame.origin.x + v.frame.size.width + _interval;
    
    float width = view.frame.size.width;
    if (width <= 0 || width > (self.frame.size.width-_paddingRight-(x))) {
        width = self.frame.size.width-_paddingRight-(x);
    }
    view.frame = CGRectMake(x, y,width,view.frame.size.height);
    view.backgroundColor = [UIColor clearColor];
    if(view.tag == 0) view.tag = count;
    [_itemArray2 addObject:lcv];
    //if (!view.hidden) {
        float h = view.frame.origin.y + view.frame.size.height + _paddingBottom;
        if (h > self.frame.size.height) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
        }
    //}
    [super addSubview:view];
}

-(void)addCustomSublabel:(UILabel *)label intervalLeft:(float)_interval{
    [self addCustomSublabel:label intervalLeft:_interval textMaxShowWidth:0 textMaxShowHeight:0];
}
-(void)addCustomSublabel:(UILabel *)label intervalLeft:(float)_interval font:(UIFont *)_font{
    [self addCustomSublabel:label intervalLeft:_interval textMaxShowWidth:0 textMaxShowHeight:0 font:_font];
}
-(void)addCustomSublabel:(UILabel *)label intervalLeft:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMaxShowHeight:(float)_maxShowHeight{
    [self addCustomSublabel:label intervalLeft:_interval textMaxShowWidth:_maxShowWidth textMaxShowHeight:_maxShowHeight font:nil];
}

-(void)addCustomSublabel:(UILabel *)label intervalLeft:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMaxShowHeight:(float)_maxShowHeight font:(UIFont *)_font{
    if (!_itemArray2) {
        _itemArray2 = [[NSMutableArray alloc] init];
    }
    NSInteger count = _itemArray2.count;
    
    float y = _paddingTop+label.frame.origin.y;
    UIView *v = [self getShowView:_itemArray2];
    float x = v.frame.origin.x + v.frame.size.width +_interval;
    
    if (_maxShowWidth <= 0 || _maxShowWidth > (self.frame.size.width-_paddingRight-(x))) {
        _maxShowWidth = self.frame.size.width-_paddingRight-(x);
    }
    LCViewVaule *lcv = [[LCViewVaule alloc] initViewValue:label interval:_interval textMaxShowWidth:_maxShowWidth textMinShowWidth:label.frame.size.width textMaxShowHeight:_maxShowHeight textMinShowHeight:label.frame.size.height font:_font];
    
    if (_font == nil) {
        _font = [UIFont systemFontOfSize:13.0f];
    }
    label.font = _font;
    CGSize size =  [HMUtility calculateSize:label.text withFont:label.font fixedWidth:_maxShowWidth];
    
    if (size.height < label.frame.size.height) {
        size.height = label.frame.size.height;
    }
    if (_maxShowHeight > 0 && size.height > _maxShowHeight) {
        size.height = _maxShowHeight;
    }
    
    if (size.width < label.frame.size.width) {
        if (label.frame.size.width > self.frame.size.width-_paddingRight-x) {
            label.frame = CGRectMake(x, y, self.frame.size.width-_paddingRight-x, size.height);
        }else{
            label.frame = CGRectMake(x, y, label.frame.size.width, size.height);
        }
    }else{
        label.frame = CGRectMake(x, y, size.width, size.height);
    }
    label.lineBreakMode = UILineBreakModeTailTruncation;
    label.numberOfLines = 0;
    label.backgroundColor = [UIColor clearColor];
    if(label.tag == 0) label.tag = count;
    [_itemArray2 addObject:lcv];
    float h = label.frame.origin.y + label.frame.size.height + _paddingBottom;
    if (h > self.frame.size.height) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
    }
    [super addSubview:label];
}

-(void)resize{
    if(_itemArray && _itemArray.count > 0) {
        float y = _paddingTop;
        for (LCViewVaule *lcvv in _itemArray) {
            UIView *view = lcvv.view;
            if (!view.hidden) {
                if ([view isKindOfClass:[LCView class]]) {
                    LCView *lcv = (LCView *)view;
                    [lcv resize];
                }
                CGRect rect = view.frame;
                view.frame = CGRectMake(rect.origin.x, y+lcvv.interval, rect.size.width, rect.size.height);
                y = view.frame.origin.y + view.frame.size.height;
            }
        }
        float h = y + _paddingBottom;
        //if (h > self.frame.size.height) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
            [self setNeedsDisplay];
        //}
    }
    if(_itemArray2 && _itemArray2.count > 0) {
        float h = 0;
        float x = 0;
        for (LCViewVaule *lcvv in _itemArray2) {
            UIView *view = lcvv.view;
            if (!view.hidden) {
                if ([view isKindOfClass:[LCView class]]) {
                    LCView *lcv = (LCView *)view;
                    [lcv resize];
                    
                }/**if ([view isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)view;
                    CGSize size =  [HMUtility calculateSize:label.text withFont:label.font fixedWidth:lcvv.maxShowWidth];
                    CGRect frame = label.frame;
                    frame.size = size;
                    if (lcvv.maxShowHeight>0 && size.height > lcvv.maxShowHeight) {
                        frame.size.height = lcvv.maxShowHeight;
                    }
                    label.frame = frame;
                }**/
                
                float h1 = view.frame.origin.y + view.frame.size.height + _paddingBottom;
                if(h < h1){
                    h = h1;
                }
                if (x == 0) {
                    x = view.frame.origin.x + view.frame.size.width;
                }else{
                    CGRect frame = view.frame;
                    frame.origin.x = x+lcvv.interval;
                    view.frame = frame;
                    x = view.frame.origin.x + view.frame.size.width;
                }
            }
        }
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
        [self setNeedsDisplay];
        
    }
}


-(void)resetHeight{
    if(_itemArray && _itemArray.count > 0) {
        UIView *view = [_itemArray objectAtIndex:_itemArray.count-1];
        float h = view.frame.origin.y + view.frame.size.height + _paddingBottom;
        //if (h > self.frame.size.height) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
            [self setNeedsDisplay];
        //}
    }
    if (_itemArray2 && _itemArray2.count > 0) {
        float h = 0;
        for (UIView *view in _itemArray2) {
            float h1 = view.frame.origin.y + view.frame.size.height + _paddingBottom;
            if(h < h1){
                h = h1;
            }
        }
        //if (h > self.frame.size.height) {
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h);
            [self setNeedsDisplay];
        //}
    }
}

-(void)clearUp{
    _itemArray = nil;
    _itemArray2 = nil;
    for (UIView *_v in [self subviews]) {
        [_v removeFromSuperview];
    }
}

-(id) getShowView:(NSMutableArray *)itemArray{
    NSInteger count = itemArray.count;
    for (long i=count-1; i >= 0; i--) {
        UIView *view = ((LCViewVaule *)[itemArray objectAtIndex:(i)]).view;
        if (!view.hidden) {
            return view;
        }
    }
    return [[UIView alloc] initWithFrame:CGRectMake(_paddingLeft, _paddingTop, 0, 0)];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)customExtensionHeight:(float)_initHeight{
    
}

@end
