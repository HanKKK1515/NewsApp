//
//  HLRobotToolBars.m
//  简闻
//
//  Created by 韩露露 on 16/5/26.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLRobotToolBar.h"
#import "HLButton.h"

@interface HLRobotToolBar () <UITextViewDelegate>
@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) HLButton *send;
@property (weak, nonatomic) UIImageView *imageView;
@end

@implementation HLRobotToolBar

- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *sub in self.subviews) {
        if ([sub isMemberOfClass:[HLButton class]]) {
            self.send = (HLButton *)sub;
            [self.send addTarget:self action:@selector(clickSend:) forControlEvents:UIControlEventTouchUpInside];
        }
        if ([sub isMemberOfClass:[UITextView class]]) {
            self.textView = (UITextView *)sub;
            self.textView.returnKeyType = UIReturnKeySend;
            self.textView.delegate = self;
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self clickSend:nil];
        return NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toolBarBeginEditing" object:self];
}

- (void)clickSend:(HLButton *)send {
    if ([self.delegate respondsToSelector:@selector(robotToolBar:text:)]) {
        [self.delegate robotToolBar:self text:self.textView.text];
    }
}

- (void)clearText {
    self.textView.text = @"";
}

- (NSString *)text {
    return self.textView.text;
}

- (void)setDelegate:(id<HLRobotToolBarDelegate>)delegate {
    _delegate = delegate;
}

- (void)toolBarBecomeFirstResponder {
    [self.textView becomeFirstResponder];
}

- (void)toolBarResignFirstResponder {
    [self.textView resignFirstResponder];
}

@end