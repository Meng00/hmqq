//
//  HMImageZoomView.m
//  hmArt
//
//  Created by wangyong on 14-9-12.
//  Copyright (c) 2014年 hanmoqianqiu. All rights reserved.
//

#import "HMImageZoomView.h"

@implementation HMImageZoomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        self.minimumZoomScale = 1.0;
        
        imgView = [[UIImageView alloc] init];
        imgView.clipsToBounds = YES;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
//        imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imgView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) setContentWithFrame:(CGRect) rect
{
    imgView.frame = rect;
    initRect = rect;
}

- (void) setAnimationRect
{
    imgView.frame = scaleOriginRect;
}

- (void) rechangeInitRdct
{
    self.zoomScale = 1.0;
    imgView.frame = initRect;
}

- (void) setImage:(UIImage *) image
{
    if (image)
    {
        imgView.image = image;
        imgSize = image.size;
        
        //判断首先缩放的值
        float scaleX = self.frame.size.width/imgSize.width;
        float scaleY = self.frame.size.height/imgSize.height;
        
        //倍数小的，先到边缘
        
        if (scaleX > scaleY)
        {
            //Y方向先到边缘
            float imgViewWidth = imgSize.width*scaleY;
            self.maximumZoomScale = self.frame.size.width/imgViewWidth;
            
            scaleOriginRect = (CGRect){self.frame.size.width/2-imgViewWidth/2,0,imgViewWidth,self.frame.size.height};
        }
        else
        {
            //X先到边缘
            float imgViewHeight = imgSize.height*scaleX;
            self.maximumZoomScale = self.frame.size.height/imgViewHeight;
            
            scaleOriginRect = (CGRect){0,self.frame.size.height/2-imgViewHeight/2,self.frame.size.width,imgViewHeight};
        }
    }
}

#pragma mark -
#pragma mark - scroll delegate
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    CGSize boundsSize = scrollView.bounds.size;
    CGRect imgFrame = imgView.frame;
    CGSize contentSize = scrollView.contentSize;
    
    CGPoint centerPoint = CGPointMake(contentSize.width/2, contentSize.height/2);
    
    // center horizontally
    if (imgFrame.size.width <= boundsSize.width)
    {
        centerPoint.x = boundsSize.width/2;
    }
    
    // center vertically
    if (imgFrame.size.height <= boundsSize.height)
    {
        centerPoint.y = boundsSize.height/2;
    }
    
    imgView.center = centerPoint;
}

#pragma mark -
#pragma mark - touch
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([imgView isAnimating]) {
        [imgView stopAnimating];
        imgView.animationImages = nil;
    }
    if ([self.zoomDelegate respondsToSelector:@selector(imageTapedWithObject:)])
    {
        [self.zoomDelegate imageTapedWithObject:self];
    }
}

#pragma mark -
#pragma mark load image with url
- (void) startLoadImage
{
    CGSize boundsSize = self.bounds.size;
    CGRect imgFrame = imgView.frame;

    imgFrame.origin.x = (boundsSize.width - 30) / 2;
    imgFrame.origin.y = (boundsSize.height - 30) / 2;
    imgFrame.size.width = 30;
    imgFrame.size.height = 30;
    imgView.frame = imgFrame;
    
    imgView.animationImages = [NSArray arrayWithObjects:
                               [UIImage imageNamed:@"loading_1.png"],
                               [UIImage imageNamed:@"loading_2.png"],
                               [UIImage imageNamed:@"loading_3.png"],
                               [UIImage imageNamed:@"loading_4.png"],
                               [UIImage imageNamed:@"loading_5.png"],
                               [UIImage imageNamed:@"loading_6.png"],
                               [UIImage imageNamed:@"loading_7.png"],
                               [UIImage imageNamed:@"loading_8.png"],
                               nil];
    imgView.animationDuration = 0.8;
    imgView.animationRepeatCount = 0;
    [imgView startAnimating];
    

}

- (void)stopLoadImage
{
    [imgView stopAnimating];
    imgView.animationImages = nil;
}


@end
