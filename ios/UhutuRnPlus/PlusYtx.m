//
//  PlusYtx.m
//  UhutuRnPlus
//
//  Created by srnpr on 2017/3/23.
//  Copyright © 2017年 srnpr. All rights reserved.
//

// CalendarManager.m

#import "PlusYtx.h"
#import "DeviceChatHelper.h"

@implementation PlusYtx

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(checkAudioAuthorizationStatus:(RCTPromiseResolveBlock)resolve
                  reject:(__unused RCTPromiseRejectBlock)reject) {
    __block NSString *mediaType = AVMediaTypeAudio;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        resolve(@(granted));
    }];
}

@end
