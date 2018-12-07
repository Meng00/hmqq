//
//  HMPointsExchangeCell.h
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMNetImageView.h"
@interface HMPointsRecordCell : UITableViewCell

@property (strong, nonatomic) IBOutlet HMNetImageView *productImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;
@property (strong, nonatomic) IBOutlet UILabel *exchangeTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@end
