//
//  RCTUhutuPlus.m
//  RCTUhutuPlus
//
//  Created by srnpr on 2017/3/24.
//  Copyright © 2017年 srnpr. All rights reserved.
//

#import "RCTUhutuPlus.h"
#import <React/RCTBridgeModule.h>
#import <React/RctLog.h>

@implementation RCTUhutuPlus

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(testPrint:(NSString *)name info:(NSDictionary *)info) {
    RCTLogInfo(@"%@: %@", name, info);
}

@end
