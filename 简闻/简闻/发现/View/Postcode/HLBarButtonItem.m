//
//  HLBarButtonItem.m
//  简闻
//
//  Created by 韩露露 on 16/5/11.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLBarButtonItem.h"

@implementation HLBarButtonItem

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

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    CGSize size = [self.title sizeWithAttributes:attributes];
    self.width = size.width + 15;
}

- (void)setBackgroundImage {
    UIImage *norImage = [UIImage imageNamed:@"RedButton"];
    CGFloat x = norImage.size.width * 0.5;
    CGFloat y = norImage.size.height * 0.5;
    norImage = [norImage resizableImageWithCapInsets:UIEdgeInsetsMake(y, x, y, x) resizingMode:UIImageResizingModeStretch];
    [self setBackgroundImage:norImage forState:UIControlStateNormal style:UIBarButtonItemStylePlain barMetrics:UIBarMetricsDefault];
}

@end
