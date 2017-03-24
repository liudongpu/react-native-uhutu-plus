//
//  DemoGlobalClass.m
//  ECSDKDemo_OC
//
//  Created by jiazy on 14/12/5.
//  Copyright (c) 2014年 ronglian. All rights reserved.
//

#import "DemoGlobalClass.h"
#import "DeviceDBHelper.h"
#import "CameraDeviceInfo.h"

#define UserDefault_UserName        @"UserDefault_Username"
#define UserDefault_UserPwd         @"UserDefault_UserPwd"
#define UserDefault_LoginAuthType   @"UserDefault_LoginAuthType"
#define UserDefault_CurResolution   @"UserDefault_CurResolution"
#define UserDefault_VideoViewContentMode     @"UserDefault_VideoviewContentMode"

#define UserDefault_NickName    [NSString stringWithFormat:@"%@_nickName",self.userName]
#define UserDefault_UserSex     [NSString stringWithFormat:@"%@_UserSex",self.userName]
#define UserDefault_UserBirth   [NSString stringWithFormat:@"%@_UserBirth",self.userName]
#define UserDefault_UserDataVer     [NSString stringWithFormat:@"%@_UserDataVer",self.userName]
#define UserDefault_UserSign   [NSString stringWithFormat:@"%@_UserSign",self.userName]
//应用信息配置文件
#define AppConfigPlist @"AppConfig.plist"

#define AppConfig_AppKey @"AppKey"
#define AppConfig_AppToken @"AppToken"

#define DefaultAppKey @"8aaf07085adadc12015ae966f0d9024a"
#define DefaultAppToke @"3c21708ffb8b0a09c3c4ec075a4c11a1"
//应用设置Key
#define messageSoundKey @"message_sound"
#define messageShakeKey @"message_shake"
#define playVoiceEar @"playvoice_ear"
#define opusKey @"opusKey"


@interface DemoGlobalClass()
@property (nonatomic, strong) NSMutableDictionary *appinfoDic;
@end

@implementation DemoGlobalClass

+(DemoGlobalClass*)sharedInstance {
    
    static DemoGlobalClass *demoglobalclass;
    static dispatch_once_t demoglobalclassonce;
    dispatch_once(&demoglobalclassonce, ^{
        demoglobalclass = [[DemoGlobalClass alloc] init];
    });
    return demoglobalclass;
}

-(id)init {
    
    if (self = [super init]) {
        self.mainAccontDictionary = [NSMutableDictionary dictionary];
        self.allSessions = [NSMutableDictionary dictionary];
        self.interphoneArray = [NSMutableArray array];
        self.AtPersonArray = [NSMutableArray array];
        self.groupMemberArray = [NSMutableArray array];
        self.cameraInfoArray = [[ECDevice sharedInstance].VoIPManager getCameraInfo];
        [self readAppConfig];
        [self SetLasterSaveCodec];
    }
    return self;
}

-(void)readAppConfig {
    
    //应用资源文件夹应用信息文件路径
    NSString *appResource = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:AppConfigPlist];

    //应用资源文件在设备上的路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *appDocument = [[paths objectAtIndex:0] stringByAppendingPathComponent:AppConfigPlist];
    
    BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:appDocument];
    if (!success){
        
        NSError *error;
        success = [[NSFileManager defaultManager] copyItemAtPath:appResource toPath:appDocument error:&error];
        if (!success){
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
    
    //读取设备配置文件 实际开发中，可直接读取应用资源配置文件appResource
    self.appinfoDic = [[NSMutableDictionary alloc] initWithContentsOfFile:appDocument];
}

-(NSString*)getOtherNameWithPhone:(NSString*)phone {
    
    if (phone.length <= 0) {
        return @"";
    }
    
    if ([phone isEqualToString:@"10089"]) {
        return @"系统通知";
    }
    
    if ([phone hasPrefix:@"g"]) {
        NSString * name = [[IMMsgDBAccess sharedInstance] getGroupNameOfId:phone];
        if (name.length ==0) {
            
            //请求群组信息
            [[ECDevice sharedInstance].messageManager getGroupDetail:phone completion:^(ECError *error, ECGroup *group) {
                
                if (error.errorCode == ECErrorType_NoError && group.name.length>0) {
                    
                    [[IMMsgDBAccess sharedInstance] addGroupIDs:@[group]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KNotice_ReloadSessionGroup object:group.groupId];
                }
                
            }];

            return phone;
        } else {
            return name;
        }
    } else {
        AddressBook* book = [[AddressBookManager sharedInstance] checkAddressBook:phone];
        if (!KCNSSTRING_ISEMPTY(book.name)) {
            return book.name;
        }

        NSString* name = [[IMMsgDBAccess sharedInstance] getUserName:phone];
        if (name.length>0) {
            return name;
        }
    }
    return phone;
}

-(UIImage*)getOtherImageWithPhone:(NSString*)phone {
    if ([phone hasPrefix:@"g"]) {
        return [UIImage imageNamed:@"group_head"];
    }
    AddressBook* book = [[AddressBookManager sharedInstance] checkAddressBook:phone];
    if (book) {
        return book.head;
    }
    
    ECSexType sex = [[IMMsgDBAccess sharedInstance] getUserSex:phone];
    return (sex==ECSexType_Female?[UIImage imageNamed:@"female_default_head_img"]:[UIImage imageNamed:@"male_default_head_img"]);
}

/**
 *@brief 判断SDK是否支持VoIP
 *@return YES:支持 NO:不支持
 */
-(BOOL)isSDKSupportVoIP {
    return ([ECDevice sharedInstance].VoIPManager != nil);
}

- (BOOL)isDiscussGroupOfId:(NSString *)groupId {
    return [[IMMsgDBAccess sharedInstance] isDiscussOfGroupId:groupId];
}
    
-(NSString*)appKey {
    NSString *value = [self.appinfoDic objectForKey:AppConfig_AppKey];
    NSLog(@"appconfig appkey=%@",value);
    return value;
}

-(NSString*)appToken {
    NSString *value = [self.appinfoDic objectForKey:AppConfig_AppToken];
    NSLog(@"appconfig apptoken=%@",value);
    return value;
}

-(void)setLoginAuthType:(LoginAuthType)loginAuthType {
    [[NSUserDefaults standardUserDefaults] setObject:@(loginAuthType) forKey:UserDefault_LoginAuthType];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(LoginAuthType)loginAuthType {
    NSNumber *type = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_LoginAuthType];
    NSUInteger typeInt = type.unsignedIntegerValue;
    return typeInt==0?1:typeInt;
}

-(void)setUserName:(NSString *)userName {
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:UserDefault_UserName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)userName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserName];
}

