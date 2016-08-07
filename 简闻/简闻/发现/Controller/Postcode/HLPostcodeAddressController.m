//
//  HLPostcodeAddressController.m
//  简闻
//
//  Created by 韩露露 on 16/5/11.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLPostcodeAddressController.h"
#import "HLBarButtonItem.h"

@interface HLPostcodeAddressController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *address;
@property (strong, nonatomic) NSArray *addressList;
@property (strong, nonatomic) HLPostcodeProvinceList *province;

- (IBAction)addressRefresh:(UIBarButtonItem *)sender;
- (IBAction)back:(UIBarButtonItem *)sender;
@end

@implementation HLPostcodeAddressController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)) {
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addressRefresh:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.addressList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"addressCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:245/255.0 green:131/255.0 blue:7/255.0 alpha:1.0];
    id objc = self.addressList[indexPath.row];
    if ([objc isMemberOfClass:[HLPostcodeProvinceList class]]) {
        HLPostcodeProvinceList *province = objc;
        cell.textLabel.text = province.province;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if ([objc isMemberOfClass:[HLPostcodeCityList class]]) {
        HLPostcodeCityList *city = objc;
        cell.textLabel.text = city.city;
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else if ([objc isMemberOfClass:[HLPostcodeDistrict class]]) {
        HLPostcodeDistrict *district = objc;
        cell.textLabel.text = district.district;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id objc = self.addressList[indexPath.row];
    if ([objc isMemberOfClass:[HLPostcodeProvinceList class]]) {
        self.province = objc;
        self.addressList = self.province.city;
        self.address.title = self.province.province;
        [self.tableView reloadData];
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(postcodeAddressController:withChoiceObjects:)]) {
        NSDictionary *objcs = nil;
        if ([objc isMemberOfClass:[HLPostcodeCityList class]]) {
            objcs = @{@"province" : self.province, @"city" : objc};
        } else if ([objc isMemberOfClass:[HLPostcodeDistrict class]]) {
            objcs = @{@"District" : objc};
        }
        [self.delegate postcodeAddressController:self withChoiceObjects:objcs];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)addressRefresh:(UIBarButtonItem *)sender {
    if (self.allData) {
        self.addressList = self.allData.result;
        self.address.title = @"省  份";
    } else if (self.cityData) {
        self.addressList = self.cityData.district;
        self.address.title = @"地  区";
    } else {
        self.address.title = @"无具体数据";
    }
    [self.tableView reloadData];
}

- (IBAction)back:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
