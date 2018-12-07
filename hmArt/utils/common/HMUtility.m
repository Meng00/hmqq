//
//  HMUtility.m
//  hmArt
//
//  Created by wangyong on 13-6-16.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMUtility.h"
#import "HMModalBaseView.h"
#import "LCAnimationUtility.h"
#import "HMGlobal.h"
#import "ITTBaseDataSourceImp.h"
#import "ITTCalendarView.h"

#define kHMUserInfoId @"com.hanmo.51art.user.id"
#define kHMUserInfoMobile @"com.hanmo.51art.user.mobile"
#define kHMUserInfoPass @"com.hanmo.51art.user.pass"
#define kHMUserInfoName @"com.hanmo.51art.user.name"
#define kHMUserInfoBirth @"com.hanmo.51art.user.birth"
#define kHMUserInfoEmail @"com.hanmo.51art.user.email"
#define kHMUserInfoGender @"com.hanmo.51art.user.gender"
#define kHMUserInfoVIP @"com.hanmo.51art.user.vip"

@implementation HMUtility

+ (id)loadViewFromNib:(NSString *)nib withClass:(Class)clazz
{
    
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:nib owner:nil options:nil];
    
    for (UIView *view in views) {
        if([view isKindOfClass:clazz])
        {
            return view;
        }
    }
    return nil;
}

+ (UIView *)getRootView:(UIView *)view
{
    
    UIView *v = view;
    
    while(v.superview) {
        v = v.superview;
    }
    return v;
}


static HMModalBaseView *kLCModalViewBackground = nil;
+ (void)showModalView:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close
{
    if (kLCModalViewBackground == nil) {
        kLCModalViewBackground = [[HMModalBaseView alloc] initWithTap2Close:close];
    }
    [kLCModalViewBackground reset];
    kLCModalViewBackground.close = close;
    [kLCModalViewBackground setModalView:view baseView:rview];
}

+ (void)showModalViewOnTransparentBase:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close
{
    if (kLCModalViewBackground == nil) {
        kLCModalViewBackground = [[HMModalBaseView alloc] initWithTap2Close:close];
    }
    [kLCModalViewBackground reset];
    kLCModalViewBackground.close = close;
    kLCModalViewBackground.backgroundColorForMockView = [UIColor clearColor];
    kLCModalViewBackground.borderColorForMockView = [UIColor clearColor];
    [kLCModalViewBackground setModalView:view baseView:rview];
}

+ (void)showModalView:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close dlgBackgroundColor:(UIColor *)color
{
    if (kLCModalViewBackground == nil) {
        kLCModalViewBackground = [[HMModalBaseView alloc] initWithTap2Close:close];
    }
    kLCModalViewBackground.close = close;
    kLCModalViewBackground.backgroundColorForMockView = color;
    [kLCModalViewBackground setModalView:view baseView:rview];
}

+ (void)showModalView:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close fixSize:(CGSize)size
{
    if (kLCModalViewBackground == nil) {
        kLCModalViewBackground = [[HMModalBaseView alloc] initWithTap2Close:close];
    }
    kLCModalViewBackground.dialogSize = size;
    kLCModalViewBackground.close = close;
    [kLCModalViewBackground setModalView:view baseView:rview];
}

+ (void)showModalView:(UIView *)view baseView:(UIView *)rview clickBackgroundToClose:(BOOL)close fixSize:(CGSize)size dlgBackgroundColor:(UIColor *)color
{
    if (kLCModalViewBackground == nil) {
        kLCModalViewBackground = [[HMModalBaseView alloc] initWithTap2Close:close];
    }
    kLCModalViewBackground.dialogSize = size;
    kLCModalViewBackground.backgroundColorForMockView = color;
    [kLCModalViewBackground setModalView:view baseView:rview];
}

+ (void)dismissModalView:(UIView *)view
{
    [view removeFromSuperview];
    [kLCModalViewBackground removeFromSuperview];
    [kLCModalViewBackground reset];
}


