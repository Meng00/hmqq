//
//  HMPointsExchangeCell.m
//  hmArt
//
//  Created by wangyong on 14-8-14.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMPointsRecordCell.h"

@implementation HMPointsRecordCell

- (void)awakeFromNib
{
    // Initialization code
    self.contentView.layer.borderWidth = 1.0;
    self.contentView.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end