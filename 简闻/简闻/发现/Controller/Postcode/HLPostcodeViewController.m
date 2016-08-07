//
//  HLPostcodeViewController.m
//  简闻
//
//  Created by 韩露露 on 16/5/4.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLPostcodeViewController.h"
#import "HLPostcodeHeaderView.h"
#import "HLPostcodeHeaderSecondView.h"
#import "HLSecondTextField.h"
#import "HLWebTool.h"
#import "HLPostcodeParameter.h"
#import "HLPostcodeAddressResponse.h"
#import "MBProgressHUD+MJ.h"
#import "HLPostcodeFooterView.h"
#import "HLPostcodeCityListResponse.h"
#import "HLPostcodeAddressController.h"

@interface HLPostcodeViewController () <HLPostcodeHeaderViewDelegate, HLPostcodeHeaderSecondViewDelegate, UITextFieldDelegate, HLPostcodeAddressDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (strong, nonatomic) HLPostcodeFooterView *footerView;
@property (strong, nonatomic) NSArray *currentAllList; // 存储当前的tableViwCell数据，用于切换

@property (strong, nonatomic) HLPostcodeAddressResult *currentResult; // firstHeader搜索到的数据相应
@property (strong, nonatomic) NSArray *cityList; // firstHeader搜索到的数据数组
@property (strong, nonatomic) HLPostcodeHeaderView *headerView;; // firstHeader

@property (strong, nonatomic) NSArray *citySecondeList; // secondHeader搜索到的数据数组
@property (strong, nonatomic) HLPostcodeHeaderSecondView *headerSecondView; // secondHeader
@property (strong, nonatomic) HLPostcodeCityListResponse *allCityData; // secondHeader全国所有城市列表
@property (weak, nonatomic) HLPostcodeProvinceList *currentProvince; // secondHeader省
@property (weak, nonatomic) HLPostcodeCityList *currentCity; // secondHeader市
@property (weak, nonatomic) HLPostcodeDistrict *currentDistrict; // secondHeader区
@property (weak, nonatomic) HLPostcodeAddressController *addressVc; // secondHeader弹窗

- (IBAction)clickSegment;
- (IBAction)cancel:(UIBarButtonItem *)sender;
@end

@implementation HLPostcodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cancelBtn.imageInsets = UIEdgeInsetsMake(10, -5, 7, 10);
    [self setupAllCityData];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"HLPostcodeFooterView" bundle:nil] forCellReuseIdentifier:@"footerViewID"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didClickTextFieldBtn:) name:@"didClickTextFieldBtn" object:nil];
}

- (void)didClickTextFieldBtn:(NSNotification *)notification {
    HLSecondTextField *textField = notification.object;
    [self textFieldShouldBeginEditing:textField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 1) {
        self.addressVc.allData = self.allCityData;
        self.currentCity = nil;
        self.headerSecondView.province.text = @"";
        self.headerSecondView.district.text = @"";
        self.headerSecondView.district.enabled = NO;
        self.headerSecondView.keyword.enabled = NO;
        
        self.addressVc.popoverPresentationController.sourceView = self.headerSecondView.province;
        self.addressVc.popoverPresentationController.sourceRect = self.headerSecondView.province.bounds;
        __weak typeof(self) postcodeVc = self;
        [self presentViewController:self.addressVc animated:YES completion:^{
            [postcodeVc.headerSecondView hiddenKeyboard];
        }];
        return NO;
    } else if (textField.tag == 2) {
        if (self.currentCity) {
            self.addressVc.cityData = self.currentCity;
            
            self.addressVc.popoverPresentationController.sourceView = self.headerSecondView.district;
            self.addressVc.popoverPresentationController.sourceRect = self.headerSecondView.district.bounds;
            
            __weak typeof(self) postcodeVc = self;
            [self presentViewController:self.addressVc animated:YES completion:^{
                [postcodeVc.headerSecondView hiddenKeyboard];
            }];
        } else {
            [self alertWithErrorCode:0 orMsg:@"请先选择省市"];
        }
        return NO;
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.headerSecondView.district.enabled = self.currentCity != nil;
    self.headerSecondView.keyword.enabled = self.currentCity != nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.headerSecondView hiddenKeyboard];
}

