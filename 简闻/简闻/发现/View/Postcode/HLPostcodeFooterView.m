//
//  HLPostcodeFooterView.m
//  简闻
//
//  Created by 韩露露 on 16/5/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLPostcodeFooterView.h"

@interface HLPostcodeFooterView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation HLPostcodeFooterView

- (void)startActive {
    [self.activeView startAnimating];
    self.activeView.hidden = NO;
    _active = YES;
}

- (void)stopActive {
    [self.activeView stopAnimating];
    self.activeView.hidden = YES;
    _active = NO;
}

- (void)setFooterViewWithString:(NSString *)string {
    self.label.text = string;
}

+ (instancetype)postcodeFooterView {
    return [[NSBundle mainBundle] loadNibNamed:@"HLPostcodeFooterView" owner:self options:nil].lastObject;;
}

@end
