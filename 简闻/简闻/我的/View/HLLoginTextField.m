//
//  HLLoginTextField.m
//  简闻
//
//  Created by 韩露露 on 16/6/17.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLLoginTextField.h"

@implementation HLLoginTextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupBackground];
    }
    return self;
}

//- (void)drawPlaceholderInRect:(CGRect)rect {
//}

- (void)setupBackground {
    self.borderStyle = UITextBorderStyleNone;
    UIImage *image = [UIImage imageNamed:@"searchbar_textfield_background"];
    CGFloat w = image.size.width * 0.5;
    CGFloat h = image.size.height * 0.5;
    self.background = [image resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h, w) resizingMode:UIImageResizingModeStretch];
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.clearButtonMode = UITextFieldViewModeAlways;
}

@end
