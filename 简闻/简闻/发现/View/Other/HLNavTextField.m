//
//  HLNavTextField.m
//  简闻
//
//  Created by 韩露露 on 16/5/17.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLNavTextField.h"

@interface HLNavTextField ()
@property (assign, nonatomic) int hans;
@property (assign, nonatomic) int other;
@end

@implementation HLNavTextField

- (void)drawPlaceholderInRect:(CGRect)rect { // 额外的，，，用于更改Placeholder的文字大小、颜色、位置的
    NSAttributedString *placeholder = self.attributedPlaceholder;
    NSRange range = NSMakeRange(0, self.placeholder.length);
    NSMutableDictionary *dict = [placeholder attributesAtIndex:0 effectiveRange:&range].mutableCopy;
    UIColor *col = [UIColor orangeColor];
    col = [col colorWithAlphaComponent:0.5];
    dict[NSForegroundColorAttributeName] = col;
    dict[NSFontAttributeName] = [UIFont systemFontOfSize:13];
    CGRect myRect = CGRectMake(rect.origin.x + 3, rect.origin.y + 7, rect.size.width, rect.size.height);
    [[self placeholder] drawInRect:myRect withAttributes:dict];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hans = -1;
        self.other = -1;
        [self addTarget:self action:@selector(searchDidChange:) forControlEvents:UIControlEventEditingChanged]; // 初始化时监听文字的改变
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hans = -1;
        self.other = -1;
        [self addTarget:self action:@selector(searchDidChange:) forControlEvents:UIControlEventEditingChanged]; // 初始化时监听文字的改变
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.hans = -1;
        self.other = -1;
        [self addTarget:self action:@selector(searchDidChange:) forControlEvents:UIControlEventEditingChanged]; // 初始化时监听文字的改变
    }
    return self;
}

- (void)limitHansLength:(int)hans otherLength:(int)other {
    self.hans = hans; // 设置中文状态下的限制字数
    self.other = other; // 设置状态下的限制字数
}

- (void)searchDidChange:(UITextField *)textField {
    if (![textField.textInputMode.primaryLanguage isEqualToString:@"en-US"]) { // 判断输入状态是否为英文
        if (!textField.markedTextRange && (self.hans >= 0) && (textField.text.length > self.hans)) { // 过滤掉输入时高亮状态下的情况
            [self setCaretPositionWithTextField:textField limit:self.hans];
        }
    } else { // 英文输入状态下
        if ((self.other >= 0) && (textField.text.length > self.other)) {
            [self setCaretPositionWithTextField:textField limit:self.other];
        }
        NSDictionary *dict = @{@"hansLength" : @(self.hans), @"otherLength" : @(self.other)};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"textFieldDidChange" object:nil userInfo:dict];
    }
}

- (void)setCaretPositionWithTextField:(UITextField *)textField limit:(NSUInteger)length {
    UITextPosition *selectedPosition = textField.selectedTextRange.start; // 拿到截取之前的光标位置
    textField.text = [textField.text substringToIndex:length]; // 截取限制字数以内的文本
    textField.selectedTextRange = [textField textRangeFromPosition:selectedPosition toPosition:selectedPosition]; // 恢复光标的位置
}

@end