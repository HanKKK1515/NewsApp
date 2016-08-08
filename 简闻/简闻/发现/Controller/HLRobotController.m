//
//  HLRobotController.m
//  简闻
//
//  Created by 韩露露 on 16/5/21.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLRobotController.h"
#import "HLRobotToolBar.h"
#import "HLRobotResponse.h"
#import "HLWebTool.h"
#import "HLRobotCellData.h"
#import "HLRobotToolBar.h"
#import "MBProgressHUD+MJ.h"
#import "NSDate+HL.h"
#import "HLRobotCell.h"
#import "HLUserCell.h"
#import "HLMore.h"
#import "HLHomeViewController.h"
#import "HLTool.h"

@interface HLRobotController () <UITableViewDelegate, UITableViewDataSource, HLRobotToolBarDelegate, HLMoreDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *moreBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet HLRobotToolBar *toolBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;
@property (strong, nonatomic) NSArray *chatData;

- (IBAction)cancel:(UIBarButtonItem *)sender;
- (IBAction)more:(UIBarButtonItem *)sender;
@property (weak, nonatomic) HLMore *more;
@property (assign, nonatomic, getter = isShow) BOOL show;
@end

@implementation HLRobotController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
    self.moreBtn.imageInsets = UIEdgeInsetsMake(0, 0, 3, 9);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.toolBar.delegate = self;
    
    [self setupNotif];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableView:)];
    [self.tableView addGestureRecognizer:tap];
}

- (void)setupNotif {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolBarTextViewDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolBarBeginEditing:) name:@"toolBarBeginEditing" object:self.toolBar];
}

- (void)tapTableView:(UITapGestureRecognizer *)tap {
    if (self.isShow) {
        [self more:nil];
    }
    [self.toolBar toolBarResignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.isShow) {
        [self more:nil];
    }
    [self.toolBar toolBarResignFirstResponder];
}

- (void)toolBarBeginEditing:(NSNotification *)notif {
    if (self.isShow) {
        [self more:nil];
    }
}

