//
//  HLNavigationController.m
//  简闻
//
//  Created by 韩露露 on 16/4/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNavigationController.h"

@interface HLNavigationController ()

@end

@implementation HLNavigationController

- (void)viewDidLoad { 
    [super viewDidLoad];
    
    UINavigationBar *navBar = self.navigationBar;
    navBar.tintColor = [UIColor cyanColor];
    UIImage *image = [UIImage imageNamed:@"NavBar64"];
    CGFloat width = image.size.width * 0.5;
    CGFloat height = image.size.height * 0.5;
    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(height, width, height, width) resizingMode:UIImageResizingModeStretch];
    [navBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor cyanColor];
    attributes[NSFontAttributeName] = [UIFont fontWithName:@"Heiti TC" size:18];
    [navBar setTitleTextAttributes:attributes];
    
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    NSMutableDictionary *attribs = [NSMutableDictionary dictionary];
    attribs[NSFontAttributeName] = [UIFont fontWithName:@"Heiti TC" size:18];
    [item setTitleTextAttributes:attribs forState:UIControlStateNormal];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}

@end
