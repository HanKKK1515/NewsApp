//
//  HLPhoneResponse.h
//  简闻
//
//  Created by 韩露露 on 16/5/2.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HLPhoneResult.h"

@interface HLPhoneResponse : NSObject
@property (assign, nonatomic) int error_code;
@property (copy, nonatomic) NSString *reason;
@property (strong, nonatomic) HLPhoneResult *result;
@end
