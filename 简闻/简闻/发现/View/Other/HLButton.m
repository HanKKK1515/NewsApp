//
//  HLButton.m
//  简闻
//
//  Created by 韩露露 on 16/4/28.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLButton.h"

@implementation HLButton

- (instancetype)init {
    if (self = [super init]) {
        [self setBackgroundImage];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setBackgroundImage];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundImage];
    }
    return self;
}

- (void)setBackgroundImage {
    self.showsTouchWhenHighlighted = YES;
    
    UIImage *norImage = [UIImage imageNamed:@"RedButton"];
    CGFloat x = norImage.size.width * 0.5;
    CGFloat y = norImage.size.height * 0.5;
    norImage = [norImage resizableImageWithCapInsets:UIEdgeInsetsMake(y, x, y, x) resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:norImage forState:UIControlStateNormal];
    
    UIImage *heightImage = [UIImage imageNamed:@"RedButtonPressed"];
    CGFloat w = heightImage.size.width * 0.5;
    CGFloat h = heightImage.size.height * 0.5;
    heightImage = [heightImage resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h, w) resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:heightImage forState:UIControlStateHighlighted];
    [self setBackgroundImage:heightImage forState:UIControlStateDisabled];
}

@end
