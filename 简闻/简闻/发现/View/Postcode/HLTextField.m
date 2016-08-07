//
//  HLTextField.m
//  简闻
//
//  Created by 韩露露 on 16/5/4.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLTextField.h"

@implementation HLTextField

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
    
    UIImageView *leftView = [[UIImageView alloc] init];
    leftView.image = [UIImage imageNamed:@"searchbar_textfield_search_icon"];
    self.rightView.translatesAutoresizingMaskIntoConstraints = NO;
    leftView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *leftWidth = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:leftView.image.size.width + 15];
    NSLayoutConstraint *leftHeight = [NSLayoutConstraint constraintWithItem:leftView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:leftView.image.size.height];
    [leftView addConstraints:@[leftWidth, leftHeight]];
    
    leftView.contentMode = UIViewContentModeCenter;
    self.leftView = leftView;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
}

@end
