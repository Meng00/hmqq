//
//  LCViewVaule.h
//  lifeassistant
//
//  Created by 刘学 on 14-6-16.
//
//

#import <Foundation/Foundation.h>

@interface LCViewVaule : NSObject

@property(strong ,nonatomic) UIView *view;

@property(nonatomic) float interval;
@property(nonatomic) float maxShowWidth;
@property(nonatomic) float minShowWidth;
@property(nonatomic) float maxShowHeight;
@property(nonatomic) float minShowHeight;
@property(nonatomic, strong) UIFont *font;

-(id) initViewValue:(UIView *)_view interval:(float)_interval;
-(id) initViewValue:(UIView *)_view interval:(float)_interval textMaxShowWidth:(float)_maxShowWidth textMinShowWidth:(float)_minShowWidth textMaxShowHeight:(float)_maxShowHeight textMinShowHeight:(float)_minShowHeight font:(UIFont *)_font;

@end
