//
//  HLPostcodeHeaderSecondView.h
//  简闻
//
//  Created by 韩露露 on 16/5/9.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HLPostcodeHeaderSecondView;
@protocol HLPostcodeHeaderSecondViewDelegate <NSObject, UITextFieldDelegate>

@optional
- (void)postcodeHeaderSecondViewDidClickbtn:(HLPostcodeHeaderSecondView *)view;

@end

@interface HLPostcodeHeaderSecondView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UITextField *province;
@property (weak, nonatomic) IBOutlet UITextField *district;
@property (weak, nonatomic) IBOutlet UITextField *keyword;
@property (weak, nonatomic) id<HLPostcodeHeaderSecondViewDelegate> delegate;
@property (assign, nonatomic, getter = isBtnEnable) BOOL btnEnable;

- (void)hiddenKeyboard;
+ (instancetype)postcodeHeaderSecondView;
@end
