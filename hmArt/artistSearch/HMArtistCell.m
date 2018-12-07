//
//  HMArtistCell.m
//  hmArt
//
//  Created by wangyong on 13-7-10.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMArtistCell.h"

@implementation HMArtistCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setLevel:(NSInteger)level
{
    for (int i = 0; i < self.levelImages.count; i++) {
        UIImageView *imgView = [self.levelImages objectAtIndex:i];
        if (i < level) {
            imgView.image = [UIImage imageNamed:@"star.png"];
        }else{
            imgView.image = [UIImage imageNamed:@"star_gray.png"];
        }
    }
}
@end
