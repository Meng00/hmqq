//
//  HMArtistInfo.m
//  hmArt
//
//  Created by wangyong on 13-7-11.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMArtistDetail.h"
#import "HMUtility.h"
#import "HMGlobal.h"
#import "HMArtistInfoList.h"
#import "HMPictureList.h"
#import "HMPriceTrend.h"
#import "HMArtistPrice.h"

@interface HMArtistDetail ()

@end

@implementation HMArtistDetail

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
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"view_bg.png"]];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];

    CGRect rect = _scrollView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - HM_SYS_VIEW_OFFSET;
    _scrollView.frame = rect;
    [_scrollView setContentSize:CGSizeMake(rect.size.width, 390)];

    _artistInfo = [[NSMutableDictionary alloc] init];
    [self query];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setPortraitImage:nil];
    [self setNameLabel:nil];
    [self setBirthLabel:nil];
    [self setHometownLabel:nil];
    [self setStarlevelImages:nil];
    [self setResumeLabel:nil];
    [self setButtonView:nil];
    [self setActivity:nil];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_requestId != 0) {
        [[LCNetworkInterface sharedInstance] cancelRequest:_requestId];
    }
    
    [super viewWillDisappear:animated];
}

- (void)setParams:(NSString *)params
{
    NSDictionary *dicParam = [HMUtility parametersWithSeparator:@"=" delimiter:@"&" url:params];
    _artistId =[[dicParam objectForKey:@"id"] integerValue];
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 1];    
    [queryParam setValue:[NSNumber numberWithInteger:_artistId] forKey:@"id"];
    _requestId = [net asynRequest:interfaceArtistDetail with:queryParam needSSL:NO target:self action:@selector(dealDetail:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealDetail:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == HM_NET_INTERFACE_SUCCESS) {
        NSDictionary *artist = [result.value objectForKey:@"obj"];
        [_artistInfo setObject:[artist objectForKey:@"name"] forKey:@"name"];
        [_artistInfo setObject:[artist objectForKey:@"birthDate"] forKey:@"birthDate"];
        [_artistInfo setObject:[artist objectForKey:@"nativePlace"] forKey:@"nativePlace"];
        [_artistInfo setObject:[artist objectForKey:@"creditRating"] forKey:@"creditRating"];
        NSString *photo = [HMUtility getString:[artist objectForKey:@"photos"]];
        [_artistInfo setObject:photo forKey:@"photos"];
        [_artistInfo setObject:[artist objectForKey:@"id"] forKey:@"id"];
        
        _resume = [artist objectForKey:@"resumeExplain"];//简历
        [self reLayoutConent];
    }
}

- (void)reLayoutConent
{
    _nameLabel.text =[HMUtility getString:[_artistInfo objectForKey:@"name"]];
    self.title =  _nameLabel.text;
    _birthLabel.text = [HMUtility getString:[_artistInfo objectForKey:@"birthDate"]];
    _hometownLabel.text = [HMUtility getString:[_artistInfo objectForKey:@"nativePlace"]];
    [self setLevel:[[_artistInfo objectForKey:@"creditRating"] integerValue]];
    NSString *image = [HMUtility getString:[_artistInfo objectForKey:@"photos"]];
    if (image.length > 0) {
        _portraitImage.imageUrl = [NSString stringWithFormat:@"%@%@", HM_SYS_IMGSRV_PREFIX, image];
        [_portraitImage load];
    }

    
    NSString *s = [HMUtility getString:_resume];
    _resumeLabel.text = s;
    _resumeLabel.numberOfLines = 0;
    _resumeLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    [_resumeLabel sizeToFit];
    CGRect rect = _resumeLabel.frame;
    if (rect.size.height > 105.0) {
        _resumeLabel.numberOfLines = 5;
        _icons.hidden = NO;
        rect.size.height = 105.0;
        [_resumeLabel sizeToFit];
        _resumeLabel.frame = rect;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResume:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        _resumeLabel.userInteractionEnabled = YES;
        [_resumeLabel addGestureRecognizer:tap];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapResume:)];
        tap1.numberOfTapsRequired = 1;
        tap1.numberOfTouchesRequired = 1;
        _icons.userInteractionEnabled = YES;
        [_icons addGestureRecognizer:tap1];
    }
    
    _scrollView.contentSize = CGSizeMake(320, 360 + rect.size.height);
    
    CGRect rectView = _buttonView.frame;
    rectView.origin.y = rect.origin.y + rect.size.height + 10;
    _buttonView.frame = rectView;
        
}

- (void)tapResume:(UITapGestureRecognizer *)recognizer
{
    NSString *s = [HMUtility getString:_resume];
    _resumeLabel.text = s;
    _resumeLabel.numberOfLines = 0;
    _resumeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [_resumeLabel sizeToFit];
     _icons.hidden = YES;
    CGRect rect = _resumeLabel.frame;
    _resumeLabel.userInteractionEnabled = NO;
    _scrollView.contentSize = CGSizeMake(320, 360 + rect.size.height);
    
    CGRect rectView = _buttonView.frame;
    rectView.origin.y = rect.origin.y + rect.size.height + 10;
    _buttonView.frame = rectView;
    
}

- (void)setLevel:(NSInteger)level
{
    for (int i = 0; i < self.starlevelImages.count; i++) {
        UIImageView *imgView = [self.starlevelImages objectAtIndex:i];
        if (i < level) {
            imgView.image = [UIImage imageNamed:@"star.png"];
        }else{
            imgView.image = [UIImage imageNamed:@"star_gray.png"];
        }
    }
}

- (IBAction)infoButtonDown:(UIButton *)sender {
    HMArtistInfoList *infoList = [[HMArtistInfoList alloc] initWithNibName:nil bundle:nil];
    infoList.infoType = sender.tag;
    infoList.artistName = _nameLabel.text;
    infoList.artistId = [[_artistInfo objectForKey:@"id"] integerValue];
    [self.navigationController pushViewController:infoList animated:YES];
}

- (IBAction)pictureButtonDown:(UIButton *)sender {
    NSInteger picType = sender.tag;
    HMPictureList *picList = [[HMPictureList alloc] initWithNibName:nil bundle:nil];
    picList.pictureType = picType;
    picList.artistId = [[_artistInfo objectForKey:@"id"] integerValue];
    [self.navigationController pushViewController:picList animated:YES];
}

- (IBAction)priceButtonDown:(id)sender {
    //HMPriceTrend *price = [[HMPriceTrend alloc] initWithNibName:nil bundle:nil];
    HMArtistPrice *price = [[HMArtistPrice alloc] initWithNibName:nil bundle:nil];
    price.artistId = [[_artistInfo objectForKey:@"id"] integerValue];
    [self.navigationController pushViewController:price animated:YES];
}


@end
