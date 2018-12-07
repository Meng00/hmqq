//
//  LCTapToCloseView.h
//  uni114
//
//  Created by Administrator on 12-12-2.
//
//

#import <UIKit/UIKit.h>

@interface LCTapToCloseView : UIView

@property (nonatomic, strong) id target;

@property (nonatomic, unsafe_unretained) SEL action;

@end
