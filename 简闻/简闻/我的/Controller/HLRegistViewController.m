//
//  HLRegistViewController.m
//  简闻
//
//  Created by 韩露露 on 16/6/20.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLRegistViewController.h"
#import "HLLoginTextField.h"
#import "HLTool.h"
#import "HLButton.h"
#import "HLGenderView.h"
#import "MBProgressHUD+MJ.h"
#import "HLBirthdayView.h"
#import "NSDate+HL.h"
#import <BmobSDK/Bmob.h>
#import "NSString+md5.h"

@interface HLRegistViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet HLLoginTextField *userName;
@property (weak, nonatomic) IBOutlet HLLoginTextField *pwd;
@property (weak, nonatomic) IBOutlet HLLoginTextField *again;
@property (weak, nonatomic) IBOutlet HLLoginTextField *mail;
@property (weak, nonatomic) IBOutlet HLLoginTextField *gender;
@property (weak, nonatomic) IBOutlet HLLoginTextField *birthday;
@property (weak, nonatomic) IBOutlet HLButton *registBtn;

- (IBAction)regist;
@end

@implementation HLRegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.userName limitHansLength:8 otherLength:20];
    [self.pwd limitHansLength:0 otherLength:20];
    [self.again limitHansLength:0 otherLength:20];
    
    [self.userName becomeFirstResponder];
    
    self.userName.delegate = self;
    self.pwd.delegate = self;
    self.again.delegate = self;
    self.mail.delegate = self;
    self.gender.delegate = self;
    self.birthday.delegate = self;
    
    [self setupNotif];
}

- (void)setupNotif {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiedChange) name:UITextFieldTextDidChangeNotification object:self.userName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderDidChoice:) name:@"genderDidChoice" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderDidCancel) name:@"genderDidCancel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(genderDidDone) name:@"genderDidDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedBirthday:) name:@"didSelectedDateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCancelBirthday) name:@"didCancelDateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDoneBirthday) name:@"didDoneDateNotification" object:nil];
}

- (void)genderDidChoice:(NSNotification *)notif {
    self.gender.text = notif.userInfo[@"userInfo"];
}

- (void)genderDidCancel {
    self.gender.text = @"";
    [self.gender resignFirstResponder];
}

- (void)genderDidDone {
    [self.gender resignFirstResponder];
}

- (void)didSelectedBirthday:(NSNotification *)notif {
    NSDate *date = notif.userInfo[@"userInfo"];
    self.birthday.text = date.stringWithYMD;
}

- (void)didCancelBirthday {
    self.birthday.text = @"";
    [self.birthday resignFirstResponder];
}

- (void)didDoneBirthday {
    [self.birthday resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)verifyPwd {
    if ([self.pwd.text isEqualToString:self.again.text]) {
        return YES;
    } else {
        [MBProgressHUD showMessage:@"确认密码不一致，请核对后再操作。" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
                [self.again becomeFirstResponder];
            });
        });
        return NO;
    }
}

- (BOOL)verifyUserNameLegal {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH ' ' || SELF ENDSWITH ' '"];
    if ([predicate evaluateWithObject:self.userName.text]) {
        [MBProgressHUD showMessage:@"用户名不能以空格开头或结尾！" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
                [self.userName becomeFirstResponder];
            });
        });
        return NO;
    }
    return YES;
}

- (BOOL)verifyPwdLegal {
    if (self.pwd.text.length < 6) {
        [self.view endEditing:YES];
        [MBProgressHUD showMessage:@"密码至少设置6位" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
            [self.pwd becomeFirstResponder];
            self.again.text = @"";
        });
        return NO;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS ' '"];
        if ([predicate evaluateWithObject:self.pwd.text]) {
            [self.view endEditing:YES];
            [MBProgressHUD showMessage:@"密码不能包含空格" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
                [self.pwd becomeFirstResponder];
                self.again.text = @"";
            });
            return NO;
        }
        return YES;
    }
}

- (void)verifyPwdLenght {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.registBtn.enabled = self.gender.enabled = self.birthday.enabled = self.mail.enabled = (self.pwd.text.length >= 6) && (self.pwd.text.length == self.again.text.length);
    });
}