+ (void)addRoundCorner:(UIView *)view
            withRadius:(CGFloat)radius
             onTopLeft:(BOOL)topLeft
            onTopRight:(BOOL)topRight
          onBottomLeft:(BOOL)bottomLeft
         onBottonRight:(BOOL)bottomRight
{
    UIRectCorner corners = 0;
    if (topLeft)
        corners |= UIRectCornerTopLeft;
    if (topRight)
        corners |= UIRectCornerTopRight;
    if (bottomLeft)
        corners |= UIRectCornerBottomLeft;
    if (bottomRight)
        corners |= UIRectCornerBottomRight;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}


+ (CGPoint)caculLocation:(UIView *)view
           referenceView:(UIView *)referenceView
{
    
    UIView *v = view;
    
    CGPoint point = CGPointMake(0.0f, 0.0f);
    while(v) {
        point.x += v.frame.origin.x;
        point.y += v.frame.origin.y;
        v = v.superview;
        
        // 如果存在上级视图，且上级视图是可卷动视图
        if (v && [v isKindOfClass:[UIScrollView class]]) {
            UIScrollView *sv = (UIScrollView *)v;
            point.x -= sv.contentOffset.x;
            point.y -= sv.contentOffset.y;
        }
        
        if (v == referenceView)
            break;
        
    }
    return point;
}

+ (NSDate *)dateFrom:(NSString *)txt withFormat:(NSString *)format timeZone:(NSTimeZone *)zone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (zone)
        [formatter setTimeZone:zone];
    else
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    [formatter setDateFormat:format];
    return [formatter dateFromString:txt];
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format timeZone:(NSTimeZone *)zone
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    if (zone)
        [formatter setTimeZone:zone];
    else
        [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    return [formatter stringFromDate:date];
}

+ (NSDate *)getShortDate:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle: NSDateFormatterNoStyle];
    [df setDateStyle: NSDateFormatterMediumStyle];
    NSString *nowDateStr = [df stringFromDate:date];
    return  [df dateFromString:nowDateStr];
}

+ (NSDate *)datePlus:(NSDate *)date years:(NSInteger)years months:(NSInteger)months Days:(NSInteger)days hours:(NSInteger)hours minutes:(NSInteger)minutes seconds:(NSInteger)seconds
{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* dc1 = [[NSDateComponents alloc] init];
    if (years)
        [dc1 setYear:years];
    if (months)
        [dc1 setMonth:months];
    if (days)
        [dc1 setDay:days];
    if (hours)
        [dc1 setHour:hours];
    if (minutes)
        [dc1 setMinute:minutes];
    if (seconds)
        [dc1 setSecond:seconds];
    
    return [gregorian dateByAddingComponents:dc1 toDate:date options:0];
}


+ (void)showTip:(NSString *)text inView:(UIView *)view
{
    [HMUtility showTipInView:view withText:text];
}


+ (void)showTipInView:(UIView *)view withText:(NSString *)text
{
    UIView *rootView = [HMUtility getRootView:view];
    
    CGSize containerSize = rootView.bounds.size;
    
    CGFloat w = containerSize.width < 200 ? containerSize.width : 200;
    
    CGSize textSize = [HMUtility calculateSize:text withFont:[UIFont systemFontOfSize:15] fixedWidth:w - 20];
    
    CGFloat x = (containerSize.width - w) / 2;
    CGFloat y = (containerSize.height - textSize.height - 40) / 2;
    
    if ([rootView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *sv = (UIScrollView *)rootView;
        y += sv.contentOffset.y;
    }
    
    if (y < 0)
        y = 0;
    
    UIView *tipView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, textSize.height + 40)];
    tipView.backgroundColor = [UIColor darkGrayColor];
    tipView.layer.cornerRadius = 10.0;
    tipView.layer.borderColor = [UIColor colorWithWhite:0.936 alpha:1.0].CGColor;
    tipView.layer.borderWidth = 3.0;
    
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, w - 20, textSize.height + 20)];
    tv.font = [UIFont systemFontOfSize:15];
    tv.text = text;
    tv.textColor = [UIColor whiteColor];
    tv.clipsToBounds = YES;
    tv.backgroundColor = [UIColor clearColor];
    tv.userInteractionEnabled = NO;
    tv.textAlignment = NSTextAlignmentCenter;
    
    [tipView addSubview:tv];
    
    [LCAnimationUtility fadeOutView:tipView containerView:rootView delay:1 duration:1 completion:nil];
    
}