/**
 *  addressVC的代理方法
 */
- (void)postcodeAddressController:(HLPostcodeAddressController *)vc withChoiceObjects:(NSDictionary *)objects {
    __weak typeof(self) postcodeVc = self;
    [objects enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isMemberOfClass:[HLPostcodeProvinceList class]]) {
            postcodeVc.currentProvince = obj;
        }  else if ([obj isMemberOfClass:[HLPostcodeCityList class]]) {
            postcodeVc.currentCity = obj;
            postcodeVc.headerSecondView.district.enabled = postcodeVc.currentCity != nil;
            postcodeVc.headerSecondView.keyword.enabled = postcodeVc.currentCity != nil;
            
            NSString *city = nil;
            if ([postcodeVc.currentProvince.province isEqualToString:postcodeVc.currentCity.city]) {
                city = postcodeVc.currentProvince.province;
            } else {
                city = [NSString stringWithFormat:@"%@%@", postcodeVc.currentProvince.province, postcodeVc.currentCity.city];
            }
            postcodeVc.headerSecondView.province.text = city;
        } else if ([obj isMemberOfClass:[HLPostcodeDistrict class]]) {
            postcodeVc.currentDistrict = obj;
            postcodeVc.headerSecondView.district.text = postcodeVc.currentDistrict.district;
        }
    }];
    [self.addressVc dismissViewControllerAnimated:NO completion:nil];
}

/**
 * headerSecondeView的代理方法，点击搜索按钮触发
 */
- (void)postcodeHeaderSecondViewDidClickbtn:(HLPostcodeHeaderSecondView *)view {
    [self.headerSecondView hiddenKeyboard];
    view.btnEnable = NO;
    __weak typeof(self) poVc = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        poVc.headerSecondView.btnEnable = YES;
    });
    if (self.headerSecondView.province.text.length < 1) {
        [self alertWithErrorCode:0 orMsg:@"请选择省市"];
        return;
    }
    NSString *url = @"http://v.juhe.cn/postcode/search";
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"key"] = @"eb320dda57d458cc1a237acda8168c76";
    parameter[@"pid"] = self.currentProvince.id;
    parameter[@"cid"] = self.currentCity.id;
    if (self.currentDistrict.district.length) {
        parameter[@"did"] = self.currentDistrict.id;
    }
    if (self.headerSecondView.keyword.text.length) {
        parameter[@"q"] = self.headerSecondView.keyword.text;
    }
    
    [self searchDataWithURL:url parameter:parameter removeOldData:YES];
}

/**
 * headerView的代理方法，点击搜索按钮触发
 */
- (void)postcodeHeaderView:(HLPostcodeHeaderView *)postcodeHeaderView{
    [self.headerView hiddenKeyboard];
    self.headerView.btnEnable = NO;
    __weak typeof(self) poVc = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        poVc.headerView.btnEnable = YES;
    });
    if (self.headerView.searchText.text.length < 1) {
        [self alertWithErrorCode:0 orMsg:@"你还没有输入"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [poVc.headerView showKeyboard];
        });
        return;
    }
    NSString *url = @"http://v.juhe.cn/postcode/query";
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"postcode"] = self.headerView.searchText.text;
    parameter[@"key"] = @"eb320dda57d458cc1a237acda8168c76";
    parameter[@"page"] = @(1);
    [self searchDataWithURL:url parameter:parameter removeOldData:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.segment.selectedSegmentIndex) {
        [self postcodeHeaderView:self.headerView];
    } else {
        [self postcodeHeaderSecondViewDidClickbtn:self.headerSecondView];
    }
    return YES;
}

