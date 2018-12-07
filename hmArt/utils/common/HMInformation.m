//
//  HMInformation.m
//  hmArt
//
//  Created by wangyong on 13-7-8.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMInformation.h"
#import "HMUtility.h"

@interface HMInformation ()

@end

@implementation HMInformation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    self = [super initWithNibName:nil  bundle:nil];
    if (self) {
        // Custom initialization
        self.title = title;
        _showListButton = NO;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    
    [self layoutInformation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark layout information
- (void)layoutInformation
{
    CGFloat spaceY = 5.0;
    CGFloat offsetY = 0.0;
    switch (_infoType) {
        case kInfoTypeNews:
        {
            if (_showListButton) {
                // 右侧按钮
                UIBarButtonItem *rightButton =  [[UIBarButtonItem alloc] initWithTitle:@"列表" style:UIBarButtonItemStyleDone target:self action:@selector(newsListDown:)];
                
                self.navigationItem.rightBarButtonItem = rightButton;
            }
            
            if (!_infoDictionary) {
                return;
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 26.0)];
            label.backgroundColor= [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:16.0];
            label.text = [_infoDictionary objectForKey:@"title"];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            [label sizeToFit];
            [_scrollView addSubview:label];
            CGRect rect = label.frame;
            offsetY += (rect.size.height + spaceY);
            NSString *subTitle = [HMUtility getString:[_infoDictionary objectForKey:@"subTitle"]];
            if (subTitle.length > 0) {
                UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, offsetY, 300.0, 21.0)];
                subTitleLabel.backgroundColor= [UIColor clearColor];
                subTitleLabel.textAlignment = NSTextAlignmentRight;
                subTitleLabel.font = [UIFont systemFontOfSize:13.0];
                subTitleLabel.numberOfLines = 0;
                subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                subTitleLabel.text = [NSString stringWithFormat:@"-%@", subTitle];
                [subTitleLabel sizeToFit];
                [_scrollView addSubview:subTitleLabel];
                rect = subTitleLabel.frame;
                offsetY += (rect.size.height + spaceY);
             }
            
        }
            break;
        case kInfoTypeActivity:
        {
            
            if (!_infoDictionary) {
                return;
            }
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 26.0)];
            nameLabel.backgroundColor= [UIColor clearColor];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.font = [UIFont boldSystemFontOfSize:16.0];
            nameLabel.adjustsFontSizeToFitWidth = YES;
            nameLabel.text = [NSString stringWithFormat:@"%@", [_infoDictionary objectForKey:@"name"]];
            [_scrollView addSubview:nameLabel];
            offsetY += (26.0 + spaceY);
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 26.0)];
            label.backgroundColor= [UIColor clearColor];
            label.textAlignment = NSTextAlignmentLeft;
            label.font = [UIFont boldSystemFontOfSize:14.0];
            label.text = [NSString stringWithFormat:@"活动时间:%@", [_infoDictionary objectForKey:@"activityDate"]];
            [_scrollView addSubview:label];
            offsetY += (26.0 + spaceY);
            NSString *subTitle = [HMUtility getString:[_infoDictionary objectForKey:@"describes"]];
            if (subTitle.length > 0) {
                UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 21.0)];
                subTitleLabel.backgroundColor= [UIColor clearColor];
                subTitleLabel.textAlignment = NSTextAlignmentLeft;
                subTitleLabel.font = [UIFont systemFontOfSize:14.0];
                subTitleLabel.numberOfLines = 0;
                subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                subTitleLabel.text = [NSString stringWithFormat:@"%@", subTitle];
                [subTitleLabel sizeToFit];
                [_scrollView addSubview:subTitleLabel];
                CGRect rect = subTitleLabel.frame;
                offsetY += (rect.size.height + spaceY);
            }
            
        }
            break;
        case kInfoTypePublish:
        {
            
            if (!_infoDictionary) {
                return;
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 26.0)];
            label.backgroundColor= [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:16.0];
            label.adjustsFontSizeToFitWidth = YES;
            label.text = [NSString stringWithFormat:@"%@", [_infoDictionary objectForKey:@"name"]];
            [_scrollView addSubview:label];
            offsetY += (26.0 + spaceY);
            UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 21.0)];
            numLabel.backgroundColor= [UIColor clearColor];
            numLabel.textAlignment = NSTextAlignmentLeft;
            numLabel.font = [UIFont systemFontOfSize:14.0];
            numLabel.text = [NSString stringWithFormat:@"出版号:%@", [HMUtility getString:[_infoDictionary objectForKey:@"publishNum"]]];
            [_scrollView addSubview:numLabel];
            offsetY += (26.0 + spaceY);
            
            NSString *subTitle = [HMUtility getString:[_infoDictionary objectForKey:@"describes"]];
            if (subTitle.length > 0) {
                UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 21.0)];
                subTitleLabel.backgroundColor= [UIColor clearColor];
                subTitleLabel.textAlignment = NSTextAlignmentLeft;
                subTitleLabel.font = [UIFont systemFontOfSize:14.0];
                subTitleLabel.numberOfLines = 0;
                subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                subTitleLabel.text = [NSString stringWithFormat:@"%@", subTitle];
                [subTitleLabel sizeToFit];
                [_scrollView addSubview:subTitleLabel];
                CGRect rect = subTitleLabel.frame;
                offsetY += (rect.size.height + spaceY);
            }
            
        }
            break;
        case kInfoTypePrize:
        {
            
            if (!_infoDictionary) {
                return;
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 26.0)];
            label.backgroundColor= [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:16.0];
            label.adjustsFontSizeToFitWidth = YES;
            label.text = [NSString stringWithFormat:@"%@", [_infoDictionary objectForKey:@"name"]];
            [_scrollView addSubview:label];
            offsetY += (26.0 + spaceY);
            UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 21.0)];
            numLabel.backgroundColor= [UIColor clearColor];
            numLabel.textAlignment = NSTextAlignmentLeft;
            numLabel.font = [UIFont boldSystemFontOfSize:14.0];
            numLabel.text = [NSString stringWithFormat:@"获奖时间:%@", [HMUtility getString:[_infoDictionary objectForKey:@"gainDate"]]];
            [_scrollView addSubview:numLabel];
            offsetY += (21.0 + spaceY);
            
            NSString *subTitle = [HMUtility getString:[_infoDictionary objectForKey:@"describes"]];
            if (subTitle.length > 0) {
                UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 21.0)];
                subTitleLabel.backgroundColor= [UIColor clearColor];
                subTitleLabel.textAlignment = NSTextAlignmentLeft;
                subTitleLabel.font = [UIFont systemFontOfSize:14.0];
                subTitleLabel.numberOfLines = 0;
                subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                subTitleLabel.text = [NSString stringWithFormat:@"描述:%@", subTitle];
                [subTitleLabel sizeToFit];
                [_scrollView addSubview:subTitleLabel];
                CGRect rect = subTitleLabel.frame;
                offsetY += (rect.size.height + spaceY);
            }
            
        }
            break;
            
        case kInfoTypeExhibition:
        {
            
            if (!_infoDictionary) {
                return;
            }
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 26.0)];
            label.backgroundColor= [UIColor clearColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:16.0];
            label.adjustsFontSizeToFitWidth = YES;
            label.text = [NSString stringWithFormat:@"%@", [_infoDictionary objectForKey:@"name"]];
            [_scrollView addSubview:label];
            offsetY += (26.0 + spaceY);
            UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 21.0)];
            numLabel.backgroundColor= [UIColor clearColor];
            numLabel.textAlignment = NSTextAlignmentLeft;
            numLabel.font = [UIFont boldSystemFontOfSize:14.0];
            numLabel.adjustsFontSizeToFitWidth = YES;
            numLabel.text = [NSString stringWithFormat:@"展览时间:%@", [HMUtility getString:[_infoDictionary objectForKey:@"gainDate"]]];
            [_scrollView addSubview:numLabel];
            offsetY += (26.0 + spaceY);
            UILabel *siteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 21.0)];
            siteLabel.backgroundColor= [UIColor clearColor];
            siteLabel.textAlignment = NSTextAlignmentLeft;
            siteLabel.font = [UIFont boldSystemFontOfSize:14.0];
            siteLabel.adjustsFontSizeToFitWidth = YES;
            siteLabel.text = [NSString stringWithFormat:@"展览地点:%@", [HMUtility getString:[_infoDictionary objectForKey:@"site"]]];
            [_scrollView addSubview:siteLabel];
            offsetY += (21.0 + spaceY);
            
            NSString *subTitle = [HMUtility getString:[_infoDictionary objectForKey:@"describes"]];
            if (subTitle.length > 0) {
                UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300.0, 21.0)];
                subTitleLabel.backgroundColor= [UIColor clearColor];
                subTitleLabel.textAlignment = NSTextAlignmentLeft;
                subTitleLabel.font = [UIFont systemFontOfSize:14.0];
                subTitleLabel.numberOfLines = 0;
                subTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                subTitleLabel.text = [NSString stringWithFormat:@"%@", subTitle];
                [subTitleLabel sizeToFit];
                [_scrollView addSubview:subTitleLabel];
                CGRect rect = subTitleLabel.frame;
                offsetY += (rect.size.height + spaceY);
            }
            
        }
            break;
           
        default:
            break;
    }
    
    if (!_framesArray) {
        return;
    }
    
    //处理内容帧
    for (int i = 0; i < _framesArray.count; i++) {
        NSDictionary *frameDic = [_framesArray objectAtIndex:i];
        NSString *imageUrl = [frameDic objectForKey:@"image"];
        if (imageUrl.length > 0) {
            HMNetImageView *iv = [[HMNetImageView alloc]initWithFrame:CGRectMake(0.0, offsetY, 320, 180)];
            iv.image = [UIImage imageNamed:@"holder_320_180.png"];
            iv.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, imageUrl];
            iv.contentMode = UIViewContentModeScaleAspectFit;
            iv.backgroundColor = [UIColor clearColor];
            [iv load];
            [_scrollView addSubview:iv];
            offsetY += (180 + spaceY);
        }
        NSString *content = [frameDic objectForKey:@"content"];
        if (content.length > 0) {
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, offsetY, 300, 21)];
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
            contentLabel.numberOfLines = 0;
            contentLabel.textAlignment = NSTextAlignmentLeft;
            contentLabel.font = [UIFont systemFontOfSize:14.0];
            contentLabel.text = content;
            [contentLabel sizeToFit];
            [_scrollView addSubview:contentLabel];
            CGRect rectLabel = contentLabel.frame;
             offsetY += (rectLabel.size.height + spaceY);
        }
    }
    [_scrollView setContentSize:CGSizeMake(320, offsetY + 30)];
}

@end
