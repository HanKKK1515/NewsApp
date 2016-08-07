//
//  HLPostcodeHeaderSecondView.m
//  简闻
//
//  Created by 韩露露 on 16/5/9.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLPostcodeHeaderSecondView.h"
#import "HLButton.h"

@interface HLPostcodeHeaderSecondView ()
@property (weak, nonatomic) IBOutlet HLButton *btn;

- (IBAction)clickSearchBtn;

@end

@implementation HLPostcodeHeaderSecondView

- (void)hiddenKeyboard {
    [self.province endEditing:YES];
    [self.district endEditing:YES];
    [self.keyword endEditing:YES];
}

+ (instancetype)postcodeHeaderSecondView {
    HLPostcodeHeaderSecondView *view = [[NSBundle mainBundle] loadNibNamed:@"HLPostcodeHeaderSecondView" owner:self options:nil].lastObject;
    view.keyword.rightView = nil;
    return view;
}

- (void)setDelegate:(id<HLPostcodeHeaderSecondViewDelegate>)delegate {
    _delegate = delegate;
    
    self.province.delegate = self.delegate;
    self.district.delegate = self.delegate;
    self.keyword.delegate = self.delegate;
}

- (IBAction)clickSearchBtn {
    if ([self.delegate respondsToSelector:@selector(postcodeHeaderSecondViewDidClickbtn:)]) {
        [self.delegate postcodeHeaderSecondViewDidClickbtn:self];
    }
}

- (void)setBtnEnable:(BOOL)btnEnable {
    _btnEnable = btnEnable;
    self.btn.enabled = btnEnable;
}

@end
