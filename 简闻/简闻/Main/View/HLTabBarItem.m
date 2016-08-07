//
//  HLTabBarItem.m
//  简闻
//
//  Created by 韩露露 on 16/6/30.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLTabBarItem.h"

@implementation HLTabBarItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.imageInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.imageInsets = UIEdgeInsetsMake(3, 3, 3, 3);
    }
    return self;
}

@end
