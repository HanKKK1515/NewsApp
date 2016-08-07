//
//  HLChengyuResponse.m
//  简闻
//
//  Created by 韩露露 on 16/5/14.
//  Copyright © 2016年 韩露露. All rights reserved.
//

#import "HLChengyuResponse.h"

@implementation HLChengyuResponse

- (NSDictionary *)result {
    NSMutableDictionary *newResult = [NSMutableDictionary dictionary];
    __weak typeof(self) chengRsp = self;
    [_result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *oldKey = key;
        if ([oldKey isEqualToString:@"pinyin"]) {
            if (![obj isEqual:[NSNull null]]) {
                if ([obj hasPrefix:@" "]) {
                    obj = [obj substringFromIndex:1];
                }
                [newResult setObject:obj forKey:@"0拼音"];
            }
        } else if ([oldKey isEqualToString:@"chengyujs"]) {
            if (![obj isEqual:[NSNull null]]) {
                if ([obj hasPrefix:@" "]) {
                    obj = [obj substringFromIndex:1];
                }
                if (![obj hasSuffix:@"。"]) {
                    obj = [obj stringByAppendingString:@"。"];
                }
                [newResult setObject:obj forKey:@"1成语解释"];
            }
        } else if ([oldKey isEqualToString:@"from_"]) {
            if (![obj isEqual:[NSNull null]]) {
                if ([obj hasPrefix:@" "]) {
                    obj = [obj substringFromIndex:1];
                }
                if (![obj hasSuffix:@"。"]) {
                    obj = [obj stringByAppendingString:@"。"];
                }
                [newResult setObject:obj forKey:@"2成语出处"];
            }
        } else if ([oldKey isEqualToString:@"example"]) {
            if (![obj isEqual:[NSNull null]]) {
                if ([obj hasPrefix:@" "]) {
                    obj = [obj substringFromIndex:1];
                }
                if (![obj hasSuffix:@"。"]) {
                    obj = [obj stringByAppendingString:@"。"];
                }
                [newResult setObject:obj forKey:@"3举例"];
            }
        } else if ([oldKey isEqualToString:@"yufa"]) {
            if (![obj isEqual:[NSNull null]]) {
                if ([obj hasPrefix:@" "]) {
                    obj = [obj substringFromIndex:1];
                }
                if (![obj hasSuffix:@"。"]) {
                    obj = [obj stringByAppendingString:@"。"];
                }
                [newResult setObject:obj forKey:@"4语法"];
            }
        } else if ([oldKey isEqualToString:@"ciyujs"]) {
            if (![obj isEqual:[NSNull null]]) {
                if ([obj hasPrefix:@" "]) {
                    obj = [obj substringFromIndex:1];
                }
                if (![obj hasSuffix:@"。"]) {
                    obj = [obj stringByAppendingString:@"。"];
                }
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@ && SELF CONTAINS %@", @"[", @"]"];
                if ([predicate evaluateWithObject:obj]) {
                    NSRange range = [obj rangeOfString:@"]"];
                    NSString *english = [obj substringWithRange:NSMakeRange(1, range.location -1)];
                    NSString *hans = [obj substringFromIndex:range.location + 1];
                    if ([english hasPrefix:@" "]) {
                        english = [english substringFromIndex:1];
                    }
                    if ([hans hasPrefix:@" "]) {
                        hans = [hans substringFromIndex:1];
                    }
                    [newResult setObject:english forKey:@"5英文释义"];
                    [newResult setObject:hans forKey:@"6词语解释"];
                } else {
                    [newResult setObject:obj forKey:@"6词语解释"];
                }
            }
        } else if ([oldKey isEqualToString:@"yinzhengjs"]) {
            if (![obj isEqual:[NSNull null]]) {
                if ([obj hasPrefix:@" "]) {
                    obj = [obj substringFromIndex:1];
                }
                if (![obj hasSuffix:@"。"]) {
                    obj = [obj stringByAppendingString:@"。"];
                }
                [newResult setObject:obj forKey:@"7引证解释"];
            }
        } else if ([oldKey isEqualToString:@"tongyi"]) {
            if (![obj isEqual:[NSNull null]]) {
                [newResult setObject:[chengRsp textWithArray:obj] forKey:@"8同义词"];
            }
        } else if ([oldKey isEqualToString:@"fanyi"]) {
            if (![obj isEqual:[NSNull null]]) {
                [newResult setObject:[chengRsp textWithArray:obj] forKey:@"9反义词"];
            }
        }
    }];
    return newResult;
}

- (NSString *)textWithArray:(NSArray *)array {
    NSString *text = nil;
    NSString *temp = nil;
    for (int i = 0; i < array.count; i++) {
        
        if (!i) {
            text = array[0];
            if ([text hasPrefix:@" "]) {
                text = [text substringFromIndex:1];
            }
        } else {
            temp = array[i];
            if ([temp hasPrefix:@" "]) {
                temp = [temp substringFromIndex:1];
            }
            text = [text stringByAppendingFormat:@"  %@", temp];
        }
    }
    return text;
}

- (NSArray *)allKey {
    NSMutableArray *key = self.result.allKeys.mutableCopy;
    int i, j, n = 0;
    NSString *temp = nil;
    for (i = 0; i < key.count -1; i++) {
        n = i;
        for (j = i + 1; j < key.count; j++) {
            if ([key[n] compare:key[j]] == NSOrderedDescending) {
                n = j;
            }
        }
        if (n != i) {
            temp = key[i];
            key[i] = key[n];
            key[n] = temp;
        }
    }
    return key;
}

@end
