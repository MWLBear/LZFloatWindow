//
//  ViewController.m
//  LZFloatWindow
//
//  Created by lz on 2017/12/2.
//  Copyright © 2017年 lz. All rights reserved.
//

#import "ViewController.h"
#import "LZFloatWindow.h"

@interface ViewController ()
@property(nonatomic,strong)LZFloatWindow*floatWindow;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.floatWindow = [[LZFloatWindow alloc]initWithFrame:CGRectMake(0, 0, 40, 40) mainImageName:[UIImage imageNamed:@"timg.jpeg"]];
    [self.floatWindow show];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