- (BOOL)verifyMailLegal {
    if (self.mail.text.length <= 0) return YES;
    
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
    if (![emailTest evaluateWithObject:self.mail.text]) {
        [self.view endEditing:YES];
        [MBProgressHUD showMessage:@"邮箱格式不正确！" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
            [self.mail becomeFirstResponder];
        });
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.pwd]) {
        if ([self verifyUserNameLegal]) {
            [self verifyPwdLenght];
        }
    } else if ([textField isEqual:self.again]) {
        if ([self verifyPwdLegal] && [self verifyUserNameLegal]) {
            [self verifyPwdLenght];
        }
    } else if ([textField isEqual:self.mail]) {
        if (![self verifyPwd] || ![self verifyUserNameLegal]) {
            self.registBtn.enabled = self.gender.enabled = self.birthday.enabled = self.mail.enabled = NO;
        }
    } else if ([textField isEqual:self.gender]) {
        if (![self verifyPwd] || ![self verifyUserNameLegal]) {
            self.gender.enabled = self.birthday.enabled = self.mail.enabled = NO;
        } else if ([self verifyMailLegal]) {
            textField.inputView = [HLGenderView genderView];
        }
    } else if ([textField isEqual:self.birthday]) {
        if (![self verifyPwd] || ![self verifyUserNameLegal]) {
            self.gender.enabled = self.birthday.enabled = self.mail.enabled = NO;
        } else if ([self verifyMailLegal]) {
            textField.inputView = [HLBirthdayView birthdayView];
        }
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.again.enabled = self.pwd.enabled = self.userName.text.length > 0;
        self.mail.enabled = self.gender.enabled = self.birthday.enabled = self.registBtn.enabled = self.userName.text.length > 0 && (self.pwd.text.length >= 6 && [self.pwd.text isEqualToString:self.again.text]);
    });
    return YES;
}

- (void)textFiedChange {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.again.enabled = self.pwd.enabled = self.userName.text.length > 0;
        self.mail.enabled = self.gender.enabled = self.birthday.enabled = self.registBtn.enabled = self.userName.text.length > 0 && (self.pwd.text.length >= 6 && [self.pwd.text isEqualToString:self.again.text]);
    });
}

- (void)setupAccount {
    HLAccount *account = [HLAccount sharedAccount];
    account.nickname = self.userName.text;
    account.pwd = self.pwd.text.md5String;
    account.email = self.mail.text;
    account.gender = self.gender.text;
    account.birthday = self.birthday.text;
    account.platformType = kHLPlatformTypeNone;
    account.login = YES;
    account.uid = self.pwd.text.md5String;
    account.icon = @"";
    account.rememberPwd = YES;
    account.autoLogin = YES;
    account.notes = [NSArray array];
    
    [self.view endEditing:YES];
    [MBProgressHUD showMessage:@"注册完成，请登录邮箱验证。" toView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        [self.navigationController popToRootViewControllerAnimated:YES];
    });
}

- (IBAction)regist {
    if (![self verifyMailLegal] || ![self verifyPwd]) return;
    
    self.registBtn.enabled = NO;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.registBtn.enabled = YES;
    });
    BmobUser *bUser = [[BmobUser alloc] init];
    bUser.username = self.userName.text;
    if (self.mail.text.length > 0) {
        bUser.email = self.mail.text;
    }
    bUser.password =  self.pwd.text.md5String;
    [bUser setObject:self.gender.text forKey:@"gender"];
    [bUser setObject:self.birthday.text forKey:@"birthday"];
    [bUser setObject:@"" forKey:@"icon"];
    [bUser setObject:self.pwd.text.md5String forKey:@"uid"];
    [bUser setObject:[NSNumber numberWithUnsignedLong:kHLPlatformTypeNone] forKey:@"platformType"];
    [bUser signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful){
            [BmobUser loginInbackgroundWithAccount:self.userName.text andPassword:self.pwd.text.md5String block:^(BmobUser *user, NSError *error) {
                if (user) {
                    [self.view endEditing:YES];
                    [self setupAccount];
                } else {
                    [self.view endEditing:YES];
                    [MBProgressHUD showError:@"用户名或密码错误" toView:self.view];
                }
            }];
        } else {
            [self.view endEditing:YES];
            [MBProgressHUD showMessage:@"注册失败" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view];
            });
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self regist];
    [self.view endEditing:YES];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