- (void)searchDataWithURL:(NSString *)url parameter:(NSMutableDictionary *)attribute removeOldData:(BOOL)remove {
    __weak typeof(self) poVc = self;
    [HLWebTool get:url param:attribute class:[HLPostcodeAddressResponse class] success:^(id responseObject) {
        HLPostcodeAddressResponse *response = responseObject;
        if ([response.reason isEqualToString:@"successed"]) {
            poVc.currentResult = response.result;
            if (remove) {
                poVc.currentAllList = nil;
            }
            if (poVc.currentResult.totalcount.integerValue) {
                poVc.currentAllList = [poVc.currentAllList arrayByAddingObjectsFromArray:poVc.currentResult.list];
            } else {
                [MBProgressHUD showError:@"未查询到数据" toView:poVc.view];
            }
        } else {
            [poVc alertWithErrorCode:response.error_code orMsg:nil];
        }
        [poVc.tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接不稳定！" toView:poVc.view];
        [poVc.tableView reloadData];
    }];
}

- (void)alertWithErrorCode:(int)errorCode orMsg:(NSString *)msg {
    NSString *errorMsg = msg;
    if (errorCode == 206601) {
        errorMsg = @"错误的邮编号码";
    } else if (errorCode == 206602) {
        errorMsg = @"错误的省份";
    } else if (errorCode == 206603) {
        errorMsg = @"错误的城市";
    } else if (errorCode == 206604) {
        errorMsg = @"错误的地区";
    }
    __weak typeof(self) poVc = self;
    [MBProgressHUD showMessage:errorMsg toView:self.view];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:poVc.view];
        if (poVc.segment.selectedSegmentIndex) {
            [poVc.headerView showKeyboard];
        }
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.currentAllList.count >= 20) {
        return self.currentAllList.count + 1;
    } else {
        return self.currentAllList.count;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.currentAllList.count) {
        static NSString *footerIdentifier = @"footerViewID";
        if (!self.footerView) {
            self.footerView = [tableView dequeueReusableCellWithIdentifier:footerIdentifier forIndexPath:indexPath];
        }
        
        [self.footerView stopActive];
        if (self.currentResult.currentpage.integerValue < self.currentResult.totalpage.integerValue ) {
            [self.footerView setFooterViewWithString:[NSString stringWithFormat:@"上拉刷新(%@/%@页)", self.currentResult.currentpage, self.currentResult.totalpage]];
        } else {
            [self.footerView setFooterViewWithString:[NSString stringWithFormat:@"加载完毕(%@页)", self.currentResult.totalpage]];
        }
        
        return self.footerView;
    } else {
        static NSString *identifier = @"postcodeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:245/255.0 green:131/255.0 blue:7/255.0 alpha:1.0];
        HLPostcodeAddressResultCity *city = self.currentAllList[indexPath.row];
        UILabel *province = (UILabel *)[cell viewWithTag:1];
        UILabel *postcode = (UILabel *)[cell viewWithTag:2];
        UILabel *address = (UILabel *)[cell viewWithTag:3];
        province.text = city.Province;
        postcode.text = city.PostNumber;
        address.text = [NSString stringWithFormat:@"%@%@%@", city.City, city.District, city.Address];
        return cell;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.headerView hiddenKeyboard];
    [self.headerSecondView hiddenKeyboard];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.footerView.isActive || self.currentResult.currentpage.integerValue  >= self.currentResult.totalpage.integerValue || self.currentAllList.count <= 0) return;
    if (scrollView.contentOffset.y > scrollView.contentSize.height - self.view.frame.size.height + self.footerView.frame.size.height) {
        [self.footerView setFooterViewWithString:@"正在拼命加载中……"];
        [self.footerView startActive];
        scrollView.contentOffset = CGPointMake(0, scrollView.contentSize.height - self.view.frame.size.height);
        scrollView.scrollEnabled = NO;
        __weak typeof(self) postcodeVc = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            scrollView.scrollEnabled = YES;
            [postcodeVc loadMoreData];
        });
    }
}

