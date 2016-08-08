//
//  HLHomeViewController.m
//  简闻
//
//  Created by 韩露露 on 16/5/30.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLHomeViewController.h"
#import "HLWebTool.h"
#import "HLNewsResponse.h"
#import "HLNewsHotResponse.h"
#import "MBProgressHUD+MJ.h"
#import "HLNewsTableViewCell.h"
#import "HLNewsViewController.h"
#import "HLNavView.h"
#import "HLPostcodeFooterView.h"
#import "Reachability+AutoChecker.h"
#import "HLNewsHeaderView.h"

@interface HLHomeViewController () <UITextFieldDelegate, HLNewsHeaderViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *hot;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchBtn;
@property (strong, nonatomic) NSArray *hotNewsTitle; // 每次请求的热点新闻标题
@property (strong, nonatomic) NSMutableArray *hotNewsAllTitle; // 所有热点新闻标题
@property (strong, nonatomic) NSMutableArray *newsFirstes; // 搜索新闻的所有第一个结果
@property (strong, nonatomic) NSMutableArray *allNews; // 要显示的新闻数据
@property (strong, nonatomic) HLNavView *titleView;
@property (assign, nonatomic, getter = isAll) BOOL all;
@property (assign, nonatomic) int newCount;
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
    
    
    self.all = YES;
    [self setupRefresh];
}

- (void)setupRefresh {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([Reachability isReachable]) {
            [self refresh:nil];
        } else {
            [self performSelectorOnMainThread:@selector(warningNoNet) withObject:nil waitUntilDone:YES];
        }
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

- (void)showCountLabel:(int)count {
    UILabel *label = [[UILabel alloc] init];
    label.alpha = 0.0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    if (count) {
        if (self.isAll) {
            label.text = [NSString stringWithFormat:@"更新%lu条新闻", (unsigned long)count];
        } else {
            label.text = [NSString stringWithFormat:@"搜到%lu条相关新闻", (unsigned long)count];
        }
    } else {
        label.text = @"无更新数据";
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:10];
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_new_status_background"]];
    [self.navigationController.view insertSubview:label belowSubview:self.navigationController.navigationBar];
    
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.navigationController.navigationBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.navigationController.navigationBar attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:[UIScreen mainScreen].bounds.size.width];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:20];
    [self.navigationController.view addConstraints:@[bottom, centerX, width, height]];
    [UIView animateWithDuration:1 animations:^{
        label.alpha = 1.0;
        label.transform = CGAffineTransformMakeTranslation(0, 20);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 delay:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            label.alpha = 0.0;
            label.transform =CGAffineTransformMakeTranslation(0, 0);
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
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

- (void)getNewsHot {
    self.all = YES;
    NSString *url = @"http://op.juhe.cn/onebox/news/words";
    NSDictionary *attribute = @{@"key" : @"2acf8e073270584d037f5da1ba51fb24"};
    [HLWebTool get:url param:attribute class:[HLNewsHotResponse class] success:^(id responseObject) {
        HLNewsHotResponse *response = responseObject;
        if ([response.reason isEqualToString:@"查询成功"] && self.isAll) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"!SELF in %@", self.hotNewsAllTitle];
            self.hotNewsTitle = [response.result filteredArrayUsingPredicate:predicate];
            if (self.hotNewsTitle.count) {
                [self.hotNewsAllTitle addObjectsFromArray:self.hotNewsTitle];
                [self setData];
            } else {
                self.allNews = self.newsFirstes;
                [self stopRefreshWithTopCount:0];
                [self setupHeaderViewData];
                [self.tableView reloadData];
            }
        } else if (self.isAll) {
            self.allNews = self.newsFirstes;
            [self stopRefreshWithTopCount:0];
            [self setupHeaderViewData];
            [self.tableView reloadData];
        } else {
            [self.refreshControl endRefreshing];
        }
    } failure:^(NSError *error) {
        if (self.isAll) {
            self.allNews = self.newsFirstes;
            [self stopRefreshWithTopCount:0];
            [self setupHeaderViewData];
            [self.tableView reloadData];
            [MBProgressHUD showError:@"网络连接错误！" toView:self.view];
        } else {
            [self.refreshControl endRefreshing];
        }
    }];
}

