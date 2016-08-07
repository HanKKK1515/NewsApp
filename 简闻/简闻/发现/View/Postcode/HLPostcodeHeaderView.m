//
//  HLpostcodeView.m
//  简闻
//
//  Created by 韩露露 on 16/5/4.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLPostcodeHeaderView.h"
#import "HLButton.h"

@interface HLPostcodeHeaderView () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet HLButton *btn;
- (IBAction)clickSearchBtn;
@end

@implementation HLPostcodeHeaderView

- (void)showKeyboard {
    [self.searchText becomeFirstResponder];
}
- (void)hiddenKeyboard {
    [self.searchText endEditing:YES];
}

+ (instancetype)postcodeHeaderView {
    HLPostcodeHeaderView *headerView = [[NSBundle mainBundle] loadNibNamed:@"HLPostcodeHeaderView" owner:self options:nil].lastObject;
    headerView.searchText.delegate = headerView;
    return headerView;
}

- (IBAction)clickSearchBtn {
    if ([self.delegate respondsToSelector:@selector(postcodeHeaderView:)]) {
        [self.delegate postcodeHeaderView:self];
        [self.searchText endEditing:YES];
    }
}

- (void)setDelegate:(id<HLPostcodeHeaderViewDelegate>)delegate {
    _delegate = delegate;
    self.searchText.delegate = self.delegate;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField endEditing:YES];
}

- (void)setBtnEnable:(BOOL)btnEnable {
    _btnEnable = btnEnable;
    self.btn.enabled = btnEnable;
}

@end
