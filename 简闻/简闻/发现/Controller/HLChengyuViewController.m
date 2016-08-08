//
//  HLChengyuViewController.m
//  简闻
//
//  Created by 韩露露 on 16/5/14.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLChengyuViewController.h"
#import "HLNavView.h"
#import "HLBarButtonItem.h"
#import "HLWebTool.h"
#import "MBProgressHUD+MJ.h"
#import "AFNetworking.h"
#import "HLChengyuResponse.h"
#import "HLChengyuCell.h"
#import "HLChengyuHeaderView.h"
#import "HLChengyuBottomFooterView.h"
#import "HLChengyuTopHeaderView.h"
#import "HLChengyuResult.h"

@interface HLChengyuViewController () <UITextFieldDelegate, HLChengyuHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBtn;
@property (strong, nonatomic) HLNavView *titleView;
@property (strong, nonatomic) HLChengyuResponse *response;
@property (strong, nonatomic) NSArray *allData;

- (IBAction)clickCancel:(UIBarButtonItem *)sender;
- (IBAction)search:(UIBarButtonItem *)sender;
@end

@implementation HLChengyuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancel.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
    self.titleView = [HLNavView titleView];
    self.navigationItem.titleView = self.titleView;
    self.titleView.titleSearch.delegate = self;
    self.titleView.titleSearch.keyboardType = UIKeyboardTypeDefault;
    self.titleView.titleSearch.returnKeyType = UIReturnKeySearch;
    self.titleView.titleSearch.placeholder = @"请输入成语";
    [self.titleView.titleSearch limitHansLength:4 otherLength:0];
    [self.titleView.titleSearch becomeFirstResponder];
    
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"HLChengyuHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"headerView"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:@"textFieldDidChange" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)textFieldDidChange:(NSNotification *)notif {
    NSDictionary *dict = notif.userInfo;
    if (![dict[@"otherLength"] integerValue]) {
        [self.titleView.titleSearch resignFirstResponder];
        [self alertWithMsg:@"只允许输入中文"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allData.count > 1 ? self.allData.count - 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    HLChengyuResult *result = self.allData[section + 1];
    return result.isClose ? 0 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLChengyuCell *cell = [HLChengyuCell cellWithTableView:tableView ForRowAtIndexPath:indexPath];
    cell.result = self.allData[indexPath.section + 1];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.allData.count) {
        HLChengyuHeaderView *header = [HLChengyuHeaderView headerViewWithTableView:tableView];
        header.delegate = self;
        header.result = self.allData[section + 1];
        if (header.result.isClose) {
            [header ChangeArrow:YES];
        } else {
            [header ChangeArrow:NO];
        }
        return header;
    } else {
        return nil;
    }
}

- (void)chengyuHeaderViewDidClickBtn:(HLChengyuHeaderView *)headerView {
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (IBAction)clickCancel:(UIBarButtonItem *)sender {
    [self.titleView.titleSearch endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)search:(UIBarButtonItem *)sender {
    [self.titleView.titleSearch resignFirstResponder];
    sender.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    if (self.titleView.titleSearch.text.length < 4) {
        [self alertWithMsg:@"请输入成语"];
        return;
    }
    NSString *url = @"http://v.juhe.cn/chengyu/query";
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"word"] = self.titleView.titleSearch.text;
    parameter[@"key"] = @"e7aef2df5803a36dbe2d2e70ee56da9d";
    
    [HLWebTool get:url param:parameter class:[HLChengyuResponse class] success:^(id responseObject) {
        self.response = responseObject;
        if ([self.response.reason isEqualToString:@"success"]) {
            self.allData = nil;
            
            HLChengyuTopHeaderView *header = [HLChengyuTopHeaderView topHeaderView];
            HLChengyuResult *result = self.allData[0];
            [header chengyu: self.titleView.titleSearch.text pinyin:result.text.firstObject];
            self.tableView.tableHeaderView = header;
            self.tableView.tableFooterView = [HLChengyuBottomFooterView bottomFooterView];
            self.tableView.sectionHeaderHeight = 70;
            
            [self.tableView reloadData];
        } else {
            [self alertWithMsg:@"请检查输入字词是否正确"];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接不稳定！" toView:self.view];
    }];
}

- (void)alertWithMsg:(NSString *)msg {
    if (self.searchBtn.enabled) {
        self.searchBtn.enabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.searchBtn.enabled = YES;
        });
    }
    [MBProgressHUD showMessage:msg toView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        [self.titleView.titleSearch becomeFirstResponder];
    });
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.titleView.titleSearch resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.titleView.titleSearch resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self search:self.searchBtn];
    return YES;
}

- (NSArray *)allData {
    if (!_allData) {
        if (self.response) {
            NSMutableArray *all = [NSMutableArray array];
            NSArray *allKey = self.response.allKey;
            for (int i = 0; i < allKey.count; i++) {
                HLChengyuResult *result = [[HLChengyuResult alloc] init];
                result.key = allKey[i];
                result.text = @[self.response.result[result.key]];
                [all addObject:result];
            }
            _allData = all;
        }
    }
    return _allData;
}

@end
