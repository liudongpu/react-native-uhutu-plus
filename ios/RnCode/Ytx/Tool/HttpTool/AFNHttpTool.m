//
//  AFNHttpTool.m
//  ECSDKDemo_OC
//
//  Created by huangjue on 16/8/4.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "AFNHttpTool.h"

@interface AFNHttpTool ()
@property (nonatomic, assign) NSInteger SmsVerifyCodeType;
@end

@implementation AFNHttpTool

+(instancetype)sharedInstanced {
    static dispatch_once_t onceToken;
    static AFNHttpTool *httptool;
    dispatch_once(&onceToken, ^{
        httptool = [[self alloc] init];
    });
    return httptool;
}

- (void)queryMessageReadStatus:(NSInteger)type
                         msgId:(NSString*)msgId
                      pageSize:(NSInteger)pageSize
                        pageNo:(NSInteger)pageNo
                    completion:(void (^)(NSString *err,NSArray *array,NSInteger totalSize))completion {
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];

    NSString *timerStr = [CommonTools stringFromDate:@"yyyyMMddHHmmss" WithDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    NSString *authorBase64 = [NSString stringWithFormat:@"%@:%@",[DemoGlobalClass sharedInstance].appKey,timerStr];
    authorBase64 = [[authorBase64 dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    [mgr.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [mgr.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [mgr.requestSerializer setValue:authorBase64 forHTTPHeaderField:@"Authorization"];
    [mgr.requestSerializer setQueryStringSerializationWithBlock:^NSString * _Nonnull(NSURLRequest * _Nonnull request, id  _Nonnull parameters, NSError * _Nullable __autoreleasing * _Nullable error) {
        return parameters;
    }];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    [bodyDict setValue:msgId forKey:@"msgId"];
    [bodyDict setValue:@(pageSize) forKey:@"pageSize"];
    [bodyDict setValue:@(pageNo) forKey:@"pageNo"];
    [bodyDict setValue:@(type) forKey:@"type"];
    [bodyDict setValue:[DemoGlobalClass sharedInstance].userName forKey:@"userName"];
    
    NSString *paramter = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:nil] encoding:NSUTF8StringEncoding];
    
    NSString *sig = [CommonTools MD5:[NSString stringWithFormat:@"%@%@%@",[DemoGlobalClass sharedInstance].appKey,[DemoGlobalClass sharedInstance].appToken,timerStr]];
    NSString *url = [NSString stringWithFormat:@"%@%@/IMPlus/MessageReceipt?sig=%@",URLHead,[DemoGlobalClass sharedInstance].appKey,sig];
    
    if ([url hasPrefix:@"https"]) {
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        // 是否允许,NO-- 不允许无效的证书
        [securityPolicy setAllowInvalidCertificates:YES];
        securityPolicy.validatesDomainName = NO;
        mgr.securityPolicy = securityPolicy;
    }
    
    [mgr POST:url parameters:paramter progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *statusCode = [responseObject objectForKey:@"statusCode"];
        NSArray *result = [responseObject objectForKey:@"result"];
        NSInteger totalSize = [[responseObject objectForKey:@"totalSize"] integerValue];
        NSMutableArray *readStatusArray = [NSMutableArray array];
        for (NSDictionary *dict in result) {
            ECReadMessageMember *member = [[ECReadMessageMember alloc] init];
            member.userName = dict[@"useracc"];
            member.timetmp = dict[@"time"];
            [readStatusArray addObject:member];
        }
        NSLog(@"queryMessageReadStatus-statusCode:%@,readStatusArray:%@,totalSize:%ld",statusCode,readStatusArray,(long)totalSize);
        completion(statusCode,readStatusArray,totalSize);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion([NSString stringWithFormat:@"%ld",(long)error.code],nil,0);
    }];
}
@end
