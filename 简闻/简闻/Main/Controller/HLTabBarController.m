//
//  HLTabBarController.m
//  简闻
//
//  Created by 韩露露 on 16/4/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLTabBarController.h"

@interface HLTabBarController ()

@end

@implementation HLTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITabBar *tabBar = self.tabBar;
    tabBar.tintColor = [UIColor orangeColor];
    UIImage *image = [UIImage imageNamed:@"NavBar"];
    CGFloat width = image.size.width * 0.5;
    CGFloat height = image.size.height * 0.5;
    tabBar.backgroundImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(height, width, height, width) resizingMode:UIImageResizingModeStretch];
    
    UITabBarItem *item = [UITabBarItem appearance];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:13];
    [item setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

@end
