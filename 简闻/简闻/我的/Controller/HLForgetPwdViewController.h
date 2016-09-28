//
//  HLForgetPwdViewController.h
//  简闻
//
//  Created by 韩露露 on 16/6/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLButton.h"

typedef NS_ENUM(NSUInteger, HLEmailOption) {
    kHLEmailOptionResetPwd,
    kHLEmailOptionVerify,
    kHLEmailOptionReset,
    kHLEmailOptionSet
};

@interface HLForgetPwdViewController : UIViewController
@property (assign, nonatomic) HLEmailOption emailOption;
@property (copy, nonatomic) NSString *btnTitle;
@property (copy, nonatomic) NSString *emailStr;
@property (copy, nonatomic) NSString *placeholder;
@end