+ (CGSize)calculateSize:(NSString *)txt withFont:(UIFont *)font fixedWidth:(CGFloat)width
{
    CGSize size = [txt sizeWithFont:font
                  constrainedToSize: CGSizeMake(width, MAXFLOAT)
                      lineBreakMode: NSLineBreakByWordWrapping];
    return size;
}

+ (void)alert:(NSString *)message
        title:(NSString *) title
{
    UIAlertView *alertView = [[UIAlertView alloc] init];
    alertView.title = title;
    alertView.message = message;
    [alertView addButtonWithTitle:@"关闭"];
    
    [alertView show];
    
}


+ (void)tap2Action:(NSString *)text on:(UIView *)view target:(id)target action:(SEL)action
{
    UIView *rootView = view;//[LCUtility getRootView:view];
    
    CGSize containerSize = rootView.bounds.size;
    
    CGFloat w = containerSize.width < 200 ? containerSize.width : 200;
    
    CGSize textSize = [HMUtility calculateSize:text withFont:[UIFont systemFontOfSize:15] fixedWidth:w - 20];
    
    CGFloat x = (containerSize.width - w) / 2;
    CGFloat y = (containerSize.height - textSize.height - 40) / 2;
    
    if ([rootView isKindOfClass:[UIScrollView class]]) {
        UIScrollView *sv = (UIScrollView *)rootView;
        y += sv.contentOffset.y;
    }
    
    if (y < 0)
        y = 0;
    
    LCTapToCloseView *tipView = [[LCTapToCloseView alloc] initWithFrame:CGRectMake(x, y, w, textSize.height + 40)];
    tipView.backgroundColor = [UIColor whiteColor];
    tipView.layer.cornerRadius = 10.0;
    tipView.layer.borderColor = [UIColor colorWithWhite:0.936 alpha:1.0].CGColor;
    tipView.layer.borderWidth = 3.0;
    
    UITextView *tv = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, w - 20, textSize.height + 20)];
    tv.text = text;
    tv.font = [UIFont systemFontOfSize:15];
    tv.textColor = [UIColor blackColor];
    tv.clipsToBounds = YES;
    tv.backgroundColor = [UIColor whiteColor];
    tv.userInteractionEnabled = NO;
    tv.textAlignment = NSTextAlignmentCenter;
    
    [tipView addSubview:tv];
    
    tipView.target = target;
    tipView.action = action;
    
    [rootView addSubview:tipView];
}

+ (NSString *)getString:(NSString *)str
{
    if (!str) return @"";
    if ([str isEqual:[NSNull null]]) {
        return @"";
    }
    if ([str isEqualToString:@"<null>"]) {
        return @"";
    }
    return [NSString stringWithString:str];
}

+ (void)addBusyIndictor:(UIActivityIndicatorView *)indicator toView:(UIView *)view
{
    [indicator removeFromSuperview];
    indicator.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
    [view addSubview:indicator];
}
//生成length长的随机整数串
+ (NSString *)genRandom:(NSInteger)length
{
    NSMutableString *nms = [[NSMutableString alloc] initWithCapacity:length];
    for (int i = 0; i < length; i++) {
        int x = arc4random() % 10;
        [nms appendFormat:@"%d", x];
    }
    return nms;
}

+ (void)makeSearchBarTransparent:(UISearchBar *)searchBar
{
    for (UIView *subview in searchBar.subviews)
    {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
        {
            [subview removeFromSuperview];
            break;
        }
    }
}

+ (void)writeUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    [userDefaults setInteger:params.uid forKey:kHMUserInfoId];
    [userDefaults setObject:params.mobile forKey:kHMUserInfoMobile];
    [userDefaults setObject:params.password forKey:kHMUserInfoPass];
    [userDefaults setObject:params.name forKey:kHMUserInfoName];
    [userDefaults setObject:params.birth forKey:kHMUserInfoBirth];
    [userDefaults setObject:params.email forKey:kHMUserInfoEmail];
    [userDefaults setInteger:params.sex forKey:kHMUserInfoGender];
    [userDefaults setInteger:params.vip forKey:kHMUserInfoVIP];
    [userDefaults synchronize];
    
}

