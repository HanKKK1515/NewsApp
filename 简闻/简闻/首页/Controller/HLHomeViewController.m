//
//  HLHomeViewController.m
//  简闻
//
//  Created by 韩露露 on 16/5/30.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLHomeViewController.h"
#import "HLWebTool.h"
#import "MBProgressHUD+MJ.h"
#import "HLNewsTableViewCell.h"
#import "HLNewsViewController.h"
#import "HLNavView.h"
#import "HLPostcodeFooterView.h"
#import "HLNewsHeaderView.h"
#import "HLShowRefreshCountTool.h"

@interface HLHomeViewController () <UITextFieldDelegate, HLNewsHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *hot;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBtn;
@property (strong, nonatomic) NSMutableArray *allNews; // 要显示的新闻数据
@property (strong, nonatomic) HLNavView *titleView;
@property (assign, nonatomic, getter = isAll) BOOL all;
@property (strong, nonatomic) HLPostcodeFooterView *footerView;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int refreshLoop;
@property (assign, nonatomic) int refreshCount;
@property (strong, nonatomic) HLNewsHeaderView *headerView;
@property (strong, nonatomic) NSMutableArray *headerNews;
@property (assign, nonatomic) NSUInteger selectHeaderItem;

- (IBAction)refresh:(UIBarButtonItem *)sender;
- (IBAction)search:(UIBarButtonItem *)sender;
@end

static const int minRow = 10;

@implementation HLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIApplication *app = [UIApplication sharedApplication];
    app.statusBarHidden = NO;
    app.statusBarStyle = UIStatusBarStyleLightContent;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self setMyFooterView];
    
    [self setNaviTitleView];
    
    [self setRefreshVc];
    
    [self setupNotifiction];
    
    self.all = YES;
    [HLWebTool getNewsFromCache:YES success:^(NSMutableArray *allNews) {
        if (allNews.count) {
            self.allNews = allNews;
        } else {
            [HLWebTool getNewsFromCache:NO success:^(NSMutableArray *allNews) {
                self.allNews = allNews;
            }];
        }
    }];
}

#pragma mark - 通知，监听数据的加载过程和结果
- (void)setupNotifiction {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopRefreshWithNewsCount:) name:@"stopRefreshWithNewsCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupHeaderViewData) name:@"setupHeaderViewData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWithData) name:@"reloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkError) name:@"networkError" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endHeaderRefreshing) name:@"endHeaderRefreshing" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNews) name:@"noNews" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleBecomeFirstResponder) name:@"titleBecomeFirstResponder" object:nil];
}

- (void)stopRefreshWithNewsCount:(NSNotification *)notif {
    int count = [notif.object intValue];
    [self stopRefreshWithTopCount:count];
}

- (void)reloadWithData {
    [self.tableView reloadData];
}

- (void)networkError {
    [MBProgressHUD showError:@"网络连接错误！" toView:self.view];
}

- (void)endHeaderRefreshing {
    [self.refreshControl endRefreshing];
}

- (void)noNews {
    [MBProgressHUD showError:@"无相关新闻！" toView:self.view];
}

- (void)titleBecomeFirstResponder {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.titleView.titleSearch becomeFirstResponder];
    });
}

- (void)warningNoNet {
    [MBProgressHUD showMessage:@"网络已断开，请检查网络设置！" toView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
    });
}

/**
 *  自动终止刷新refresh
 */
- (void)checkIsRefreshing {
    if (++self.refreshLoop <= 5) {
        self.refreshCount += (int)self.refreshControl.isRefreshing;
        if (self.refreshCount >= 5) {
            [self stopRefreshWithTopCount:0];
        }
    } else {
        self.refreshLoop = 1;
        self.refreshCount = 1;
    }
}

/**
 *  开启定时器
 */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self timer];
}

/**
 *  销毁定时器
 */
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setMyFooterView {
    self.tableView.tableFooterView = self.footerView;
    [self.footerView setFooterViewWithString:@"上拉刷新....."];
    [self.footerView stopActive];
    self.footerView.hidden = YES;
}

- (void)setNaviTitleView {
    self.titleView = [HLNavView titleView];
    self.navigationItem.titleView = self.titleView;
    self.titleView.titleSearch.delegate = self;
    self.titleView.titleSearch.keyboardType = UIKeyboardTypeDefault;
    self.titleView.titleSearch.returnKeyType = UIReturnKeySearch;
    self.titleView.titleSearch.placeholder = @"搜新闻";
}

- (void)setRefreshVc {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor orangeColor];
    self.refreshControl.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
    [self.refreshControl addTarget:self action:@selector(downRefresh) forControlEvents:UIControlEventValueChanged];
}

/**
 *  提醒新闻更新条数
 */
- (void)showCountLabel:(int)count {
    NSString *text = nil;
    if (count) {
        if (self.isAll) {
            text = [NSString stringWithFormat:@"更新%lu条新闻", (unsigned long)count];
        } else {
            text = [NSString stringWithFormat:@"搜到%lu条相关新闻", (unsigned long)count];
        }
    } else {
        text = @"无更新数据";
    }
    [HLShowRefreshCountTool showText:text inNavc:self.navigationController];
}

- (void)stopRefreshWithTopCount:(int)count {
    [self showCountLabel:count];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
            self.tableView.contentOffset = CGPointMake(0, 0);
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.refreshControl.isRefreshing) {
            self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"下拉刷新..."];
            self.hot.enabled = YES;
            self.searchBtn.enabled = YES;
        }
    });
    
    if (self.footerView.isActive) {
        [self.footerView setFooterViewWithString:@"上拉刷新....."];
        [self.footerView stopActive];
    }
}

