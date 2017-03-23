//
//  DeviceDelegateHelper+VoIP.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 15/6/30.
//  Copyright (c) 2015年 ronglian. All rights reserved.
//

#import "DeviceDelegateHelper+Meeting.h"
#import "VoipIncomingViewController.h"
#import "MultiVideoConfViewController.h"

@implementation DeviceDelegateHelper(Meeting)
const char KalertMeeting;
/**
 @brief 有会议呼叫邀请
 @param callid      会话id
 @param calltype    呼叫类型
 @param meetingData 会议的数据
 */
- (NSString*)onMeetingCallReceived:(NSString*)callid withCallType:(CallType)calltype withMeetingData:(NSDictionary*)meetingData {
    
    [[ECDevice sharedInstance].VoIPManager enableLoudsSpeaker:YES];
    
    [AppDelegate shareInstance].callid = nil;
    if ([DemoGlobalClass sharedInstance].isCallBusy) {
        [[ECDevice sharedInstance].VoIPManager rejectCall:callid andReason:ECErrorType_CallBusy];
        return @"";
    }
    
    if (calltype == VIDEO) {
        MultiVideoConfViewController *VideoConfview = [[MultiVideoConfViewController alloc] init];
        VideoConfview.navigationItem.hidesBackButton = YES;
        VideoConfview.curVideoConfId = meetingData[ECMeetingDelegate_CallerConfId];
        VideoConfview.Confname = @"视频会议";
        VideoConfview.isCreator = NO;
        VideoConfview.callID = callid;
        
        id rootviewcontroller = [AppDelegate shareInstance].window.rootViewController;
        if ([rootviewcontroller isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *nav = (UINavigationController*)rootviewcontroller;
            if (nav.visibleViewController!=nil) {
                rootviewcontroller = nav.visibleViewController;
            } else {
                rootviewcontroller = nav.topViewController;
            }
            if ([rootviewcontroller isKindOfClass:[UIViewController class]]) {
                [((UIViewController*)rootviewcontroller).navigationController pushViewController:VideoConfview animated:YES];
            } else {
                [rootviewcontroller pushViewController:VideoConfview animated:YES];
            }
            
        } else if ([rootviewcontroller isKindOfClass:[UIViewController class]]) {
            
            [((UIViewController*)rootviewcontroller).navigationController pushViewController:VideoConfview animated:YES];
        }
        

    } else {
        
        VoipIncomingViewController* incomingVoiplView = [[VoipIncomingViewController alloc] initWithName:meetingData[ECMeetingDelegate_CallerConfId] andPhoneNO:meetingData[ECMeetingDelegate_CallerName] andCallID:callid];
        incomingVoiplView.contactVoip = meetingData[ECMeetingDelegate_CallerConfId];
        incomingVoiplView.status = IncomingCallStatus_incoming;
        
        id rootviewcontroller = [AppDelegate shareInstance].window.rootViewController;
        if ([rootviewcontroller isKindOfClass:[UINavigationController class]]) {
            
            UINavigationController *nav = (UINavigationController*)rootviewcontroller;
            if (nav.visibleViewController!=nil) {
                rootviewcontroller = nav.visibleViewController;
            } else {
                rootviewcontroller = nav.topViewController;
            }
            [rootviewcontroller presentViewController:incomingVoiplView animated:YES completion:nil];
        } else if ([rootviewcontroller isKindOfClass:[UIViewController class]]) {
            [rootviewcontroller presentViewController:incomingVoiplView animated:YES completion:nil];
        }
    }

    [DemoGlobalClass sharedInstance].isCallBusy = YES;
    return nil;
}

-(void)onReceiveInterphoneMeetingMsg:(ECInterphoneMeetingMsg *)message {
    
//    [[AppDelegate shareInstance] toast:@"onReceiveInterphoneMeetingMsg 收到"];
    
    if (message.type == Interphone_INVITE) {
        
        if (message.interphoneId.length > 0) {
            BOOL isExist = NO;
            for (NSString *interphoneid in [DemoGlobalClass sharedInstance].interphoneArray) {
                if ([interphoneid isEqualToString:message.interphoneId]) {
                    isExist = YES;
                    break;
                }
            }
            
            if (!isExist) {
                [[DemoGlobalClass sharedInstance].interphoneArray addObject:message.interphoneId];
            }
        }
        
    } else if (message.type == Interphone_OVER) {
        
        if (message.interphoneId.length > 0) {
            for (NSString *interphoneid in [DemoGlobalClass sharedInstance].interphoneArray) {
                if ([interphoneid isEqualToString:message.interphoneId]) {
                    [[DemoGlobalClass sharedInstance].interphoneArray removeObject:interphoneid];
                    break;
                }
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceiveInterphoneMeetingMsg object:message];
}

-(void)onReceiveMultiVoiceMeetingMsg:(ECMultiVoiceMeetingMsg *)message {
//    [[AppDelegate shareInstance] toast:@"onReceiveMultiVoiceMeetingMsg 收到"];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceiveMultiVoiceMeetingMsg object:message];
}

- (void)onReceiveMultiVideoMeetingMsg:(ECMultiVideoMeetingMsg *)msg
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onReceiveMultiVideoMeetingMsg object:msg];
}
@end
