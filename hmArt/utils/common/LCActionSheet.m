//
//  LCActionSheet.m
//  uni114
//
//  Created by wangyong on 13-3-8.
//
//

#import "LCActionSheet.h"
#import "LCGlobalDeviceInfo.h"
@interface LCActionSheet ()

- (void)pickerDone:(id)sender;

@end

@implementation LCActionSheet

@synthesize cancelButtonTag;
@synthesize okButtonTag;
@synthesize cancelButtonBlock;
@synthesize okButtonBlock;
@synthesize serviceName;
@synthesize serviceType;

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

- (id) initWithTitle:(NSString *)title
   cancelButtonTitle:(NSString *)cancelTitle
     cancelButtonTag:(NSInteger)cancelTag
         cancelBlock:(LCActionSheetBlock)cancelBlock
       okButtonTitle:(NSString *)okTitle
         okButtonTag:(NSInteger)okTag
             okBlock:(LCActionSheetBlock)okBlock
{
    if ((self = [super initWithTitle:title
                            delegate:nil
                   cancelButtonTitle:nil
              destructiveButtonTitle:nil
                   otherButtonTitles:nil])) {
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        toolbar.barStyle = UIBarStyleBlackOpaque;
        [toolbar sizeToFit];
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        if (cancelTitle) {
            UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:cancelTitle style:UIBarButtonItemStyleBordered target:self action:@selector(pickerDone:)];
            self.cancelButtonTag = cancelTag;
            cancelBtn.tag = cancelTag;
            self.cancelButtonBlock = cancelBlock;
            [barItems addObject:cancelBtn];
        }
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [barItems addObject:flexSpace];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:okTitle style:UIBarButtonItemStyleDone target:self action:@selector(pickerDone:)];
        doneBtn.tag = okTag;
        self.okButtonTag = okTag;
        self.okButtonBlock = okBlock;
        [barItems addObject:doneBtn];
        [toolbar setItems:barItems animated:YES];
        [self addSubview:toolbar];
    }
    return self;
}
- (id) initWithTitle:(NSString *)title
               phone:(NSString *)phone
                type:(NSString *)type
                name:(NSString *)name
   cancelButtonTitle:(NSString *)cancelTitle
       okButtonTitle:(NSString *)okTitle
{
    NSString *showTitle = [NSString stringWithFormat:@"%@:%@?", title, phone];
    if ((self = [super initWithTitle:showTitle
                            delegate:self
                   cancelButtonTitle:cancelTitle
              destructiveButtonTitle:okTitle
                   otherButtonTitles:nil])) {
        self.phone = phone;
        self.serviceName = name;
        self.serviceType = type;
    }
    return self;
    
}

- (id) initWithTitle:(NSString *)title
               phone:(NSString *)phone
     showPhoneNumber:(BOOL)show
                type:(NSString *)type
                name:(NSString *)name
   cancelButtonTitle:(NSString *)cancelTitle
       okButtonTitle:(NSString *)okTitle

{
    NSMutableString *showTitle = [[NSMutableString alloc] initWithCapacity:10];
    if (show) {
        [showTitle appendFormat:@"%@:%@", title, phone];
    }else{
        [showTitle appendFormat:@"%@", title];
    }
    if ((self = [super initWithTitle:showTitle
                            delegate:self
                   cancelButtonTitle:cancelTitle
              destructiveButtonTitle:okTitle
                   otherButtonTitles:nil])) {
        self.phone = phone;
        self.serviceName = name;
        self.serviceType = type;
    }
    return self;
    
}


- (void)pickerDone:(id)sender
{
    NSInteger buttonTag = [sender tag];
    
    if (buttonTag == cancelButtonTag) {
        if (self.cancelButtonBlock)
            self.cancelButtonBlock();
    } else if (buttonTag == self.okButtonTag) {
        if (self.okButtonBlock)
            self.okButtonBlock();
    }
    [self dismissWithClickedButtonIndex:0 animated:YES];
    
}
- (void)dealloc {
    cancelButtonBlock = nil;
    okButtonBlock = nil;
}

- (void) showMe:(UIView *)view
{
    [self showInView:view];
    //[self showFromTabBar:view];
    self.bounds = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 20);
}



- (void) showPhonecall:(UIView *)view
{
    [self showInView:view];
}

#pragma mark -
#pragma mark Action Sheet Delegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex])
    {
        //[LCGlobalDeviceInfo submitPhoneCallLog:self.serviceName withType:self.serviceType phoneNumber:self.phone];
        UIApplication *myApp = [UIApplication sharedApplication];
        NSString *theCall = [NSString stringWithFormat:@"tel://%@",self.phone];
        [myApp openURL:[NSURL URLWithString:theCall]];
        
    }
}


@end
