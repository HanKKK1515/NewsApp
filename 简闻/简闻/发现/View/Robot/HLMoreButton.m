//
//  HLMoreButton.m
//  简闻
//
//  Created by 韩露露 on 16/6/30.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLMoreButton.h"

@implementation HLMoreButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

@end
