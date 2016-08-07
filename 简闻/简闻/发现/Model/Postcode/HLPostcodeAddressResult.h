//
//  HLPostcodeAddressResult.h
//  简闻
//
//  Created by 韩露露 on 16/5/6.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPostcodeAddressResultCity.h"

@interface HLPostcodeAddressResult : NSObject
@property (copy, nonatomic) NSString *totalpage;
@property (copy, nonatomic) NSString *currentpage;
@property (copy, nonatomic) NSString *totalcount;
@property (strong, nonatomic) NSArray *list;
@end