+ (void)readUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger uid = [userDefaults integerForKey:kHMUserInfoId];
    NSString *mobile = [userDefaults stringForKey:kHMUserInfoMobile];
    NSString *name = [userDefaults stringForKey:kHMUserInfoName];
    NSString *birth = [userDefaults stringForKey:kHMUserInfoBirth];
    NSString *email = [userDefaults stringForKey:kHMUserInfoEmail];
    NSString *pass = [userDefaults stringForKey:kHMUserInfoPass];
    NSInteger sex = [userDefaults integerForKey:kHMUserInfoGender];
    NSInteger vip = [userDefaults integerForKey:kHMUserInfoVIP];
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    params.uid = uid;
    params.mobile = mobile;
    params.name = name;
    params.birth = birth;
    params.email = email;
    params.sex = sex;
    params.password = pass;
    params.vip = vip;
}

+ (void)resetUserInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    HMGlobalParams *params = [HMGlobalParams sharedInstance];
    params.uid = 0;
    params.mobile = nil;
    params.name = nil;
    params.birth = nil;
    params.email = nil;
    params.sex = 1;
    params.password = nil;
    params.vip = 0;
    
    [userDefaults setInteger:params.uid forKey:kHMUserInfoId];
    [userDefaults setObject:params.mobile forKey:kHMUserInfoMobile];
    [userDefaults setObject:params.name forKey:kHMUserInfoName];
    [userDefaults setObject:params.birth forKey:kHMUserInfoBirth];
    [userDefaults setObject:params.email forKey:kHMUserInfoEmail];
    [userDefaults setInteger:params.sex forKey:kHMUserInfoGender];
    [userDefaults setObject:params.password forKey:kHMUserInfoPass];
    [userDefaults setInteger:params.vip forKey:kHMUserInfoVIP];
    [userDefaults synchronize];
    
}

+ (void)navBar:(UINavigationBar *)bar backImage:(NSString *)image backTag:(NSInteger)tag
{
    if ([bar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        //if iOS 5.0 and later
        UIImage *bgImage = [UIImage imageNamed:image];
        UIImage *stretchedImage = [bgImage stretchableImageWithLeftCapWidth:1 topCapHeight:5];
        
        [bar setBackgroundImage:stretchedImage forBarMetrics:UIBarMetricsDefault];
        //[bar setBackgroundImage:[UIImage imageNamed:image] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        UIImageView *imageView = (UIImageView *)[bar viewWithTag:tag];
        if (imageView == nil)
        {
            imageView = [[UIImageView alloc] initWithImage:
                         [UIImage imageNamed:image]];
            [imageView setTag:tag];
            [bar insertSubview:imageView atIndex:0];
        }
    }
    
}

/*
画廊作品价格规则p：p==1 已售
p<1 议价
p>1 原价显示

画家作品价格规则：
待售作品：p=-2  议价
P<>-2 原价显示
已售作品：原价显示
精品作品：p=-3 无效价格（不显示）
 
 type取值
 #define kPictureTypeGallery 1
 #define kPictureTypeForSale 1
 #define kPictureTypeSaled 2
 #define kPictureTypeWonderful 3

*/
+ (NSString *)getPrice:(NSNumber *)price pictureType:(NSInteger) type
{
    if (!price) {
        if (type == 3){//精品展区价格为null返回空不显示
            return @"";
        }else{
            return @"议价";
        }
    }
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    return [NSString stringWithFormat:@"￥%@", [numberFormatter stringFromNumber: price]];
/*    if (!price) {
        return @"";
    }
    NSInteger p = [price integerValue];
    switch (type) {
        case kPictureTypeGallery:
        {
            if (p == 1) {
                return @"已售";
            }else if (p < 1 ){
                return @"议价";
            }else {
                NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
                return [NSString stringWithFormat:@"￥%@", [numberFormatter stringFromNumber: price]];
            }
        }
            break;
        case kPictureTypeForSale:
        {
            if (p == -2) {
                return @"议价";
            }else {
                NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
                [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
                return [NSString stringWithFormat:@"￥%@", [numberFormatter stringFromNumber: price]];
            }
        }
            break;
        case kPictureTypeSaled:
        {
            NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
            return [NSString stringWithFormat:@"￥%@", [numberFormatter stringFromNumber: price]];
        }
            break;
        default:
            break;
    }
    
    return @"";*/
}

+ (BOOL)isComplexSize:(NSString *)pictureSize
{
    NSString *strRegex = @"[0-9]{1,5}x[0-9]{1,5}x[0-9]{1,3}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", strRegex];
    return [predicate evaluateWithObject:pictureSize];
}

