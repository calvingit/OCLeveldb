//
//  User.h
//  LeveldbDemo
//
//  Created by zhangwen on 2017/12/28.
//  Copyright © 2017年 JOBO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) NSInteger age;

+ (NSString *)dbKey;
@end
