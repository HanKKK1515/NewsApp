//
//  HLPhoneViewController.m
//  简闻
//
//  Created by 韩露露 on 16/5/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLPhoneViewController.h"
#import "HLLabel.h"
#import "HLButton.h"
#import "HLWebTool.h"
#import "HLPhoneResponse.h"
#import "MBProgressHUD+MJ.h"
#import "HLNavView.h"

@interface HLPhoneViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet HLLabel *province;
@property (weak, nonatomic) IBOutlet HLLabel *city;
@property (weak, nonatomic) IBOutlet HLLabel *sp;
@property (weak, nonatomic) IBOutlet HLLabel *rpt_type;
@property (weak, nonatomic) IBOutlet HLLabel *countDesc;
@property (weak, nonatomic) IBOutlet HLLabel *detail;
@property (strong, nonatomic) HLNavView *titleView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBtn;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)search:(UIBarButtonItem *)sender;
@end

@implementation HLPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
    self.titleView = [HLNavView titleView];
    self.navigationItem.titleView = self.titleView;
    self.titleView.titleSearch.delegate = self;
    self.titleView.titleSearch.keyboardType = UIKeyboardTypeNumberPad;
    self.titleView.titleSearch.returnKeyType = UIReturnKeySearch;
    self.titleView.titleSearch.placeholder = @"请输入固话/手机号码前7位";
    [self.titleView.titleSearch becomeFirstResponder];
    [self.titleView.titleSearch limitHansLength:11 otherLength:11];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.titleView.titleSearch endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)search:(UIBarButtonItem *)sender {
    [self.titleView.titleSearch resignFirstResponder];
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    if (self.titleView.titleSearch.text.length < 7) {
        [self alertWithErrorCode:0 orMsg:@"至少输入手机号码前7位"];
        return;
    }
    
    NSString *url = @"http://op.juhe.cn/onebox/phone/query";
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"key"] = @"21668cb31086ed9591b9b5dac1136113";
    parameter[@"tel"] = self.titleView.titleSearch.text;
    __weak typeof(self) cardVc = self;
    [HLWebTool get:url param:parameter class:[HLPhoneResponse class] success:^(id responseObject) {
        HLPhoneResponse *response = responseObject;
        if ([response.reason isEqualToString:@"查询成功"]) {
            HLPhoneResult *result = response.result;
            cardVc.province.text = result.province.length ? result.province : @"无";
            cardVc.city.text = result.city.length ? result.city : @"无";
            cardVc.sp.text = result.sp.length ? result.sp : @"无";
            cardVc.rpt_type.text = result.rpt_type.length ? result.rpt_type : @"无";
            cardVc.countDesc.text = result.countDesc.length ? result.countDesc : @"无";
            cardVc.detail.text = result.hyname.length ? result.hyname : @"无";
        } else {
            [cardVc alertWithErrorCode:response.error_code orMsg:nil];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接不稳定！" toView:cardVc.view];
    }];
}

- (void)alertWithErrorCode:(int)errorCode orMsg:(NSString *)msg {
    NSString *errorMsg = msg;
    if (errorCode == 207201) {
        errorMsg = @"查询的号码不能为空";
    } else if (errorCode == 207202) {
        errorMsg = @"查询不到相关信息";
    } else if (errorCode == 207203) {
        errorMsg = @"网络错误，请重试";
    }
    __weak typeof(self) cardVc = self;
    [MBProgressHUD showMessage:errorMsg toView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:cardVc.view];
        [cardVc.titleView.titleSearch becomeFirstResponder];
    });
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.titleView.titleSearch resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.titleView.titleSearch endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self search:self.searchBtn];
    return YES;
}

@end
