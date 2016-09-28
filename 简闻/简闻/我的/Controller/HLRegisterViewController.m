//
//  HLRegisterViewController.m
//  简闻
//
//  Created by 韩露露 on 16/6/11.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLRegisterViewController.h"
#import "MBProgressHUD+MJ.h"
#import "HLLoginTextField.h"
#import "HLTool.h"
#import <BmobSDK/Bmob.h>
#import "HLForgetPwdViewController.h"
#import "HLMemo.h"
#import "NSString+md5.h"

@interface HLRegisterViewController ()
@property (weak, nonatomic) IBOutlet HLLoginTextField *accountField;
@property (weak, nonatomic) IBOutlet HLLoginTextField *pwdField;
@property (weak, nonatomic) IBOutlet HLButton *loginBtn;
@property (weak, nonatomic) IBOutlet UISwitch *loginSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *pwdSwitch;
@property (strong, nonatomic) HLAccount *account;

- (IBAction)loginSwitchClick;
- (IBAction)pwdSwitchClick;
- (IBAction)login;
@end

@implementation HLRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiedChange) name:UITextFieldTextDidChangeNotification object:self.accountField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFiedChange) name:UITextFieldTextDidChangeNotification object:self.pwdField];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pwdDidReset) name:@"pwdDidReset" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.account) {
        self.accountField.text = self.account.nickname;
        self.pwdSwitch.on = self.account.isRememberPwd;
        self.loginSwitch.on = self.account.isAutoLogin;
        if(self.account.isRememberPwd) {
            self.pwdField.text = self.account.pwd;
            self.loginBtn.enabled = YES;
        } else {
            self.loginSwitch.on = NO;
        }
    }
    
    if (self.accountField.text.length) {
        [self.pwdField becomeFirstResponder];
    } else {
        [self.accountField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.accountField endEditing:YES];
    [self.pwdField endEditing:YES];
    [HLTool saveAccount:[HLAccount sharedAccount]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textFiedChange {
    self.loginBtn.enabled = (self.accountField.text.length && self.pwdField.text.length);
    if (self.accountField.text.length <= 0) {
        self.pwdField.text = @"";
        self.pwdSwitch.on = NO;
        self.loginSwitch.on = NO;
    }
}

- (void)pwdDidReset {
    self.account.rememberPwd = NO;
    self.account.pwd = @"";
    self.pwdSwitch.on = NO;
    self.loginBtn.enabled = NO;
    self.pwdField.text = @"";
}

- (IBAction)pwdSwitchClick {
    if (self.pwdField.text.length > 0) {
        self.account.rememberPwd = self.pwdSwitch.isOn;
        self.account.autoLogin = self.loginSwitch.isOn;
        if(self.pwdSwitch.on) return;
        [self.loginSwitch setOn:NO animated:YES];
    } else if (self.pwdSwitch.isOn) {
        self.pwdSwitch.on = NO;
        [MBProgressHUD showMessage:@"请先输入密码！" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
    }
}

- (IBAction)loginSwitchClick {
    if ((self.pwdField.text.length > 0) && (self.accountField.text.length > 0)) {
        self.account.rememberPwd = self.pwdSwitch.isOn;
        self.account.autoLogin = self.loginSwitch.isOn;
        if(!self.loginSwitch.on) return;
        [self.pwdSwitch setOn:YES animated:YES];
    } else if (self.loginSwitch.isOn) {
        self.loginSwitch.on = NO;
        [MBProgressHUD showMessage:@"请先输入用户名和密码！" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HLForgetPwdViewController *desVc = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"forgetSegue"]) {
        desVc.emailOption = kHLEmailOptionResetPwd;
        desVc.btnTitle = @"发送";
    }
}

- (void)setupAccountWithUser:(BmobUser *)user {
    [self.loginBtn setTitle:@"正在登录..." forState:UIControlStateNormal];
    
    self.account.nickname = user.username;
    self.account.rememberPwd = self.pwdSwitch.isOn;
    self.account.autoLogin = self.loginSwitch.isOn;
    self.account.login = YES;
    self.account.pwd = self.pwdField.text.md5String;
    self.account.email = user.email;
    self.account.uid = [user objectForKey:@"uid"];
    self.account.gender = [user objectForKey:@"gender"];
    self.account.birthday = [user objectForKey:@"birthday"];
    self.account.icon = [user objectForKey:@"icon"];
    self.account.platformType = [[user objectForKey:@"platformType"] unsignedLongValue];
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"notes"];
    [bquery whereObjectKey:@"myNotes" relatedTo:[BmobUser currentUser]];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSMutableArray *memos = [NSMutableArray array];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            BmobObject *note = obj;
            HLMemo *memo = [[HLMemo alloc] init];
            memo.title = [note objectForKey:@"title"];
            memo.text = [note objectForKey:@"text"];
            memo.date = [note objectForKey:@"date"];
            [self insertNews:memo inArray:memos];
        }];
        self.account.notes = memos;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)insertNews:(HLMemo *)memo inArray:(NSMutableArray *)array {
    if (array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            HLMemo *tempMemo = array[i];
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"yyyy-MM-dd hh:mm:ss";
            NSComparisonResult result = [[fmt stringFromDate:memo.date] compare:[fmt stringFromDate:tempMemo.date]];
            if ((result == NSOrderedDescending) || (result == NSOrderedSame)) {
                [array insertObject:memo atIndex:i];
                return;
            } else if (i == array.count - 1) {
                [array addObject:memo];
                return;
            }
        }
    } else {
        [array addObject:memo];
    }
}

- (IBAction)login {
    [self.accountField resignFirstResponder];
    [self.pwdField resignFirstResponder];
    self.loginBtn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.loginBtn.enabled = YES;
    });
    [BmobUser loginInbackgroundWithAccount:self.accountField.text andPassword:self.pwdField.text.md5String block:^(BmobUser *user, NSError *error) {
        if (user) {
            [self setupAccountWithUser:user];
        } else {
            self.account.login = NO;
            [MBProgressHUD showError:@"用户名或密码错误" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.pwdField becomeFirstResponder];
            });
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (HLAccount *)account {
    if (!_account) {
        self.account = [HLAccount sharedAccount];
    }
    return _account;
}

@end
