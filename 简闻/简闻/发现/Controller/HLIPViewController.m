//
//  HLIPViewController.m
//  简闻
//
//  Created by 韩露露 on 16/5/2.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLIPViewController.h"
#import "HLLabel.h"
#import "HLWebTool.h"
#import "HLIPResponse.h"
#import "MBProgressHUD+MJ.h"
#import "HLNavView.h"

@interface HLIPViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet HLLabel *area;
@property (weak, nonatomic) IBOutlet HLLabel *location;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBtn;
@property (strong, nonatomic) HLNavView *titleView;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)search:(UIBarButtonItem *)sender;
@end

@implementation HLIPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
    self.titleView = [HLNavView titleView];
    self.navigationItem.titleView = self.titleView;
    self.titleView.titleSearch.delegate = self;
    self.titleView.titleSearch.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.titleView.titleSearch.returnKeyType = UIReturnKeySearch;
    self.titleView.titleSearch.placeholder = @"请输入IP地址/域名";
    [self.titleView.titleSearch becomeFirstResponder];
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
    if (self.titleView.titleSearch.text.length <= 0) {
        [self alertWithErrorCode:0 orMsg:@"请输入IP地址或域名"];
        return;
    }
    NSString *url = @"http://apis.juhe.cn/ip/ip2addr";
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"ip"] = self.titleView.titleSearch.text;
    parameter[@"key"] = @"324ab2a706fa8fdb364234a2e2f88bdf";
    __weak typeof(self) ipVc = self;
    [HLWebTool get:url param:parameter class:[HLIPResponse class] success:^(id responseObject) {
        ipVc.area.text = @"  ";
        ipVc.location.text = @"  ";
        HLIPResponse *response = responseObject;
        if ([response.reason isEqualToString:@"Return Successd!"]) {
            HLIPResult *result = response.result;
            ipVc.area.text = [ipVc.area.text stringByAppendingString:result.area ? result.area : @"无"];
            ipVc.location.text = [ipVc.location.text stringByAppendingString:result.location ? result.location : @"无"];
        } else {
            [ipVc alertWithErrorCode:response.error_code orMsg:nil];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接错误！" toView:ipVc.view];
    }];
}

- (void)alertWithErrorCode:(int)errorCode orMsg:(NSString *)msg {
    NSString *errorMsg = msg;
    if (errorCode == 200101) {
        errorMsg = @"ip地址不能为空";
    } else if (errorCode == 200102) {
        errorMsg = @"错误的IP地址";
    } else if (errorCode == 200103) {
        errorMsg = @"查询无结果";
    } else if (errorCode == 200104) {
        errorMsg = @"要查询的地址不能为空";
    } else if (errorCode == 200105) {
        errorMsg = @"查询无结果";
    }
    [MBProgressHUD showMessage:errorMsg toView:self.view];
    __weak typeof(self) ipVc = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:ipVc.view];
        [ipVc.titleView.titleSearch becomeFirstResponder];
    });
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
