//
//  HLPostcodeAddressController.h
//  简闻
//
//  Created by 韩露露 on 16/5/11.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLPostcodeCityListResponse.h"

@class HLPostcodeAddressController;
@protocol HLPostcodeAddressDelegate <NSObject>

@optional
- (void)postcodeAddressController:(HLPostcodeAddressController *)vc withChoiceObjects:(NSDictionary *)objects;

@end
@interface HLPostcodeAddressController : UITableViewController
@property (weak, nonatomic) id<HLPostcodeAddressDelegate> delegate;
@property (strong, nonatomic) HLPostcodeCityListResponse *allData;
@property (strong, nonatomic) HLPostcodeCityList *cityData;
@end
