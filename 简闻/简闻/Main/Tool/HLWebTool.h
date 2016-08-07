//
//  HLWebTool.h
//  简闻
//
//  Created by 韩露露 on 16/5/1.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HLWebTool : NSObject
/**
 *  get请求
 */
+ (void)get:(NSString *)url param:(NSDictionary *)param class:(Class)resultClass success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;

@end
