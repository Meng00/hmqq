//
//  LCView.h
//  lifeassistant
//
//  Created by liuxue on 13-8-22.
//
//

#import <UIKit/UIKit.h>
#import "HMUtility.h"
#import "LCViewVaule.h"

@interface LCView : UIView
{
    
}

@property(strong, nonatomic) NSMutableArray *_itemArray;
@property(strong, nonatomic) NSMutableArray *_itemArray2;

@property(nonatomic) float _paddingLeft;
@property(nonatomic) float _paddingRight;
@property(nonatomic) float _paddingTop;
@property(nonatomic) float _paddingBottom;


/**
 *设置view 内边距
 **/
-(void)setPaddingTop:(float)top paddingBottom:(float)bottom paddingLeft:(float)left paddingRight:(float)right;

-(void)addCustomSubview:(UIView *)view intervalTop:(float)_interval;
-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval;
-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval font:(UIFont *)_font;
-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval textMaxShowWidth:(float)_maxShowWidth;
-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMaxShowHeight:(float)_maxShowHeight;
-(void)addCustomSublabel:(UILabel *)label intervalTop:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMaxShowHeight:(float)_maxShowHeight font:(UIFont *)_font;

-(void)addCustomSubview:(UIView *)view intervalLeft:(float)_interval;
-(void)addCustomSublabel:(UILabel *)label intervalLeft:(float)_interval;
-(void)addCustomSublabel:(UILabel *)label intervalLeft:(float)_interval font:(UIFont *)_font;
-(void)addCustomSublabel:(UILabel *)label intervalLeft:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMaxShowHeight:(float)_maxShowHeight;
-(void)addCustomSublabel:(UILabel *)label intervalLeft:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMaxShowHeight:(float)_minHeight font:(UIFont *)_font;

//-(void)resetHeight;
-(void)resize;
-(void)clearUp;

@end