- (void)setUserPassword:(NSString *)userPassword{
    [[NSUserDefaults standardUserDefaults] setObject:userPassword forKey:UserDefault_UserPwd];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)userPassword {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserPwd];
}

-(void)setNickName:(NSString *)nickName {
    [[NSUserDefaults standardUserDefaults] setObject:nickName forKey:UserDefault_NickName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)nickName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_NickName];
}

-(void)setSex:(ECSexType)sex {
    [[NSUserDefaults standardUserDefaults] setObject:@(sex) forKey:UserDefault_UserSex];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(ECSexType)sex {
    NSNumber* nssex = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserSex];
    return nssex.integerValue;
}

-(void)setSign:(NSString *)sign {
    [[NSUserDefaults standardUserDefaults] setObject:sign forKey:UserDefault_UserSign];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)sign {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserSign];
}

-(void)setDataVersion:(unsigned long long)dataVersion {
    [[NSUserDefaults standardUserDefaults] setObject:@(dataVersion) forKey:UserDefault_UserDataVer];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(unsigned long long)dataVersion {
    NSNumber* nsdataver = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserDataVer];
    return nsdataver.unsignedLongLongValue;
}

-(void)setBirth:(NSString *)birth {
    [[NSUserDefaults standardUserDefaults] setObject:birth forKey:UserDefault_UserBirth];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)birth {
    return [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_UserBirth];
}

-(void)setIsMessageSound:(BOOL)isMessageSound {
    [[NSUserDefaults standardUserDefaults] setObject:@(isMessageSound) forKey:messageSoundKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isMessageSound {
    NSNumber* isPlay = [[NSUserDefaults standardUserDefaults] valueForKey:messageSoundKey];
    if (isPlay==nil || isPlay.boolValue){
        return YES;
    }
    return NO;
}

-(void)setIsMessageShake:(BOOL)isMessageShake {
    [[NSUserDefaults standardUserDefaults] setObject:@(isMessageShake) forKey:messageShakeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isMessageShake {
    NSNumber* isPlay = [[NSUserDefaults standardUserDefaults] valueForKey:messageShakeKey];
    if (isPlay==nil || isPlay.boolValue){
        return YES;
    }
    return NO;
}

-(void)setIsPlayEar:(BOOL)isPlayEar {
    [[NSUserDefaults standardUserDefaults] setObject:@(isPlayEar) forKey:playVoiceEar];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)isPlayEar {
    NSNumber* isear = [[NSUserDefaults standardUserDefaults] valueForKey:playVoiceEar];
    return isear.boolValue;
}

-(void)writeAppConfig {
    
    //应用资源文件夹应用信息文件路径
    NSString *appResource = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:AppConfigPlist];
    
    //应用资源文件在设备上的路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *appDocument = [[paths objectAtIndex:0] stringByAppendingPathComponent:AppConfigPlist];
    
    BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:appDocument];
    if (!success){
        
        NSError *error;
        success = [[NSFileManager defaultManager] copyItemAtPath:appResource toPath:appDocument error:&error];
        if (!success){
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
        }
    }
    
    [self.appinfoDic writeToFile:appDocument atomically:YES];
}

- (void)setAppKey:(NSString *)appKey AndAppToken:(NSString*)apptoken {
    [self.appinfoDic setObject:appKey forKey:AppConfig_AppKey];
    [self.appinfoDic setObject:apptoken forKey:AppConfig_AppToken];
    [self writeAppConfig];
}

- (void)setConfigData:(NSString*)CIP :(NSString*)CPORT :(NSString*)LIP :(NSString*)LPORT :(NSString*)FIP :(NSString*)FPORT  {
    
    NSString *string = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><ServerAddr version=\"2\"><Connector><server><host>%@</host><port>%@</port></server></Connector><LVS><server><host>%@</host><port>%@</port></server></LVS><FileServer><server><host>%@</host><port>%@</port></server></FileServer></ServerAddr>",CIP,CPORT,LIP,LPORT,FIP,FPORT];
    //Caches文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //服务器配置文件夹
    NSString * config = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"config.data"];
    
    [[string dataUsingEncoding:NSUTF8StringEncoding] writeToFile:config atomically:YES];
    [[ECDevice sharedInstance] SwitchServerEvn:NO];
}

