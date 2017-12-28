//
//  User.m
//  LeveldbDemo
//
//  Created by zhangwen on 2017/12/28.
//  Copyright © 2017年 JOBO. All rights reserved.
//

#import "User.h"

@implementation User
+ (NSString *)dbKey{
    return NSStringFromClass([User class]);
}
- (NSString *)description{
    return @{@"name":_name, @"age":@(_age), @"userId":_userId}.description;
}
@end