- (void)toolBarTextViewDidChange:(NSNotification *)notif {
    if (self.isShow) {
        [self more:nil];
    }
    UITextView *textView = notif.object;
    CGFloat height = textView.contentSize.height;
    if (height > 40 && height < 80) {
        self.textViewHeight.constant = height;
    } else if (height >= 80) {
        self.textViewHeight.constant = 80;
    } else {
        self.textViewHeight.constant = 30;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.chatData.count) {
        HLRobotCellData *cellData = [[HLRobotCellData alloc] init];
        cellData.text = @"陛下万福，臣妾已在此恭候多时！";
        cellData.date = [NSDate date];
        cellData.type = HLRobotTypeRobot;
        [HLTool creatWithObject:cellData];
        [self.tableView reloadData];
    }
    [self.toolBar toolBarBecomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notif {
    if (self.isShow) {
        [self more:nil];
    }
    NSDictionary *dict = notif.userInfo;
    CGFloat height = [dict[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.toolBarBottomCon.constant = height;
    CGFloat time = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:time animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self scrollViewToBottom];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if (self.isShow) {
        [self more:nil];
    }
    self.toolBarBottomCon.constant = 0;
    NSDictionary *dict = notif.userInfo;
    CGFloat time = [dict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:time animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)robotToolBar:(HLRobotToolBar *)bar text:(NSString *)text {
    if (self.isShow) {
        [self more:nil];
    }
    if (text.length <= 0) {
        [self alertWithErrorCode:0 orMsg:@"不能发送空的内容"];
        return;
    }
    if (text.length >= 20) {
        [self alertWithErrorCode:0 orMsg:@"不能超过20个汉字"];
        return;
    }
    [self.toolBar clearText];
    HLRobotCellData *meData = [[HLRobotCellData alloc] init];
    meData.text = text;
    meData.date = [NSDate date];
    meData.type = HLRobotTypeMe;
    [HLTool creatWithObject:meData];
    [self.tableView reloadData];
    [self scrollViewToBottom];
    self.textViewHeight.constant = 30;
    
    NSString *url = @"http://op.juhe.cn/robot/index";
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"info"] = text;
    parameter[@"key"] = @"73dfd78917809e82552a5849b6a410c2";
    
    [HLWebTool get:url param:parameter class:[HLRobotResponse class] success:^(id responseObject) {
        HLRobotResponse *response = responseObject;
        if ([response.reason isEqualToString:@"成功的返回"]) {
            HLRobotCellData *robotData = [[HLRobotCellData alloc] init];
            robotData.text = response.result.text;
            robotData.date = [NSDate date];
            robotData.type = HLRobotTypeRobot;
            [HLTool creatWithObject:robotData];
            [self.tableView reloadData];
            [self scrollViewToBottom];
        } else {
            [self alertWithErrorCode:response.error_code orMsg:nil];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接错误！" toView:self.view];
    }];
}

- (void)scrollViewToBottom {
    if (self.chatData.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.chatData.count - 1  inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)alertWithErrorCode:(int)errorCode orMsg:(NSString *)msg {
    NSString *errorMsg = msg;
    if (errorCode == 211200) {
        errorMsg = @"网络错误，请重试";
    } else if (errorCode == 211201) {
        errorMsg = @"输入内容无效";
    } else if (errorCode == 211202) {
        errorMsg = @"内容不能超过30字";
    } else if (errorCode == 211203) {
        errorMsg = @"服务器异常";
    } else if (errorCode == 211204) {
        errorMsg = @"未知错误";
    } else if (errorCode == 211205) {
        errorMsg = @"未知错误";
    }
    [self.toolBar toolBarResignFirstResponder];
    [MBProgressHUD showMessage:errorMsg toView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        [self.toolBar toolBarBecomeFirstResponder];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatData.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLRobotCellData *data = self.chatData[indexPath.row];
    if (indexPath.row > 0) {
        HLRobotCellData *lastSecond = self.chatData[indexPath.row - 1];
        if ([[NSDate timeIntervarWithDate:data.date] isEqualToString:[NSDate timeIntervarWithDate:lastSecond.date]]) {
            data.hiddenTime = YES;
        } else {
            data.hiddenTime = NO;
        }
    } else {
        data.hiddenTime = NO;
    }
    
    HLRobotCell *cellR = nil;
    HLUserCell *cellU = nil;
    if (data.type == HLRobotTypeRobot) {
        cellR = [HLRobotCell cellWithTableView:tableView indexPath:indexPath];
        cellR.cellData = data;
        return cellR;
    } else {
        cellU = [HLUserCell cellWithTableView:tableView indexPath:indexPath];
        cellU.cellData = data;
        return cellU;
    }
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)more:(UIBarButtonItem *)sender {
    if ((self.show = !self.isShow)) {
        self.more = [HLMore more];
        self.more.delegate = self;
        [self.view addSubview:self.more];
        self.more.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.more attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:64];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.more attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:-10];
        [self.view addConstraints:@[top, right]];
    } else {
        [self.more removeFromSuperview];
    }
}

- (void)more:(HLMore *)more didSelectedType:(HLMoreType)type {
    [self more:nil];
    if (type == kHLMoreTypeHome) {
        [self.toolBar toolBarResignFirstResponder];
        [self.tabBarController setSelectedIndex:0];
        [self.navigationController popViewControllerAnimated:NO];
    } else if (type == kHLMoreTypeTop) {
        if (self.chatData.count) {
            [self.toolBar toolBarResignFirstResponder];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    } else if (type == kHLMoreTypeBottom) {
        if (self.chatData.count) {
            [self.toolBar toolBarResignFirstResponder];
            [self scrollViewToBottom];
        }
    } else if (type == kHLMoreTypeClearContent) {
        [self clearContent];
    }
}

- (void)clearContent {
    if (self.chatData.count) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注意" message:@"确定要删除所有聊天内容吗？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [HLTool clearAllDataWithFileName:@"robot.rrr"];
            [self.tableView reloadData];
        }];
        UIAlertAction *actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [MBProgressHUD showMessage:@"无聊天内容" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
    }
}

- (NSArray *)chatData {
    NSArray *array = [HLTool listAllDataWithFileName:@"robot.rrr"];
    return array ? array : [NSArray array];
}

@end
