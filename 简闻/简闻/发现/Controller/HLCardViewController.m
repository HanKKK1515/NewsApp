//
//  HLCardViewController.m
//  简闻
//
//  Created by 韩露露 on 16/5/2.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLCardViewController.h"
#import "HLLabel.h"
#import "HLCardResponse.h"
#import "HLWebTool.h"
#import "MBProgressHUD+MJ.h"
#import "HLNavView.h"

@interface HLCardViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet HLLabel *area;
@property (weak, nonatomic) IBOutlet HLLabel *sex;
@property (weak, nonatomic) IBOutlet HLLabel *birthDay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBtn;
@property (strong, nonatomic) HLNavView *titleView;

- (IBAction)search:(UIBarButtonItem *)sender;
- (IBAction)cancel:(UIBarButtonItem *)sender;
@end

@implementation HLCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
    self.titleView = [HLNavView titleView];
    self.navigationItem.titleView = self.titleView;
    self.titleView.titleSearch.delegate = self;
    self.titleView.titleSearch.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.titleView.titleSearch.returnKeyType = UIReturnKeySearch;
    self.titleView.titleSearch.placeholder = @"请输入15或18位身份证号";
    [self.titleView.titleSearch limitHansLength:18 otherLength:18];
    [self.titleView.titleSearch becomeFirstResponder];
}

- (void)alertWithErrorCode:(int)errorCode orMsg:(NSString *)msg {
    NSString *errorMsg = msg;
    if (errorCode == 203801) {
        errorMsg = @"请输入正确的15或18位身份证";
    } else if (errorCode == 203802) {
        errorMsg = @"错误的身份证或无结果";
    } else if (errorCode == 203803) {
        errorMsg = @"身份证校验位不正确";
    } else if (errorCode == 203804) {
        errorMsg = @"查询失败";
    }
    [MBProgressHUD showMessage:errorMsg toView:self.view];
    __weak typeof(self) cardVc = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:cardVc.view];
        [cardVc.titleView.titleSearch becomeFirstResponder];
    });
}

- (IBAction)search:(UIBarButtonItem *)sender {
    [self.titleView.titleSearch resignFirstResponder];
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    if (self.titleView.titleSearch.text.length < 15) {
        [self alertWithErrorCode:0 orMsg:@"请输入15或18位身份证号"];
        return;
    }
    NSString *url = @"http://apis.juhe.cn/idcard/index";
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"cardno"] = self.titleView.titleSearch.text;
    parameter[@"key"] = @"f283beb06bfc8fe7afbb002f992d81e9";
    parameter[@"dtype"] = @"JSON";
    
    __weak typeof(self) cardVc = self;
    [HLWebTool get:url param:parameter class:[HLCardResponse class] success:^(id responseObject) {
        cardVc.area.text = @"  ";
        cardVc.sex.text = @"  ";
        cardVc.birthDay.text = @"  ";
        HLCardResponse *response = responseObject;
        if ([response.reason isEqualToString:@"成功的返回"]) {
            HLCardResult *result = response.result;
            cardVc.area.text = [cardVc.area.text stringByAppendingString:result.area];
            cardVc.sex.text = [cardVc.sex.text stringByAppendingString:result.sex];
            cardVc.birthDay.text = [cardVc.birthDay.text stringByAppendingString:result.birthday];
        } else {
            [cardVc alertWithErrorCode:response.error_code orMsg:nil];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接不稳定！" toView:cardVc.view];
    }];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.titleView.titleSearch endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.titleView.titleSearch resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self search:self.searchBtn];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.titleView.titleSearch endEditing:YES];
}

@end
