//
//  HMArtistPrice.m
//  hmArt
//
//  Created by wangyong on 13-8-13.
//  Copyright (c) 2013年 hanmoqianqiu. All rights reserved.
//

#import "HMArtistPrice.h"


@interface HMArtistPrice ()

@end

@implementation HMArtistPrice

CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize aaplPlot = applPlot;

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
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
    
    self.title = @"价格走势";
    CGRect rect = _hostView.frame;
    rect.size.height = [[UIScreen mainScreen] applicationFrame].size.height - rect.origin.y - HM_SYS_VIEW_OFFSET;
    _hostView.frame = rect;
    
    _resultArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self query];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setActivity:nil];
    [self setHostView:nil];
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
    
    [queryParam setValue:[NSNumber numberWithInteger:_artistId] forKey:@"artistId"];
   
    _requestId = [net asynRequest:interfacePriceTrend with:queryParam needSSL:NO target:self action:@selector(dealPictures:result:)];
    
    [_activity startAnimating];
    [HMUtility showModalViewOnTransparentBase:_activity baseView:self.view clickBackgroundToClose:NO];
    
}

- (void)dealPictures:(NSString *)serviceName result:(LCInterfaceResult *)result
{
    [_activity stopAnimating];
    [HMUtility dismissModalView:_activity];
    _requestId = 0;
    
    if (result.result == 1) {
        NSDictionary *ret = [result.value objectForKey:@"obj"];
        NSLog(@"%@", ret);
        [_resultArray removeAllObjects];
        
        if ([[ret objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
            _minPrice = 0;
            _maxPrice = 0;
            [self initPlot];
            return;
        }
        NSArray *pictures = [ret objectForKey:@"data"];
        if (!pictures || pictures.count == 0) {
            _minPrice = 0;
            _maxPrice = 0;
            [self initPlot];
            return;
        }
        for (unsigned int i = 0; i < pictures.count; ++i) {
            NSDictionary *item = [pictures objectAtIndex:i];
            NSInteger price = [[item objectForKey:@"price"] integerValue];
            [_resultArray addObject:[NSNumber numberWithInteger:price]];
            if (i==0) {
                _minPrice = price;
                _maxPrice = price;
            }else{
                if (price < _minPrice) {
                    _minPrice = price;
                }
                if (price > _maxPrice) {
                    _maxPrice = price;
                }
            }
        }
        if (_minPrice == _maxPrice) {
            _minPrice -= 300;
            _maxPrice += 300;
        }else if (_maxPrice / _minPrice < 10){
            _minPrice = [self getMinLevel:_minPrice isFloor:YES];
            _maxPrice = [self getMinLevel:_maxPrice isFloor:NO];
            NSLog(@"min:max：%ld---%ld", (long)_minPrice, (long)_maxPrice);
        }
        [self initPlot];

    } else {
        [HMUtility alert:@"下载失败!" title:@"提示"];
        [HMUtility tap2Action:@"重新加载" on:self.view target:self action:@selector(query)];
    }
}

#pragma mark - Chart behavior
-(void)initPlot {
    self.hostView.allowPinchScaling = NO;
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
}

-(void)configureHost
{
    self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:_hostView.bounds];
    self.hostView.allowPinchScaling = YES;
    [self.view addSubview:self.hostView];
    
}

-(void)configureGraph {
    // 1 - Create the graph
    //CGRect rect = self.hostView.bounds;
    //rect.size.width = [_resultArray count] *
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    graph.plotAreaFrame.masksToBorder = NO;
    self.hostView.hostedGraph = graph;
    // 2 - Configure the graph
    [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
    graph.paddingBottom = 30.0f;
    graph.paddingLeft  = 30.0f;
    graph.paddingTop    = 5.0f;
    graph.paddingRight  = 5.0f;
    graph.plotAreaFrame.borderLineStyle=nil;
    graph.plotAreaFrame.cornerRadius=0.0f;// hide frame
    // 绘图区4边留白
    graph.plotAreaFrame.paddingTop=5.0;
    graph.plotAreaFrame.paddingRight=5.0;
    graph.plotAreaFrame.paddingLeft=5.0;
    graph.plotAreaFrame.paddingBottom=5.0;
    
    // 3 - Set up styles
    CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
    titleStyle.color = [CPTColor whiteColor];
    //titleStyle.fontName = @"Helvetica-Bold";
    titleStyle.fontSize = 16.0f;
    /*// 4 - Set up title
    NSString *title = @"价格走势";
    graph.title = title;
    graph.titleTextStyle = titleStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -16.0f);*/
    // 5 - Set up plot space
    CGFloat xMin = 0.5f;
    CGFloat xMax = [_resultArray count]+1;
    CGFloat yMin = 0;
    CGFloat yMax = 800;  // should determine dynamically based on max price
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
    // 1 - Set up the three plots
    self.aaplPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
    self.aaplPlot.identifier = @"APPL";
    // 2 - Set up line style
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineColor = [CPTColor lightGrayColor];
    barLineStyle.lineWidth = 0.5;
    // 3 - Add plots to graph
    CPTGraph *graph = self.hostView.hostedGraph;
    CGFloat barX = CPDBarInitialX;
    NSArray *plots = [NSArray arrayWithObjects:self.aaplPlot, nil];
    for (CPTBarPlot *plot in plots) {
        plot.dataSource = self;
        plot.delegate = self;
        plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
        //plot.barOffset = CPTDecimalFromDouble(barX);
        plot.lineStyle = barLineStyle;
        [graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
        barX += CPDBarWidth;
    }
}

-(void)configureAxes {
    // 1 - Configure styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 12.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 2.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor] ;
    // 2 - Get the graph's axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure the x-axis
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.title = @"成交记录";
    axisSet.xAxis.titleTextStyle = axisTitleStyle;
    axisSet.xAxis.titleOffset = 10.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    // 4 - Configure the y-axis
    
    axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.yAxis.title = @"价格:元/平方尺";
    axisSet.yAxis.titleTextStyle = axisTitleStyle;
    axisSet.yAxis.titleOffset = 5.0f;
    axisSet.yAxis.axisLineStyle = axisLineStyle;
    
    axisSet.yAxis.majorTickLineStyle=axisLineStyle; //X轴大刻度线，线型设置
    axisSet.yAxis.majorTickLength=10;  // 刻度线的长度
    axisSet.yAxis.majorIntervalLength=CPTDecimalFromInt(80); // 间隔单位，和yMin～yMax对应
    // 小刻度线minor...
    axisSet.yAxis.minorTickLineStyle=nil;  //  不显示小刻度线
    axisSet.yAxis.labelingPolicy=CPTAxisLabelingPolicyNone;
    axisSet.yAxis.axisConstraints=[CPTConstraints constraintWithLowerOffset:0.0];
    axisSet.yAxis.orthogonalCoordinateDecimal=CPTDecimalFromInt(0);
}


#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [_resultArray count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < [_resultArray count])) {
        if ([plot.identifier isEqual:@"APPL"]) {
            NSInteger price = [[_resultArray objectAtIndex:index] integerValue];
            NSNumber *np = [self getPosY: price];
            NSLog(@"%@--%@", [_resultArray objectAtIndex:index], np);
            
            return np;
        }
    }
    return [NSDecimalNumber numberWithUnsignedInteger:(index+1)];
}

- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    CPTMutableTextStyle *textLineStyle=[CPTMutableTextStyle textStyle];
    textLineStyle.fontSize=12;
    textLineStyle.color=[CPTColor whiteColor];
    CPTTextLayer *label=[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@", [_resultArray objectAtIndex:index]] style:textLineStyle];
    return label;
}

- (NSNumber *)getPosY:(NSInteger)price
{
    return [NSNumber numberWithFloat:((price-_minPrice)  * 700.0 / (_maxPrice - _minPrice) + 20)] ;
}

- (NSInteger)getMinLevel:(NSInteger)min isFloor:(BOOL)floor
{
    NSInteger k = 10;
    NSInteger i = min;
    NSInteger fac = 1;
    NSInteger s = i / k;
    while(!(s > 0 && s < 10))
    {
        fac *= 10;
        k*=10;
        s = i / k;
    }
    if (floor) {
        return s * fac * 10;
    }else{
        return (s+1) * fac * 10;
    }
    
}
@end
