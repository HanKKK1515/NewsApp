//
//  HLMemoTableViewController.m
//  简闻
//
//  Created by 韩露露 on 16/4/21.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLMemoTableViewController.h"
#import "HLTool.h"
#import "HLMemo.h"
#import "HLMemoAddViewController.h"
#import "NSDate+HL.h"
#import "MBProgressHUD+MJ.h"
#import <BmobSDK/Bmob.h>

@interface HLMemoTableViewController () <UISearchControllerDelegate, UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editBtn;
@property (strong, nonatomic) HLAccount *account;
@property (strong, nonatomic) UISearchController *searchVc;

@property (strong, nonatomic) NSArray *listMemo;
@property (strong, nonatomic) NSArray *searchMemo;

@property (strong, nonatomic) UIImage *imageItem;

- (IBAction)addNote:(UIBarButtonItem *)sender;
- (IBAction)edit:(UIBarButtonItem *)sender;
@end

@implementation HLMemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 25);
    self.imageItem = [UIImage imageNamed:@"NavDustbin"];
    self.editBtn.image = self.imageItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.searchVc = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchVc.delegate = self;
    CGFloat version = [UIDevice currentDevice].systemVersion.floatValue;
    if (version >= 9.1) {
        self.searchVc.obscuresBackgroundDuringPresentation = NO;
    } else {
        self.searchVc.dimsBackgroundDuringPresentation = NO;
    }
    self.searchVc.searchResultsUpdater = self;
    self.definesPresentationContext = YES;
    
    self.searchVc.searchBar.tintColor = [UIColor orangeColor];
    self.searchVc.searchBar.barTintColor = [UIColor brownColor];
    [self.searchVc.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchVc.searchBar;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoDidChange:) name:@"memoDidChangeNotification" object:nil];
}

- (BOOL)verifyLogin {
    if (self.account.isLogin) {
        return YES;
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请先登录账号！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionYES = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"noteSegue" sender:nil];
        }];
        UIAlertAction *actionNO = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:actionYES];
        [alert addAction:actionNO];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)memoDidChange:(NSNotification *)notification {
    self.listMemo = notification.userInfo[@"userInfo"];
    if (!self.listMemo.count) {
        self.tableView.editing = NO;
        self.editBtn.image = self.imageItem;
        self.editBtn.title = nil;
    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        return 44;
    } else {
        return 54;
    }
}

#pragma mark - UISearchController代理方法
- (void)willPresentSearchController:(UISearchController *)searchController {
    if (self.tableView.isEditing) {
        [self edit:self.editBtn];
    }
}

#pragma mark - UISearchResultsUpdating代理方法
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self filterWithSubstr:searchController.searchBar.text];
}

- (void)filterWithSubstr:(NSString *)substr {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS[c] %@ || %K CONTAINS[c] %@", @"title", substr, @"text", substr];
    self.searchMemo = [self.listMemo filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchVc.isActive) {
        return self.searchMemo.count;
    } else {
        return self.listMemo.count;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"memoCell" forIndexPath:indexPath];
    HLMemo *memo = self.listMemo[indexPath.row];
    if (self.searchVc.isActive) {
        memo = self.searchMemo[indexPath.row];
    }
    UILabel *titelLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:3];
    titelLabel.text = memo.title;
    dateLabel.text = [NSDate timeIntervarWithDate:memo.date];
    contentLabel.text = memo.text;
    return cell;
}

- (IBAction)addNote:(UIBarButtonItem *)sender {
    if ([self verifyLogin]) {
        [self performSegueWithIdentifier:@"addSegue" sender:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self verifyLogin]) {
        [self performSegueWithIdentifier:@"addSegue" sender:self.listMemo[indexPath.row]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isMemberOfClass:HLMemo.class]) {
        HLMemoAddViewController *addVc = segue.destinationViewController;
        [addVc setDataWithMemo:sender];
    }
}

- (IBAction)edit:(UIBarButtonItem *)sender {
    if (![self verifyLogin]) return;
    
    if (self.listMemo.count || [self.editBtn.title isEqualToString:@"完成"]) {
        [self.tableView setEditing:!self.tableView.isEditing animated:YES];
        self.editBtn.image = self.tableView.isEditing ? nil : self.imageItem;
        self.editBtn.title = self.tableView.isEditing ? @"完成" : nil;
    } else {
        [MBProgressHUD showMessage:@"您还没有添加备忘呢!" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view];
        });
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"真删?";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        HLMemo *memo = self.listMemo[indexPath.row];
        [HLTool deleteWithObject:memo];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    if (self.tableView.isEditing) {
        [self edit:self.editBtn];
    }
    if (self.searchVc.isActive) {
        self.searchVc.active = NO;
        [self.searchVc.searchBar removeFromSuperview];
    }
}

- (NSArray *)listMemo {
    _listMemo = self.account.notes;
    return _listMemo;
}

- (HLAccount *)account {
    if (!_account) {
        self.account = [HLAccount sharedAccount];
    }
    return _account;
}

@end
