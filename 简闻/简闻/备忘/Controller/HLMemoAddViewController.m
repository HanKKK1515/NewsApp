//
//  HLMemoAddViewController.m
//  简闻
//
//  Created by 韩露露 on 16/4/21.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLMemoAddViewController.h"
#import "HLMemo.h"
#import "HLTool.h"
#import "HLMemoTableViewController.h"
#import <BmobSDK/Bmob.h>

#define HLTextAddInsetBottom 5

@interface HLMemoAddViewController () <UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) HLMemo *memo;
@property (weak, nonatomic) IBOutlet UITextField *titleAdd; // 标题
@property (weak, nonatomic) IBOutlet UITextView *textAdd; // 正文
@property (weak, nonatomic) IBOutlet UIBarButtonItem *save;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomcons;
@property (assign, nonatomic) CGFloat margin; // 记录textAdd到底部的距离
@property (assign, nonatomic, getter = isChanging) BOOL changing; // textAdd的高度是否被提
- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)delete:(UIBarButtonItem *)sender;
- (IBAction)save:(UIBarButtonItem *)sender;
@end

@implementation HLMemoAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    self.cancelBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
    [self.titleAdd becomeFirstResponder];
    self.titleAdd.delegate = self;
    self.textAdd.delegate = self;
    self.textAdd.layer.cornerRadius = 5;
    self.deleBtn.title = nil;
    self.deleBtn.enabled = NO;
    self.margin = self.textViewBottomcons.constant;
    if (self.memo) {
        self.titleAdd.text = self.memo.title;
        self.textAdd.text = self.memo.text;
        self.deleBtn.title = @"删除";
        self.save.title = @"编辑";
        self.deleBtn.enabled = YES;
        self.titleAdd.enabled = NO;
        self.textAdd.editable = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    CGFloat duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    __weak typeof(self) memoVc = self;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardHeight = frame.size.height;
        
        if (memoVc.textAdd.isFirstResponder && !memoVc.isChanging) {
            memoVc.textViewBottomcons.constant = keyboardHeight - HLTextAddInsetBottom;
            memoVc.textAdd.scrollsToTop = NO;
            memoVc.textAdd.contentInset = UIEdgeInsetsMake(0, 0, HLTextAddInsetBottom, 0);
            memoVc.changing = YES;
        } else if (memoVc.titleAdd.isFirstResponder && memoVc.isChanging) {
            memoVc.textViewBottomcons.constant = memoVc.margin;
            memoVc.textAdd.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            memoVc.changing = NO;
        }
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    if (!self.isChanging) return;
    NSDictionary *dict = notification.userInfo;
    CGFloat duration = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    __weak typeof(self) memoVc = self;
    [UIView animateWithDuration:duration animations:^{
        memoVc.textViewBottomcons.constant = memoVc.margin;
        memoVc.textAdd.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        memoVc.changing = NO;
    }];
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.textAdd resignFirstResponder];
    [self.titleAdd resignFirstResponder];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)delete:(UIBarButtonItem *)sender {
    [self.textAdd resignFirstResponder];
    [self.titleAdd resignFirstResponder];
    __weak typeof(self) memoVc = self;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [memoVc.titleAdd becomeFirstResponder];
    }];
    UIAlertAction *actionDelete = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [HLTool deleteWithObject:memoVc.memo];
        [memoVc.navigationController popViewControllerAnimated:YES];
    }];
    [alert addAction:actionCancel];
    [alert addAction:actionDelete];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveData {
    [self.textAdd resignFirstResponder];
    [self.titleAdd resignFirstResponder];
    NSString *titleAdd = self.titleAdd.text;
    NSString *textAdd = self.textAdd.text;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH ' ' || SELF ENDSWITH ' '"];
    if (titleAdd && titleAdd.length > 0 && ![predicate evaluateWithObject:titleAdd]) {
        if (self.memo) {
            if (![self.memo.title isEqualToString:titleAdd] || ![self.memo.text isEqualToString:textAdd]) {
                self.memo.title = titleAdd;
                self.memo.text = textAdd;
                [HLTool modifyWithObject:self.memo];
            }
        } else {
            HLMemo *memo = [[HLMemo alloc] init];
            memo.title = self.titleAdd.text;
            memo.text = self.textAdd.text;
            [HLTool creatWithObject:memo];
        }
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        __weak typeof(self) memoVc = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"标题输入不正确！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionAbandon = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [memoVc.navigationController popViewControllerAnimated:YES];
        }];
        UIAlertAction *actionContinue = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [memoVc.titleAdd becomeFirstResponder];
        }];
        [alert addAction:actionAbandon];
        [alert addAction:actionContinue];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)save:(UIBarButtonItem *)sender {
    if ([self.save.title isEqualToString:@"保存"]) {
        if ([self verifyLogin]) {
            [self saveData];
        }
    } else if ([self.save.title isEqualToString:@"编辑"]) {
        self.save.title = @"保存";
        self.titleAdd.enabled = YES;
        self.textAdd.editable = YES;
        [self.textAdd becomeFirstResponder];
    }
}

- (BOOL)verifyLogin {
    if ([HLAccount sharedAccount].isLogin) {
        return YES;
    } else {
        __weak typeof(self) meVc = self;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先登录账号！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [meVc performSegueWithIdentifier:@"noteSegue" sender:nil];
        }];
        UIAlertAction *actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.titleAdd resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    __weak typeof(self) addVc = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [addVc.textAdd becomeFirstResponder];
    });
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.textAdd resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textAdd resignFirstResponder];
    [self.titleAdd resignFirstResponder];
}

- (void)setDataWithMemo:(HLMemo *)memo {
    self.memo = memo;
}

@end