+ (NSString *)dealPictureSize:(NSString *)pictureSize
{
    NSMutableString *s = [[NSMutableString alloc] initWithCapacity:1];
    if ([HMUtility isComplexSize:pictureSize]) {
        NSArray *sa = [pictureSize componentsSeparatedByString:@"x"];
        [s appendFormat:@"%@", [sa objectAtIndex:0]];
        [s appendString:@"x"];
        [s appendFormat:@"%@", [sa objectAtIndex:1]];
        [s appendString:@"cmx"];
        [s appendFormat:@"%@", [sa objectAtIndex:2]];
        
    }else{
        [s appendString:pictureSize];
        [s appendString:@"cm"];
    }
    return s;
}


+ (NSDictionary *) parametersWithSeparator:(NSString *)separator delimiter:(NSString *)delimiter url:(NSString *)str
{
    NSArray *parameterPairs =[str componentsSeparatedByString:delimiter];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[parameterPairs count]];
    
    for (NSString *currentPair in parameterPairs) {
        
        NSRange range = [currentPair rangeOfString:separator];
        
        if(range.location == NSNotFound)
            
            continue;
        
        NSString *key = [currentPair substringToIndex:range.location];
        
        NSString *value =[currentPair substringFromIndex:range.location + 1];
        
        [parameters setObject:value forKey:key];
        
    }
    
    return parameters;
}

+(NSString *) compareCurrentTimeBySeconds:(NSUInteger)seconds
{
    long temp = 0;
    long tempMod = 0;
    NSMutableString *retStr = [[NSMutableString alloc] initWithCapacity:10];
    temp = seconds / 86400;
    tempMod = seconds - temp * 86400;
    if (temp > 0) {
        [retStr appendFormat:@"%li天", temp];
    }
    
    temp = tempMod / 3600;
    tempMod = tempMod - temp * 3600;
    if (temp > 0) {
        [retStr appendFormat:@"% 02li:", temp];
    }else{
        [retStr appendString:@"00:"];
    }
    
    temp = tempMod / 60;
    if (temp>0) {
        [retStr appendFormat:@"%02li:", temp];
    }else{
        [retStr appendString:@"00:"];
    }
    
    temp = tempMod - temp * 60;
    if (temp>0) {
        [retStr appendFormat:@"%02li", temp];
    }else{
        [retStr appendString:@"00"];
    }
    
    return  retStr;
}


+ (void)showCalendarInView:(UIView *)baseView target:(id)target currDate:(NSDate*)curDate minimumDate:(NSDate*)minDate maximumDate:(NSDate*)maxDate hideYear:(BOOL)hidden
{
    ITTCalendarView *_calendarView = [ITTCalendarView viewFromNib];
    ITTBaseDataSourceImp *dataSource = [[ITTBaseDataSourceImp alloc] init];
    _calendarView.date = curDate;
    _calendarView.dataSource = dataSource;
    _calendarView.delegate = target;
    _calendarView.frame = CGRectMake(8, 10, 309, 450);
    _calendarView.minimumDate = minDate;
    _calendarView.maximumDate = maxDate;
    _calendarView.hideYear = hidden;
    [_calendarView showInView:baseView];
    
}


@end
