//
//  LCActionSheet.h
//  uni114
//
//  Created by wangyong on 13-3-8.
//
//

#import <UIKit/UIKit.h>

typedef void(^LCActionSheetBlock)(void);

@interface LCActionSheet : UIActionSheet <UIActionSheetDelegate>


@property (nonatomic)NSInteger cancelButtonTag;
@property (nonatomic)NSInteger okButtonTag;
@property (nonatomic, copy)LCActionSheetBlock cancelButtonBlock;
@property (nonatomic, copy)LCActionSheetBlock okButtonBlock;
@property (nonatomic, copy)NSString *phone;
@property (nonatomic, copy)NSString *serviceName;
@property (nonatomic, copy)NSString *serviceType;

- (id) initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelTitle
            cancelButtonTag:(NSInteger)cancelTag
            cancelBlock:(LCActionSheetBlock)cancelBlock
            okButtonTitle:(NSString *)okTitle
            okButtonTag:(NSInteger)okTag
            okBlock:(LCActionSheetBlock)okBlock;

- (void) showMe:(UIView *)view;


- (id) initWithTitle:(NSString *)title
               phone:(NSString *)phone
                type:(NSString *)type
                name:(NSString *)name
   cancelButtonTitle:(NSString *)cancelTitle
       okButtonTitle:(NSString *)okTitle;

- (id) initWithTitle:(NSString *)title
               phone:(NSString *)phone
     showPhoneNumber:(BOOL)show
                type:(NSString *)type
                name:(NSString *)name
   cancelButtonTitle:(NSString *)cancelTitle
       okButtonTitle:(NSString *)okTitle;

- (void) showPhonecall:(UIView *)view;

@end
