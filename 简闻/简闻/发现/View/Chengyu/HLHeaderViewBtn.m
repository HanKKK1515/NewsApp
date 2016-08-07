//
//  HLHeaderViewBtn.m
//  简闻
//
//  Created by 韩露露 on 16/5/16.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLHeaderViewBtn.h"

@implementation HLHeaderViewBtn

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setMyBackground];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setMyBackground];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMyBackground];
    }
    return self;
}

- (void)setMyBackground {
    self.layer.cornerRadius = 5;
}

@end
