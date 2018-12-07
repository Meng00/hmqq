//
//  HMArtistCell.h
//  hmArt
//
//  Created by wangyong on 13-7-10.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMNetImageView.h"
@interface HMArtistCell : UITableViewCell

@property (strong, nonatomic) IBOutlet HMNetImageView *portraitImage;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *birthLabel;
@property (strong, nonatomic) IBOutlet UILabel *hometownLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *levelImages;

- (void)setLevel:(NSInteger)level;

@end
