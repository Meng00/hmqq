//
//  HMFormController.h
//  hmArt
//
//  Created by wangyong on 13-7-9.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMInputController.h"
#import "DCRoundSwitch.h"

@interface HMFormController : HMInputController <UITableViewDataSource, GetValueDelegate>
{
    // 网络请求ID
    unsigned int _requestId;
    // 表单项
    NSArray *_formAttr;
    // 表单数据
    NSMutableDictionary *_formValues;
    
    NSString *_switchOnValue;
    NSString *_switchOffValue;
}

@property (strong, nonatomic) IBOutlet UITableView *myTableView;

- (NSInteger)tagWithSection:(NSInteger)section row:(NSInteger)row;
- (NSIndexPath *)indexPathWithTag:(NSInteger)rowTag;
- (NSMutableDictionary *)curFieldAttrWithSection:(NSInteger)section row:(NSInteger)row;
- (NSMutableDictionary *)curFieldAttrWithTag:(NSInteger)tag;
- (UIView *)curFieldViewWithSection:(NSInteger)section row:(NSInteger)row;
- (UIView *)curFieldViewWithTag:(NSInteger)tag;
- (void)setFormValue:(id)obj section:(NSInteger)section row:(NSInteger)row;
- (void)setFormValue:(id)obj tag:(NSInteger)tag;
- (id)getFormValueWithSection:(NSInteger)section row:(NSInteger)row;
- (id)getFormValueWithTag:(NSInteger)tag;
- (CGFloat)getRowHeightOfSection:(NSIndexPath *)indexPath;
- (void)setResponderAtSection:(NSInteger)section row:(NSInteger)row;
- (BOOL)verifyData;
@end