- (void)startRefresh {
    [UIView animateWithDuration:0.4 animations:^{
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"正在刷新..."];
        self.tableView.contentOffset = CGPointMake(0, -82);
    } completion:^(BOOL finished) {
        if (!self.refreshControl.isRefreshing) {
            [self.refreshControl beginRefreshing];
        }
    }];
}

- (void)setupHeaderViewData {
    if (self.allNews.count < minRow || !self.isAll) return;
    
    for (HLNews *new in self.headerNews) {
        [HLWebTool insertNews:new inArray:self.allNews];
    }
    [self.headerNews removeAllObjects];
    
    NSMutableArray *urls = [NSMutableArray array];
    for (int i = 0; i < self.allNews.count; i++) {
        if (urls.count >= 3) break;
        HLNews *new = self.allNews[i];
        if (new.img.length > 3) {
            [urls addObject:new.img];
            [self.headerNews addObject:new];
            [self.allNews removeObject:new];
        }
    }
    self.headerView.icons = urls;
}

- (void)downRefresh {
    if (self.isAll) {
        [self refresh:nil];
    } else {
        [self search:nil];
    }
}

- (IBAction)refresh:(UIBarButtonItem *)sender {
    self.titleView.titleSearch.text = @"";
    [self.titleView.titleSearch resignFirstResponder];
    self.hot.enabled = NO;
    self.searchBtn.enabled = YES;
    [self startRefresh];
    
    self.all = YES;
    [HLWebTool getNewsFromCache:NO success:^(NSMutableArray *allNews) {
        self.allNews = allNews;
    }];
}

- (IBAction)search:(UIBarButtonItem *)sender {
    [self.titleView.titleSearch resignFirstResponder];
    if (self.titleView.titleSearch.text.length <= 0) {
        [MBProgressHUD showError:@"请输入关键字" toView:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.titleView.titleSearch becomeFirstResponder];
        });
        return;
    }
    self.searchBtn.enabled = NO;
    self.hot.enabled = YES;
    [self startRefresh];
    self.all = NO;
    [HLWebTool getNewsWithKeyword:self.titleView.titleSearch.text success:^(NSMutableArray *allNews) {
        self.allNews = allNews.mutableCopy;
    }];
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HLNewsTableViewCell *cell = [HLNewsTableViewCell cellWithTableView:tableView indexPath:indexPath];
    HLNews *news = self.allNews[indexPath.row];
    cell.news = news;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.footerView.hidden = (self.allNews.count < minRow);
    if (section == 1) {
        return self.allNews.count;
    }
    return 0;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.isAll) {
        return self.headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.isAll) {
        return self.headerView.bounds.size.height;
    }
    return 0;
}

#pragma mark - HLNewsHeaderViewDelegate
- (void)headerView:(HLNewsHeaderView *)headerView didSelectItem:(NSUInteger)item {
    self.selectHeaderItem = item;
    [self performSegueWithIdentifier:@"headerSegue" sender:headerView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.titleView.titleSearch.isFirstResponder) {
        [self.titleView.titleSearch resignFirstResponder];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat showH = scrollView.contentSize.height - self.view.frame.size.height + self.footerView.frame.size.height + 64;
    int newsCount = 0;
    if (self.footerView.isActive || offsetY <= 0 || showH <= 0) return;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        newsCount = minRow;
    } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        newsCount = minRow;
    }
    if (self.allNews.count <= newsCount) {
        if (offsetY >= (scrollView.contentSize.height - self.view.frame.size.height + 12)) {
            scrollView.contentOffset = CGPointMake(0, scrollView.contentSize.height - self.view.frame.size.height + 12);
            scrollView.scrollEnabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                scrollView.scrollEnabled = YES;
            });
        }
        return;
    }
    if (offsetY >= (showH - 0)) {
        [self.footerView setFooterViewWithString:@"正在拼命加载中....."];
        [self.footerView startActive];
        scrollView.contentOffset = CGPointMake(0, scrollView.contentSize.height - self.view.frame.size.height + 64);
        scrollView.scrollEnabled = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            scrollView.scrollEnabled = YES;
            if (self.isAll) {
                [HLWebTool getNewsFromCache:NO success:^(NSMutableArray *allNews) {
                    self.allNews = allNews;
                }];
            } else {
                self.all = NO;
                [HLWebTool getNewsWithKeyword:self.titleView.titleSearch.text success:^(NSMutableArray *allNews) {
                    self.allNews = allNews.mutableCopy;
                }];
            }
        });
    }
}

#pragma mark -
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (self.titleView.titleSearch.isFirstResponder) {
        [self.titleView.titleSearch resignFirstResponder];
    }
    
    HLNewsViewController *vc = segue.destinationViewController;
    HLNews *news = nil;
    if ([sender isKindOfClass:HLNewsHeaderView.class]) {
        news = self.headerNews[self.selectHeaderItem];
    } else if ([sender isKindOfClass:HLNewsTableViewCell.class]) {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        news = self.allNews[indexPath.row];
    }
    vc.url = news.url;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self search:self.searchBtn];
    return YES;
}

#pragma mark - 懒加载
- (NSMutableArray *)allNews {
    if (!_allNews) {
        self.allNews = [NSMutableArray array];
    }
    return _allNews;
}

- (HLPostcodeFooterView *)footerView {
    if (!_footerView) {
        self.footerView = [HLPostcodeFooterView postcodeFooterView];
    }
    return _footerView;
}

- (NSTimer *)timer {
    if (!_timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(checkIsRefreshing) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (HLNewsHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [HLNewsHeaderView headerView];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (NSMutableArray *)headerNews {
    if (!_headerNews) {
        _headerNews = [NSMutableArray array];
    }
    return _headerNews;
}

@end
