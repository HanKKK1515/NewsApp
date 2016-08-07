//
//  HLMemo.h
//  简闻
//
//  Created by 韩露露 on 16/4/21.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLMemo : NSObject <NSCoding>
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *text;
@property (strong, nonatomic) NSDate *date;
@end
