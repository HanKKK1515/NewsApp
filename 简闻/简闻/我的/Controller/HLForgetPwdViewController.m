//
//  HLForgetPwdViewController.m
//  简闻
//
//  Created by 韩露露 on 16/6/22.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLForgetPwdViewController.h"
#import "MBProgressHUD+MJ.h"
#import "HLLoginTextField.h"
#import <BmobSDK/Bmob.h>
#import "HLAccount.h"

@interface HLForgetPwdViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet HLLoginTextField *email;
@property (weak, nonatomic) IBOutlet HLButton *btn;

- (IBAction)clickBtn:(HLButton *)sender;
@end

@implementation HLForgetPwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.email.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.btn setTitle:self.btnTitle forState:UIControlStateNormal];
    if (self.emailOption == kHLEmailOptionVerify) {
        self.email.text = self.emailStr;
    } else if (self.emailOption == kHLEmailOptionReset) {
        self.email.placeholder = self.placeholder;
        [self.email becomeFirstResponder];
    } else {
        [self.email becomeFirstResponder];
    }
}

/**
 *  检测邮箱地址是否正确
 */
- (BOOL)stringIsValidEmail:(NSString *)checkString {
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    return [emailTest evaluateWithObject:checkString];
}

- (void)resetPwdWithArray:(NSArray *)array {
    if (array.count >0) {
        BmobUser *bUser = array.firstObject;
        if ([[bUser objectForKey:@"emailVerified"] boolValue]) {
            [BmobUser requestPasswordResetInBackgroundWithEmail:self.email.text];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pwdDidReset" object:nil];
            
            [MBProgressHUD showMessage:@"重置链接已发送至邮箱。" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
                [self.navigationController popViewControllerAnimated:YES];
            });
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"此邮箱尚未验证，立即验证？" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [bUser verifyEmailInBackgroundWithEmailAddress:self.email.text];
                [MBProgressHUD showMessage:@"验证链接已发送至邮箱。" toView:self.view];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view];
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }];
            UIAlertAction *actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:actionYES];
            [alert addAction:actionNO];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [MBProgressHUD showMessage:@"此邮箱尚未注册本站用户" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
            [self.email becomeFirstResponder];
        });
    }
}

- (IBAction)clickBtn:(HLButton *)sender {
    [self.email resignFirstResponder];
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    if ([self stringIsValidEmail:self.email.text]) {
        if (self.emailOption == kHLEmailOptionResetPwd) {
            BmobQuery *bquery = [BmobQuery queryWithClassName:@"_User"];
            [bquery whereKey:@"email" equalTo:self.email.text];
            [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                if (error) {
                    [MBProgressHUD showMessage:@"发送失败" toView:self.view];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view];
                        [self.email becomeFirstResponder];
                    });
                } else {
                    [self resetPwdWithArray:array];
                }
            }];
        } else if (self.emailOption == kHLEmailOptionVerify || self.emailOption == kHLEmailOptionReset ||self.emailOption == kHLEmailOptionSet) {
            __block BmobUser *user = [BmobUser currentUser];
            user.email = self.email.text;
            [user updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    [user verifyEmailInBackgroundWithEmailAddress:self.email.text];
                    [[HLAccount sharedAccount] setEmail:self.email.text];
                    
                    [MBProgressHUD showMessage:@"验证链接已发送至邮箱。" toView:self.view];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                } else {
                    [MBProgressHUD showError:@"添加失败，邮箱可能已被占用!" toView:self.view];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [MBProgressHUD hideHUDForView:self.view];
                        [self.email becomeFirstResponder];
                    });
                }
            }];
        }
    } else {
        [MBProgressHUD showMessage:@"邮箱格式不正确！" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
            [self.email becomeFirstResponder];
        });
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self clickBtn:self.btn];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
