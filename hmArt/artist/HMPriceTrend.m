//
//  HMPriceTrend.m
//  hmArt
//
//  Created by wangyong on 13-7-26.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMPriceTrend.h"
#import "HMPriceChart.h"

@interface HMPriceTrend ()

@end

@implementation HMPriceTrend

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
    self.title = @"价格走势";
    _resultArray = [[NSMutableArray alloc] initWithCapacity:1];
    _valueArray = [[NSMutableArray alloc] initWithCapacity:1];
    _hArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self query];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [self setActivity:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark query methods
- (void)query
{
    LCNetworkInterface * net = [LCNetworkInterface sharedInstance];
    
    if (_requestId != 0) {
        [net cancelRequest:_requestId];
    }
    
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] initWithCapacity: 3];
    [queryParam setValue:[NSNumber numberWithInteger:1] forKey:@"pageIndex"];
    [queryParam setValue:[NSNumber numberWithInteger:50] forKey:@"pageSize"];
    [queryParam setValue:[NSNumber numberWithInteger:_artistId] forKey:@"backUserId"];
    [queryParam setValue:[NSNumber numberWithInteger:2] forKey:@"type"];    //已售作品
    [queryParam setValue:[NSNumber numberWithInteger:2] forKey:@"status"];    //审核通过
    _requestId = [net asynRequest:interfacePriceTrend with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
   
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealPictures:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == 0) {
        NSDictionary *ret = result.value;
        NSLog(@"%@", ret);
        [_resultArray removeAllObjects];
        
        NSArray *pictures = [ret objectForKey:@"data"];
        for (unsigned int i = 0; i < pictures.count; ++i) {
            [_resultArray addObject:[pictures objectAtIndex:i]];
        }
        [self dealPicturesData];
    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
    }
}

- (void)dealPicturesData
{
    [_valueArray removeAllObjects];
    [_hArray removeAllObjects];
    CGFloat min = 0.0f;
    CGFloat max = 0.0f;
    _totalCount = _resultArray.count;
    CGFloat tmpPrice;
    for (int i = 0; i < _totalCount; i++) {
        NSDictionary *item = [_resultArray objectAtIndex:i];
        tmpPrice = [[item objectForKey:@"priceOfSquarefoot"] floatValue];
        if(i==0){
            min = tmpPrice;
            max = tmpPrice;
        }else{
            if (tmpPrice < min) min = tmpPrice;
            if (tmpPrice > max) max = tmpPrice;
        }
        [_valueArray addObject:[NSNumber numberWithInteger:lround(tmpPrice)]];
        [_hArray addObject:[item objectForKey:@"sellDate"]];
    }
    if (_totalCount > 0) {
        long rangeLow = lround(min);
        long rangeHigh = lround(max);
        CGRect rect = _scrollView.frame;
        CGFloat width = (_totalCount + 1) * 50.0;
        if (width > [[UIScreen mainScreen] applicationFrame].size.width) {
            rect.size.width = width;
        }else
            rect.size.width = [[UIScreen mainScreen] applicationFrame].size.width;
        
        HMPriceChart *chart = [[HMPriceChart alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
        chart.rangeHi = rangeHigh;
        chart.rangeLo = rangeLow;
        chart.hDesc = _hArray;
        chart.array = _valueArray;
        [_scrollView addSubview:chart];
        _scrollView.contentSize = rect.size;
        
    }
}
@end
