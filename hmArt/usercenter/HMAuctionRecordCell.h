//
//  HMAuctionRecordCell.h
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMNetImageView.h"
@interface HMAuctionRecordCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *exchangeTimeLabel;
@property (strong, nonatomic) IBOutlet HMNetImageView *auditImage;
@property (strong, nonatomic) IBOutlet UILabel *authorLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *codeLabel;
@end
