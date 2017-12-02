//
//  LZFloatWindow.h
//  YayawanIosSDK
//
//  Created by lz on 2017/11/29.
//  Copyright © 2017年 mengwenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZFloatWindow : UIWindow
@property (nonatomic,assign) CGRect freeRect; //freeRect--活动范围
@property (nonatomic,assign) BOOL isKeepBounds; //粘边效果 默认 YES
@property (nonatomic,copy) void(^clickViewBlock)(LZFloatWindow*view);
-(instancetype)initWithFrame:(CGRect)frame mainImageName:(UIImage*)image;
-(void)show;
-(void)hide;
@end
