//
//  TransmitContactViewController.m
//  ECSDKDemo_OC
//
//  Created by admin on 16/3/24.
//  Copyright © 2016年 ronglian. All rights reserved.
//

#import "TransmitContactViewController.h"
#import "AddressBookManager.h"

#import "ContactListViewCell.h"
#import "GroupListViewController.h"

@interface TransmitContactViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property (nonatomic, strong) UITableView *tableview;
@property (nonatomic, strong) NSMutableDictionary *contactsDict;
@property (nonatomic, strong) NSArray *contactsArray;
@end

@implementation TransmitContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"手机联系人";
    
    if ([UIDevice currentDevice].systemVersion.integerValue>7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClick)];
    [leftItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self buildUI];
    
    [self dealwithAddress];
}

- (void)buildUI {
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width,self.view.frame.size.height) style:UITableViewStylePlain];
    _tableview.backgroundColor = [UIColor whiteColor];
    _tableview.tableFooterView = [[UIView alloc] init];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableview.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _tableview.sectionHeaderHeight = 20.0f;
    [self.view addSubview:_tableview];
}

- (void)dealwithAddress {
    _contactsDict = [[AddressBookManager sharedInstance] NewallContactsBySorted];
    AddressBook *person = [[AddressBookManager sharedInstance] checkAddressBook:[DemoGlobalClass sharedInstance].userName];
    if (person) {
        [_contactsDict removeObjectForKey:person.firstLetter];
    }
    
    [_contactsDict setValue:@[[NSNull null]] forKey:@" "];
    _contactsArray = [_contactsDict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *letter1 = [NSString stringWithFormat:@"%@",obj1];
        NSString *letter2 = [NSString stringWithFormat:@"%@",obj2];
        if ([letter1 compare:letter2]==NSOrderedAscending) {
            return NSOrderedAscending;
        } else if ([letter1 compare:letter2]==NSOrderedDescending) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

- (void)cancelClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource 
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _contactsArray;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _contactsArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 2;
    }
    return [(NSArray*)_contactsDict[_contactsArray[section]] count];
}


static NSString *cellReusedId = @"cellId";
static NSString *nullCellid = @"nullCellidentifier";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nullCellid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nullCellid];
            cell.textLabel.text = indexPath.row==0?@"选择群聊":@"选择讨论组";
            cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
           
        }
        return cell;
    } else {
        id contact = [_contactsDict[_contactsArray[indexPath.section]] objectAtIndex:indexPath.row];
        ContactListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReusedId];
        if (cell==nil) {
            cell = [[ContactListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReusedId];
        }
        AddressBook *person = (AddressBook*)contact;
        cell.nameLabel.text = person.name;
        cell.numberLabel.text = person.phones.allValues[0]?:@"无号码";
        cell.portraitImg.image = person.head;
        return cell;
    }
    return nil;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        return 44.0f;
    }
    return 65.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    headView.backgroundColor = [UIColor whiteColor];
    
    // 文字
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor darkGrayColor];
    [headView addSubview:label];
    label.text = self.contactsArray[section];
    [headView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[label]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    
    // line
    UIView *lineView = [[UIView alloc] init];
    lineView.translatesAutoresizingMaskIntoConstraints = NO;
    lineView.backgroundColor = [UIColor lightGrayColor];
    [headView addSubview:lineView];
    [headView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-15-[lineView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(lineView)]];
    
    [headView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label][lineView(==0.5)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label,lineView)]];
    
    return headView;
}

const char KalertViewMessage;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        GroupListViewController *groupVc = [[GroupListViewController alloc] init];
        groupVc.title = indexPath.row==0?@"群组":@"讨论组";
        groupVc.isDiscuss = indexPath.row==0?NO:YES;
        groupVc.tableView.scrollsToTop = YES;
        if (groupVc.isDiscuss) {
            [groupVc prepareGroupDisplay];
        }
        ECMessage *msg = [self transAppSandBoxPath];
        groupVc.msg = msg;
        [self.navigationController pushViewController:groupVc animated:YES];
    } else {
        AddressBook *person = (AddressBook*)[_contactsDict[_contactsArray[indexPath.section]] objectAtIndex:indexPath.row];
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"确认发送给：" message:person.name delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        objc_setAssociatedObject(view, &KalertViewMessage, person, OBJC_ASSOCIATION_RETAIN);
        [view show];
    }
}

- (ECMessage *)transAppSandBoxPath {
    
    ECMessage *msg = [[IMMsgDBAccess sharedInstance] getMessagesWithMessageId:_message.messageId OfSession:_message.sessionId];
    switch (msg.messageBody.messageBodyType) {
        case MessageBodyType_Image:
        case MessageBodyType_Video:
        case MessageBodyType_Voice:
        case MessageBodyType_Preview:
        case MessageBodyType_File: {
            ECFileMessageBody *body = (ECFileMessageBody *)msg.messageBody;
            if (body.localPath.length > 0) {
                body.localPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:body.localPath.lastPathComponent];
            }
        }
            break;
            
        default:
            break;
    }
    return msg;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    AddressBook *person = (AddressBook*)objc_getAssociatedObject(alertView, &KalertViewMessage);
    if (buttonIndex!=alertView.cancelButtonIndex) {
        ECMessage *msg = [self transAppSandBoxPath];
        msg.to = person.phones.allValues.firstObject;
        msg.sessionId = msg.to;
        msg.from = [DemoGlobalClass sharedInstance].userName;
        [[DeviceChatHelper sharedInstance] sendMessage:msg];
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_onMesssageChanged object:msg];
        [self cancelClick];
    }
}
@end
