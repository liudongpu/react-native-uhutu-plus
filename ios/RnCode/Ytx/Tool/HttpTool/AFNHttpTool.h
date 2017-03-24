//
//  AFNHttpTool.h
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define KCNSSTRING_ISEMPTY(str) (str == nil || [str isEqual:[NSNull null]] || str.length <= 0)

#define URLHead @"https://imapp.yuntongxun.com/2016-08-15/Application/"

@interface AFNHttpTool : NSObject

+(instancetype)sharedInstanced;


/**
 查询消息已读状态

 @param type       0 未读 1已读
 @param msgId      消息id
 @param pageSize   每页数量
 @param pageNo     页数
 @param completion block返回值
 */
- (void)queryMessageReadStatus:(NSInteger)type
                         msgId:(NSString*)msgId
                      pageSize:(NSInteger)pageSize
                        pageNo:(NSInteger)pageNo
                    completion:(void (^)(NSString *err,NSArray *array,NSInteger totalSize))completion;

@end