- (void)loadMoreData {
    NSString *url = nil;
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"key"] = @"eb320dda57d458cc1a237acda8168c76";
    NSUInteger page = self.currentResult.currentpage.integerValue;
    parameter[@"page"] = @(++page);
    if (self.segment.selectedSegmentIndex) {
        url = @"http://v.juhe.cn/postcode/query";
        parameter[@"postcode"] = self.headerView.searchText.text;
    } else {
        url = @"http://v.juhe.cn/postcode/search";
        parameter[@"pid"] = self.currentProvince.id;
        parameter[@"cid"] = self.currentCity.id;
        if (self.currentDistrict.district.length) {
            parameter[@"did"] = self.currentDistrict.id;
        }
        if (self.headerSecondView.keyword.text.length) {
            parameter[@"q"] = self.headerSecondView.keyword.text;
        }
    }
    [self searchDataWithURL:url parameter:parameter removeOldData:NO];
}

- (IBAction)clickSegment {
    if (self.segment.selectedSegmentIndex) {
        self.citySecondeList = self.currentAllList;
        self.currentAllList = self.cityList;
        if (!self.currentAllList.count) {
            [self.headerView showKeyboard];
        }
    } else {
        [self.headerView hiddenKeyboard];
        self.cityList = self.currentAllList;
        self.currentAllList = self.citySecondeList;
    }
    
    [self.tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.segment.selectedSegmentIndex) {
        return self.headerView;
    } else {
        return self.headerSecondView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.segment.selectedSegmentIndex) {
        return 44;
    } else {
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            return 65;
        }
        return 55;
    }
}

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setConstrainWithView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    CGFloat height = 44;
    if ([view isMemberOfClass:[HLPostcodeHeaderSecondView class]]) {
        height = 55;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
           height = 65;
        }
    }
    NSLayoutConstraint *heightCon = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:height];
    NSLayoutConstraint *widthCon = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1 constant:self.view.frame.size.width];
    [view addConstraints:@[heightCon, widthCon]];
}

- (void)setupAllCityData {
    self.allCityData = [[HLPostcodeCityListResponse alloc] init];
    NSString *url = @"http://v.juhe.cn/postcode/pcd";
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    parameter[@"key"] = @"eb320dda57d458cc1a237acda8168c76";
    __weak typeof(self) poVc = self;
    [HLWebTool get:url param:parameter class:[HLPostcodeCityListResponse class] success:^(id responseObject) {
        HLPostcodeCityListResponse *response = responseObject;
        if ([response.reason isEqualToString:@"successed"]) {
            poVc.allCityData = response;
            poVc.addressVc.allData = poVc.allCityData;
        }
    } failure:^(NSError *error) {
        [MBProgressHUD showError:@"网络连接错误！" toView:poVc.view];
    }];
}

- (HLPostcodeHeaderView *)headerView {
    if (!_headerView) {
        self.headerView = [HLPostcodeHeaderView postcodeHeaderView];
        self.headerView.delegate = self;
        [self setConstrainWithView:self.headerView];
    }
    return _headerView;
}

- (HLPostcodeHeaderSecondView *)headerSecondView {
    if (!_headerSecondView) {
        self.headerSecondView = [HLPostcodeHeaderSecondView postcodeHeaderSecondView];
        self.headerSecondView.delegate = self;
        [self setConstrainWithView:self.headerSecondView];
    }
    return _headerSecondView;
}

- (NSArray *)currentAllList {
    if (!_currentAllList) {
        self.currentAllList = [NSArray array];
    }
    return _currentAllList;
}

- (HLPostcodeAddressController *)addressVc {
    if (!_addressVc) {
        self.addressVc = [self.storyboard instantiateViewControllerWithIdentifier:@"addressID"];
        self.addressVc.popoverPresentationController.backgroundColor = [UIColor redColor];
        self.addressVc.modalPresentationStyle = UIModalPresentationPopover;
        self.addressVc.delegate = self;
    }
    return _addressVc;
}

@end
