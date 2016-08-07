//
//  HLpostcodeView.h
//  简闻
//
//  Created by 韩露露 on 16/5/4.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLTextField.h"

@class HLPostcodeHeaderView;
@protocol HLPostcodeHeaderViewDelegate <NSObject, UITextFieldDelegate>

@optional
- (void)postcodeHeaderView:(HLPostcodeHeaderView *)postcodeHeaderView;

@end

@interface HLPostcodeHeaderView : UITableViewHeaderFooterView
@property (strong, nonatomic) id<HLPostcodeHeaderViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet HLTextField *searchText;
@property (assign, nonatomic, getter = isBtnEnable) BOOL btnEnable;

- (void)showKeyboard;
- (void)hiddenKeyboard;
+ (instancetype)postcodeHeaderView;
@end
