//
//  HLShowRefreshCountTool.m
//  简闻
//
//  Created by 韩露露 on 16/8/18.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLShowRefreshCountTool.h"

@implementation HLShowRefreshCountTool

+ (void)showText:(NSString *)text inNavc:(UINavigationController *)navc; {
    UILabel *label = [[UILabel alloc] init];
    label.alpha = 0.0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10];
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_new_status_background"]];
    [navc.view insertSubview:label belowSubview:navc.navigationBar];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:navc.navigationBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:navc.navigationBar attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:[UIScreen mainScreen].bounds.size.width];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:20];
    [navc.view addConstraints:@[bottom, centerX, width, height]];
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 1.0;
        label.transform = CGAffineTransformMakeTranslation(0, 20);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            label.alpha = 0.0;
            label.transform =CGAffineTransformMakeTranslation(0, 0);
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
}

@end