- (void)resetResourceServer {
    
    [self setAppKey:DefaultAppKey AndAppToken:DefaultAppToke];
    
    //Caches文件路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //服务器配置文件夹
    NSString * config = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"config.data"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:config]) {
        [[NSFileManager defaultManager] removeItemAtPath:config error:nil];
    }
    [[ECDevice sharedInstance] SwitchServerEvn:NO];
}

//选择摄像头
- (NSInteger)selectCamera:(NSInteger)cameraIndex
{
    if (cameraIndex >= self.cameraInfoArray.count) {
        return -1;
    }
    
    NSInteger capabilityIndex = self.curResolutionIndex;
    CameraDeviceInfo *camera = [self.cameraInfoArray objectAtIndex:cameraIndex];
    if (capabilityIndex >= camera.capabilityArray.count) {
        capabilityIndex = 0;
    }
    
    CameraCapabilityInfo *capability = [camera.capabilityArray objectAtIndex:capabilityIndex];
    
    return [[ECDevice sharedInstance].VoIPManager selectCamera:cameraIndex capability:capabilityIndex fps:capability.maxfps rotate:Rotate_Auto];
}

- (void)setCurResolutionIndex:(NSInteger)curResolution {
    [[NSUserDefaults standardUserDefaults] setObject:@(curResolution) forKey:UserDefault_CurResolution];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)curResolutionIndex {
    NSNumber* nsResolution = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_CurResolution];
    if (nsResolution==nil) {
        return 1;
    }
    return nsResolution.integerValue;
}

- (void)setViewcontentMode:(UIViewContentMode)viewcontentMode {
    [[NSUserDefaults standardUserDefaults] setObject:@(viewcontentMode) forKey:UserDefault_VideoViewContentMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIViewContentMode)viewcontentMode {
    NSNumber* nsMode = [[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_VideoViewContentMode];
    if (nsMode==nil) {
        return UIViewContentModeScaleToFill;
    }
    return nsMode.integerValue;
}

- (NSString*)viewContentModeToStr:(UIViewContentMode)contentMode {
    switch (self.viewcontentMode) {
        case UIViewContentModeScaleToFill:
            return @"ScaleToFill";
            
        case UIViewContentModeScaleAspectFit:
            return @"ScaleAspectFit";
            
        case UIViewContentModeScaleAspectFill:
            return @"ScaleAspectFill";
            
        default:
            break;
    }
    return @"ScaleAspectFit";
}

- (UIViewContentMode)viewContentModeFromStr:(NSString*)str {
    if ([str hasSuffix:@"ScaleToFill"]) {
        return UIViewContentModeScaleToFill;
    } else if ([str hasSuffix:@"ScaleAspectFill"]) {
        return UIViewContentModeScaleAspectFill;
    } else {
        return UIViewContentModeScaleAspectFit;
    }
}

//编解码设置
- (void)SetSDKCodecType:(ECCodec)type andEnable:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setObject:@(enable) forKey:[NSString stringWithFormat:@"codec_enable_%ld",type]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[ECDevice sharedInstance].VoIPManager setCodecEnabledWithCodec:type andEnabled:enable];
}

-(BOOL)GetSDKIsEnableCodecType:(ECCodec)type {
    
    NSNumber* nsEnable = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"codec_enable_%ld",type]];
    if (nsEnable==nil) {
        return [[ECDevice sharedInstance].VoIPManager getCondecEnabelWithCodec:type];
    }
    
    return nsEnable.boolValue;
}

- (void)SetLasterSaveCodec{
    for (NSInteger index = Codec_iLBC; index<=Codec_OPUS8; index++) {
        NSNumber* nsEnable = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"codec_enable_%ld",index]];
        if (nsEnable) {
            [[ECDevice sharedInstance].VoIPManager setCodecEnabledWithCodec:index andEnabled:nsEnable.boolValue];
        }
    }
}

@end