- (void)setData {
    self.newCount = 0;
    int hotCount = (int)self.hotNewsTitle.count;
    __block int responseCount = 0;
    for (int i = 0; i < hotCount; i++) {
        NSString *keyword = self.hotNewsTitle[i];
        NSString *url = @"http://op.juhe.cn/onebox/news/query";
        NSDictionary *attribute = @{@"q" : keyword, @"key" : @"2acf8e073270584d037f5da1ba51fb24"};
        [HLWebTool get:url param:attribute class:[HLNewsResponse class] success:^(id responseObject) {
            HLNewsResponse *response = responseObject;
            if ([response.reason isEqualToString:@"查询成功"] && self.isAll) {
                HLNews *news = response.result.firstObject;
                [self insertNews:news inArray:self.newsFirstes];
                self.newCount++;
            }
            responseCount++;
            if (self.newCount == 1) {
                self.allNews = self.newsFirstes;
                [self setupHeaderViewData];
                [self.tableView reloadData];
            }
            if (!(responseCount % 10) && self.isAll) {
                self.allNews = self.newsFirstes;
                [self setupHeaderViewData];
                [self.tableView reloadData];
            }
            if (responseCount == hotCount) {
                if (self.isAll) {
                    self.allNews = self.newsFirstes;
                    [self stopRefreshWithTopCount:self.newCount];
                    [self setupHeaderViewData];
                    [self.tableView reloadData];
                } else {
                    [self.refreshControl endRefreshing];
                }
            }
        } failure:^(NSError *error) {
            responseCount++;
            if (responseCount == hotCount) {
                if (self.isAll) {
                    self.allNews = self.newsFirstes;
                    [self stopRefreshWithTopCount:self.newCount];
                    [self setupHeaderViewData];
                    [self.tableView reloadData];
                    [MBProgressHUD showError:@"网络连接不稳定,加载失败！" toView:self.view];
                } else {
                    [self.refreshControl endRefreshing];
                }
            }
        }];
    }
}

- (void)insertNews:(HLNews *)news inArray:(NSMutableArray *)array {
    if (array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            HLNews *tempNews = array[i];
            NSComparisonResult result = [news.pdate_src compare:tempNews.pdate_src];
            if ((result == NSOrderedDescending) || (result == NSOrderedSame)) {
                [array insertObject:news atIndex:i];
                return;
            } else if (i == array.count - 1) {
                [array addObject:news];
                return;
            }
        }
    } else {
        [array addObject:news];
    }
}

- (void)getNewsWithKeyword:(NSString *)keyword {
    self.all = NO;
    self.newCount = 0;
    NSString *url = @"http://op.juhe.cn/onebox/news/query";
    NSDictionary *attribute = @{@"q" : keyword, @"key" : @"2acf8e073270584d037f5da1ba51fb24"};
    [HLWebTool get:url param:attribute class:[HLNewsResponse class] success:^(id responseObject) {
        HLNewsResponse *response = responseObject;
        if ([response.reason isEqualToString:@"查询成功"] && !self.isAll) {
            self.allNews = response.result.mutableCopy;
            self.newCount = (int)response.result.count;
            [self setupHeaderViewData];
            [self.tableView reloadData];
        } else if (!self.isAll) {
            [MBProgressHUD showError:@"无相关新闻！" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.titleView.titleSearch becomeFirstResponder];
            });
        }
        if (self.isAll) {
            [self.refreshControl endRefreshing];
        } else {
            [self stopRefreshWithTopCount:self.newCount];
        }
    } failure:^(NSError *error) {
        if (self.isAll) {
            [self.refreshControl endRefreshing];
        } else {
            [self stopRefreshWithTopCount:0];
            [MBProgressHUD showError:@"网络连接错误！" toView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.titleView.titleSearch becomeFirstResponder];
            });
        }
    }];
}

- (void)setupHeaderViewData {
    if (self.allNews.count < minRow || !self.isAll) return;
    
    for (HLNews *new in self.headerNews) {
        [self insertNews:new inArray:self.allNews];
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
    [self.titleView.titleSearch resignFirstResponder];
    self.hot.enabled = NO;
    self.searchBtn.enabled = YES;
    [self startRefresh];
    [self getNewsHot];
    self.titleView.titleSearch.text = @"";
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
    [self getNewsWithKeyword:self.titleView.titleSearch.text];
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
                [self getNewsHot];
            } else {
                [self getNewsWithKeyword:self.titleView.titleSearch.text];
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self.titleView.titleSearch resignFirstResponder];
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

- (NSMutableArray *)newsFirstes {
    if (!_newsFirstes) {
        self.newsFirstes = [NSMutableArray array];
    }
    return _newsFirstes;
}

- (NSMutableArray *)hotNewsAllTitle {
    if (!_hotNewsAllTitle) {
        self.hotNewsAllTitle = [NSMutableArray array];
    }
    return _hotNewsAllTitle;
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
