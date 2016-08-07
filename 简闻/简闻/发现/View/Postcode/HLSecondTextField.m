//
//  HLSecondTextField.m
//  简闻
//
//  Created by 韩露露 on 16/5/10.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLSecondTextField.h"

@implementation HLSecondTextField

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackground];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setBackground];
    }
    return self;
}

- (void)setBackground {
    self.borderStyle = UITextBorderStyleNone;
    UIImage *image = [UIImage imageNamed:@"searchbar_textfield_background"];
    CGFloat w = image.size.width * 0.5;
    CGFloat h = image.size.height * 0.5;
    self.background = [image resizableImageWithCapInsets:UIEdgeInsetsMake(h, w, h, w) resizingMode:UIImageResizingModeStretch];
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    UIButton *rightView = [[UIButton alloc] init];
    [rightView addTarget:self action:@selector(clickRightView) forControlEvents:UIControlEventTouchDown];
    UIImage *imageBtn = [UIImage imageNamed:@"navigationbar_arrow_down"];
    
    [rightView setImage:imageBtn forState:UIControlStateNormal];
    
    self.rightView.translatesAutoresizingMaskIntoConstraints = NO;
    rightView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *rightWidth = [NSLayoutConstraint constraintWithItem:rightView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:imageBtn.size.width + 6];
    NSLayoutConstraint *rightHeight = [NSLayoutConstraint constraintWithItem:rightView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:imageBtn.size.height + 16];
    [rightView addConstraints:@[rightWidth, rightHeight]];
    
    rightView.contentMode = UIViewContentModeCenter;
    self.rightView = rightView;
    self.rightViewMode = UITextFieldViewModeAlways;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeySearch;
}

- (void)clickRightView {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didClickTextFieldBtn" object:self];
}

@end
