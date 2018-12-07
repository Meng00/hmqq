//
//  HMFormController.m
//  hmArt
//
//  Created by wangyong on 13-7-9.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMFormController.h"

@interface HMFormController ()

@end

@implementation HMFormController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.inputform = (UIScrollView *)self.myTableView;
    self.getValueDelegate = self;
    _formValues = [[NSMutableDictionary alloc] init];
    _switchOffValue = @"1";
    _switchOnValue = @"0";
}

- (void)viewDidUnload {
    [super viewDidUnload];
    _formAttr = nil;
    _formValues = nil;
    [self setMyTableView:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tagWithSection:(NSInteger)section row:(NSInteger)row
{
    return (section + 1)*1000 + row;
}

- (NSIndexPath *)indexPathWithTag:(NSInteger)rowTag
{
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:rowTag%1000 inSection:(rowTag/1000 - 1)];
    return newPath;
}

- (NSDictionary *)curFieldAttrWithSection:(NSInteger)section row:(NSInteger)row
{
    NSDictionary *oneSection = [_formAttr objectAtIndex:section];
    NSArray *fields = [oneSection objectForKey:@"fields"];
    NSDictionary *oneFiled = [fields objectAtIndex:row];
    return oneFiled;
}

- (NSDictionary *)curFieldAttrWithTag:(NSInteger)tag
{
    NSIndexPath * indexPath = [self indexPathWithTag:tag];
    return [self curFieldAttrWithSection:indexPath.section row:indexPath.row];
}

- (UIView *)curFieldViewWithSection:(NSInteger)section row:(NSInteger)row
{
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *curCell = [self.myTableView
                                cellForRowAtIndexPath:newPath];
    UIView *curView = [curCell viewWithTag:[self tagWithSection:section row:row]];
    return curView;
}

//- (UIView *)curFieldUIViewWithTag:(NSInteger)tag
- (UIView *)curFieldViewWithTag:(NSInteger)tag
{
    NSIndexPath * indexPath = [self indexPathWithTag:tag];
    return [self curFieldViewWithSection:indexPath.section row:indexPath.row];
}

- (void)setFormValue:(id)obj section:(NSInteger)section row:(NSInteger)row
{
    [self setFormValue:obj tag:[self tagWithSection:section row:row]];
}

- (void)setFormValue:(id)obj tag:(NSInteger)tag
{
    if(obj == nil)return;
    [_formValues setObject:obj forKey:[NSNumber numberWithInteger:tag]];
    NSDictionary *oneField = [self curFieldAttrWithTag:tag];
    if ([[oneField objectForKey:@"fieldType"] isEqualToString:@"sex"]) {
        //UIView *curView = [self curFieldUIViewWithTag:tag];
        UIView *curView = [self curFieldViewWithTag:tag];
        if ([curView isKindOfClass:[DCRoundSwitch class]]) {
            DCRoundSwitch *rSwitch = (DCRoundSwitch *)curView;
            if (obj == [NSNull null]) obj = @"";
            if([obj isEqualToString:@"0"])rSwitch.on = YES;
            else rSwitch.on = NO;
        }
    }
    else if (![[oneField objectForKey:@"fieldType"] isEqualToString:@"hidden"]){
        if ([obj isKindOfClass:[NSNumber class]]){
            NSNumber *numVal = (NSNumber *)obj;
            [self setValue:[NSString stringWithFormat:@"%d", numVal.intValue] toSeq:tag];
        }
        else [self setValue:obj toSeq:tag];
    }
}

- (id)getFormValueWithSection:(NSInteger)section row:(NSInteger)row
{
    return [self getFormValueWithTag:[self tagWithSection:section row:row]];
}

- (id)getFormValueWithTag:(NSInteger)tag
{
    NSDictionary *oneField = [self curFieldAttrWithTag:tag];
    if ([[oneField objectForKey:@"fieldType"] isEqualToString:@"text"]) {
        return [self getValueForSeq:tag];
    }
    else return [_formValues objectForKey:[NSNumber numberWithInteger:tag]];
}

- (void)setResponderAtSection:(NSInteger)section row:(NSInteger)row
{
    NSIndexPath *newPath = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *nextCell = [self.myTableView
                                 cellForRowAtIndexPath:newPath];
    UIView *oneView = [nextCell viewWithTag:[self tagWithSection:section row:row]];
    if ([oneView isMemberOfClass:[UITextField class]]){
        UITextField *nextField = (UITextField *)oneView;
        [nextField becomeFirstResponder];
    }
}

- (BOOL)verifyData
{
    [self getInputValues];
    // 数据校验
    for (unsigned i=0; i<_formAttr.count; i++) {
        NSDictionary *oneSection = [_formAttr objectAtIndex:i];
        NSArray *fields = [oneSection objectForKey:@"fields"];
        for (unsigned j=0; j<fields.count; j++) {
            NSString *value = [self getFormValueWithSection:i row:j];
            BOOL isValid = YES;
            NSString *tipStr = @"";
            NSDictionary *oneFiled = [fields objectAtIndex:j];
            if (value == nil || [value length] < 1) {
                if ([[oneFiled objectForKey:@"required"] isEqualToString:@"1"]) {
                    isValid = NO;
                    tipStr = @"不能为空";
                }
            } else {
                if ([[oneFiled objectForKey:@"isNumber"] isEqualToString:@"1"]) {
                    if (![HMTextChecker checkIsNumber:value]){
                        isValid = NO;
                        tipStr = @"必须是数字";
                    } else {
                        if ([oneFiled objectForKey:@"max"]) {
                            NSInteger val = [value integerValue];
                            NSNumber *max = [oneFiled objectForKey:@"max"];
                            
                            if (val > [max integerValue]) {
                                isValid = NO;
                                tipStr = [NSString stringWithFormat: @"不能大于%@", max];
                            }
                        }
                    }
                }
                if ([[oneFiled objectForKey:@"isPersonID"] isEqualToString:@"1"]) {
                    if (![HMTextChecker checkID:value]){
                        isValid = NO;
                        tipStr = @"不是合法的居民身份证格式";
                    }
                }
                if ([[oneFiled objectForKey:@"isMobile"] isEqualToString:@"1"]) {
                    if (![HMTextChecker checkIsNumber:value withLength:11]){
                        isValid = NO;
                        tipStr = @"不是合法的手机号码格式";
                    }
                }
            }
            if (!isValid) {
                NSString *fieldLabel = [oneFiled objectForKey:@"fieldLabel"];
                fieldLabel = [fieldLabel substringToIndex:(fieldLabel.length - 1)];
                [HMUtility showTipInView:self.view withText:[NSString stringWithFormat:@"%@%@", fieldLabel, tipStr]];
                [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                [self setResponderAtSection:i row:j];
                return NO;
            }
        }
    }
    return YES;
}

- (CGFloat)getRowHeightOfSection:(NSIndexPath *)indexPath
{
    NSDictionary *oneSection = [_formAttr objectAtIndex:indexPath.section];
    NSNumber *defaultHeight = [oneSection objectForKey:@"rowHeight"];
    NSDictionary *oneFiled = [self curFieldAttrWithSection:indexPath.section row:indexPath.row];
    NSNumber *rowHeight = [oneFiled objectForKey:@"height"];
    CGFloat height = 44;
    if (rowHeight) {
        height = [rowHeight floatValue];
    } else{
        if (defaultHeight)
            height = [defaultHeight floatValue];
    }
    
    return height;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _formAttr.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *oneSection = [_formAttr objectAtIndex:section];
    return [oneSection objectForKey:@"sectionTitle"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self getRowHeightOfSection:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *oneSection = [_formAttr objectAtIndex:section];
    NSArray *fields = [oneSection objectForKey:@"fields"];
    NSInteger tCount = fields.count;
    for (unsigned i = 0; i<fields.count; i++) {
        NSDictionary *oneField = [fields objectAtIndex:i];
        if ([[oneField objectForKey:@"fieldType"] isEqualToString:@"hidden"])tCount--;
    }
    return tCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = [NSString stringWithFormat:@"LCForm%ld-%ld", (long)indexPath.section, (long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:
                             cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellIdentifier];
        NSDictionary *oneSection = [_formAttr objectAtIndex:indexPath.section];
        NSDictionary *oneFiled = [self curFieldAttrWithSection:indexPath.section row:indexPath.row];
        NSUInteger rowTag = [self tagWithSection:indexPath.section row:indexPath.row];
        CGFloat rowHeight = [self getRowHeightOfSection:indexPath];
        
        CGFloat yOffset = 10;
        if (rowHeight > 44)
            yOffset = (rowHeight - 25) / 2;
        CGFloat labelWidth = 90;
        NSNumber *lWidth = [oneSection objectForKey:@"labelWidth"];
        if (lWidth)labelWidth = lWidth.floatValue;
        
        UILabel *label = [[UILabel alloc] initWithFrame:
                          CGRectMake(0, yOffset, labelWidth, 25)];
        label.textAlignment = NSTextAlignmentRight;
        label.font = [UIFont systemFontOfSize:14];
        label.backgroundColor = [UIColor clearColor];
        label.text = [oneFiled objectForKey:@"fieldLabel"];
        [cell.contentView addSubview:label];
        if ([[oneFiled objectForKey:@"showStar"] isEqualToString:@"1"]){
            UILabel *labelStar = [[UILabel alloc] initWithFrame:
                                  CGRectMake(90, yOffset, 6, 25)];
            labelStar.textAlignment = NSTextAlignmentLeft;
            labelStar.font = [UIFont boldSystemFontOfSize:14];
            labelStar.textColor = [UIColor redColor];
            labelStar.backgroundColor = [UIColor clearColor];
            labelStar.text = @"*";
            [cell.contentView addSubview:labelStar];
        }
        CGFloat fLeft = labelWidth + 10;
        CGFloat fWidth = 280 - fLeft;
        NSNumber *sWidth = [oneFiled objectForKey:@"width"];
        if (sWidth)fWidth = sWidth.floatValue;
        if ([[oneFiled objectForKey:@"fieldType"] isEqualToString:@"text"]) {
            UITextField *textField = [[UITextField alloc] initWithFrame:
                                      CGRectMake(fLeft, yOffset, fWidth, 25)];
            textField.clearsOnBeginEditing = NO;
            [textField setBorderStyle:UITextBorderStyleRoundedRect];
            if([[oneFiled objectForKey:@"checkChanging"] isEqualToString:@"1"])
                [textField addTarget:self action:@selector(checkTextChanged:) forControlEvents:UIControlEventEditingChanged];
            textField.tag = rowTag;
            textField.font = [UIFont systemFontOfSize:14.0];
            textField.text = [_formValues objectForKey:[NSNumber numberWithInteger:rowTag]];
            if([[oneFiled objectForKey:@"borderStyle"] isEqualToString:@"1"]) textField.borderStyle = UITextBorderStyleNone;
            
            if([[oneFiled objectForKey:@"isLast"] isEqualToString:@"1"])[textField setReturnKeyType:UIReturnKeyDone];
            else [textField setReturnKeyType:UIReturnKeyNext];
            
            if(([[oneFiled objectForKey:@"isNumber"] isEqualToString:@"1"]) || ([[oneFiled objectForKey:@"isMobile"] isEqualToString:@"1"]))[textField setKeyboardType:UIKeyboardTypeNumberPad];
            
            if([[oneFiled objectForKey:@"isEmail"] isEqualToString:@"1"])[textField setKeyboardType:UIKeyboardTypeEmailAddress];
            
            if([[oneFiled objectForKey:@"isPasswd"] isEqualToString:@"1"])[textField setSecureTextEntry:YES];
            
            [textField setPlaceholder:[oneFiled objectForKey:@"placeholder"]];
            
            [cell.contentView addSubview:textField];
            [self addInput:textField sequence:rowTag name:[oneFiled objectForKey:@"postName"]];
        }
        else if ([[oneFiled objectForKey:@"fieldType"] isEqualToString:@"label"]) {
            UILabel *labelField = [[UILabel alloc] initWithFrame:
                                   CGRectMake(fLeft, yOffset, 150, 25)];
            labelField.textAlignment = NSTextAlignmentLeft;
            labelField.font = [UIFont systemFontOfSize:14];
            labelField.backgroundColor = [UIColor clearColor];
            labelField.tag = rowTag;
            labelField.text = [self getFormValueWithTag:rowTag];
            [cell.contentView addSubview:labelField];
            [self addInput:labelField sequence:rowTag name:[oneFiled objectForKey:@"postName"]];
        }
        else if ([[oneFiled objectForKey:@"fieldType"] isEqualToString:@"sex"]) {
            DCRoundSwitch *switchField = [[DCRoundSwitch alloc] initWithFrame:CGRectMake(fLeft, yOffset, 80, 25)];
            switchField.tag = rowTag;
            switchField.onTintColor = [UIColor orangeColor];
            switchField.offTintColor = [UIColor orangeColor];
            switchField.offTextWithOnColor = YES;
            switchField.onText = @"男";
            switchField.offText = @"女";
            switchField.on = YES;
            if ([oneFiled objectForKey:@"switchOn"]) {
                _switchOnValue = [oneFiled objectForKey:@"switchOn"];
            }
            if ([oneFiled objectForKey:@"switchOff"]) {
                _switchOffValue = [oneFiled objectForKey:@"switchOff"];
            }
            [cell.contentView addSubview:switchField];
            [self addInput:switchField sequence:rowTag name:[oneFiled objectForKey:@"postName"]];
        } else if ([[oneFiled objectForKey:@"fieldType"] isEqualToString:@"textview"]){
            if (rowHeight < 50) rowHeight = 70;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(fLeft, 10, fWidth, rowHeight - 20)];
            textView.layer.borderColor = [UIColor grayColor].CGColor;
            textView.layer.borderWidth = 1.0f;
            textView.layer.cornerRadius = 6.0;
            textView.text = [self getFormValueWithTag:rowTag];
            textView.tag = rowTag;
            [cell.contentView addSubview:textView];
            [self addInput:textView sequence:rowTag name:[oneFiled objectForKey:@"postName"]];
            
        }
        
        if ([[oneFiled objectForKey:@"extView"] isEqualToString:@"smsVerify"]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            button.frame = CGRectMake(fLeft + fWidth + 10, yOffset, 90,
                                      25);
            [button setTitle:@"获取验证码" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(smsVerifyTapped:)
             forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
        }
        
        // 计量单位
        NSString *countUnit = [oneFiled objectForKey:@"countUnit"];
        if (countUnit) {
            UILabel *unitField = [[UILabel alloc] initWithFrame:
                                  CGRectMake(fLeft + fWidth + 10, yOffset, 90, 25)];
            unitField.textAlignment = NSTextAlignmentLeft;
            unitField.font = [UIFont systemFontOfSize:14];
            unitField.backgroundColor = [UIColor clearColor];
            unitField.text = countUnit;
            [cell.contentView addSubview:unitField];
        }
        
        if ([[oneFiled objectForKey:@"needSelect"] isEqualToString:@"1"]) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}

#pragma mark getValueDelegate Delegate Methods
- (void)getValueFromInputCtrl:(HMInputCtrl *)sender
{
    id ctrl = sender.input;
    if ([ctrl isKindOfClass:[DCRoundSwitch class]]) {
        DCRoundSwitch *f = ctrl;
        if(f.on)sender.value = _switchOnValue;
        else sender.value = _switchOffValue;
        [self setFormValue:sender.value tag:f.tag];
    }
}


@end
