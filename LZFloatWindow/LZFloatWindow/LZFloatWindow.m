//
//  LZFloatWindow.m
//  YayawanIosSDK
//
//  Created by lz on 2017/11/29.
//  Copyright © 2017年 mengwenlei. All rights reserved.
//

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define animateDuration 0.3
#define normalAlpha  0.8           //正常状态时背景alpha值
#define sleepAlpha  0.3           //隐藏到边缘时的背景alpha值
#define statusChangeDuration  3.0

#import "LZFloatWindow.h"
@interface LZFloatWindow()
@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic,strong) UIImageView *imageView;
@end

@implementation LZFloatWindow

-(instancetype)initWithFrame:(CGRect)frame mainImageName:(UIImage*)image{
    
    if (self = [super initWithFrame:frame]) {
        self.isKeepBounds = YES;
        
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelAlert + 2; //窗口等级最高
        self.rootViewController = [UIViewController new];
        self.backgroundColor = [UIColor clearColor];
        
        _imageView = [[UIImageView alloc]init];
        _imageView.userInteractionEnabled = YES;
        _imageView.image = image;
        _imageView.clipsToBounds = YES;
        _imageView.frame = (CGRect){CGPointZero,self.bounds.size};
        [self addSubview:_imageView];
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickDragView)];
        [self addGestureRecognizer:singleTap];
        
        //添加移动手势可以拖动
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragAction:)];
        self.panGestureRecognizer.minimumNumberOfTouches = 1;
        self.panGestureRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:self.panGestureRecognizer];
        [self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];

    }
    return self;
}


-(void)layoutSubviews{
    if (self.freeRect.origin.x!=0||self.freeRect.origin.y!=0||self.freeRect.size.height!=0||self.freeRect.size.width!=0) {
        //设置了freeRect--活动范围
    }else{
        //没有设置freeRect--活动范围，则设置默认的活动范围为根控制器的frame
        self.freeRect = [UIApplication sharedApplication].keyWindow.rootViewController.view.frame;
    }
}

/**
 拖动事件
 @param pan 拖动手势
 */
-(void)dragAction:(UIPanGestureRecognizer *)pan{
    //先判断可不可以拖动，如果不可以拖动，直接返回，不操作
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{///开始拖动
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeStatus) object:nil];
            self.alpha = normalAlpha;
            
            //  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            //保存触摸起始点位置
            self.startPoint = [pan translationInView:self];
            //该view置于最前
            [self.superview bringSubviewToFront:self];
            break;
        }
        case UIGestureRecognizerStateChanged:{///拖动中
            //计算位移 = 当前位置 - 起始位置
           
            CGPoint point = [pan translationInView:self];
            float dx;
            float dy;
            dx = point.x - self.startPoint.x;
            dy = point.y - self.startPoint.y;
            //计算移动后的view中心点
            CGPoint newCenter = CGPointMake(self.center.x + dx, self.center.y + dy);
            //移动view
            self.center = newCenter;
            //  注意一旦你完成上述的移动，将translation重置为0十分重要。否则translation每次都会叠加
            [pan setTranslation:CGPointZero inView:self];
            break;
        }
        case UIGestureRecognizerStateEnded:{///拖动结束
            [self keepBounds];
            [self performSelector:@selector(changeStatus) withObject:nil afterDelay:statusChangeDuration];
            break;
        }
        default:
            break;
    }
}

- (void)keepBounds{
    //中心点判断
    float centerX = self.freeRect.origin.x+(self.freeRect.size.width - self.frame.size.width)/2;
    CGRect rect = self.frame;
    if (self.isKeepBounds==NO) {//没有黏贴边界的效果
        if (self.frame.origin.x < self.freeRect.origin.x) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else if(self.freeRect.origin.x+self.freeRect.size.width < self.frame.origin.x+self.frame.size.width){
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x+self.freeRect.size.width-self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }else if(self.isKeepBounds==YES){//自动粘边
        if (self.frame.origin.x< centerX) {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"leftMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x = self.freeRect.origin.x;
            self.frame = rect;
            [UIView commitAnimations];
        } else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:@"rightMove" context:context];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:0.5];
            rect.origin.x =self.freeRect.origin.x+self.freeRect.size.width - self.frame.size.width;
            self.frame = rect;
            [UIView commitAnimations];
        }
    }
    if (self.frame.origin.y < self.freeRect.origin.y) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"topMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y;
        self.frame = rect;
        [UIView commitAnimations];
    } else if(self.freeRect.origin.y+self.freeRect.size.height< self.frame.origin.y+self.frame.size.height){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:@"bottomMove" context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.5];
        rect.origin.y = self.freeRect.origin.y+self.freeRect.size.height-self.frame.size.height;
        self.frame = rect;
        [UIView commitAnimations];
    }
}

///点击事件
-(void)clickDragView{
    
    if (self.clickViewBlock) {
        self.clickViewBlock(self);
    }
}

- (void)changeStatus
{
    [UIView animateWithDuration:1.0 animations:^{
        self.alpha = sleepAlpha;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat x = self.center.x < 20+WIDTH/2 ? 0 :  self.center.x > kScreenWidth - 20 -WIDTH/2 ? kScreenWidth : self.center.x;
        CGFloat y = self.center.y < 40 + HEIGHT/2 ? 0 : self.center.y > kScreenHeight - 40 - HEIGHT/2 ? kScreenHeight : self.center.y;
        //禁止停留在4个角
        if((x == 0 && y ==0) || (x == kScreenWidth && y == 0) || (x == 0 && y == kScreenHeight) || (x == kScreenWidth && y == kScreenHeight)){
            y = self.center.y;
        }
        self.center = CGPointMake(x, y);
    }];
}

-(void)show{
    self.hidden = NO;
}
-(void)hide{
    
    self.hidden = YES;
}
@end
