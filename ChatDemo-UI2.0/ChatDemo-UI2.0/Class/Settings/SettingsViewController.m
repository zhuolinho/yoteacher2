/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "SettingsViewController.h"

#import "ApplyViewController.h"
#import "PushNotificationViewController.h"
#import "BlackListViewController.h"
#import "DebugViewController.h"
#import "EditNicknameViewController.h"
#import "UserProfileEditViewController.h"
//#import "BackupViewController.h"
#import "APService.h"
#import "API.h"

@interface SettingsViewController ()<APIProtocol, UIActionSheetDelegate> {
    API *myAPI;
    API *urAPI;
    NSString *nickname;
    long iffree;
    UIActionSheet *mySheet;
}

@property (strong, nonatomic) UIImageView *headImageView;
@property (strong, nonatomic) UILabel *usernameLabel;

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *ipSwitch;
@property (strong, nonatomic) UISwitch *delConversationSwitch;
@property (strong, nonatomic) UISwitch *showCallInfoSwitch;

@end

@implementation SettingsViewController

@synthesize autoLoginSwitch = _autoLoginSwitch;
@synthesize ipSwitch = _ipSwitch;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"title.setting", @"Setting");
    self.view.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
    
    myAPI = [[API alloc]init];
    myAPI.delegate = self;
    urAPI = [[API alloc]init];
    urAPI.delegate = self;
    
    nickname = @"";
    iffree = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [myAPI getMyInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - getter

- (UISwitch *)autoLoginSwitch
{
    if (_autoLoginSwitch == nil) {
        _autoLoginSwitch = [[UISwitch alloc] init];
        [_autoLoginSwitch addTarget:self action:@selector(autoLoginChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _autoLoginSwitch;
}

- (UISwitch *)ipSwitch
{
    if (_ipSwitch == nil) {
        _ipSwitch = [[UISwitch alloc] init];
        [_ipSwitch addTarget:self action:@selector(useIpChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _ipSwitch;
}

- (UISwitch *)delConversationSwitch
{
    if (!_delConversationSwitch)
    {
        _delConversationSwitch = [[UISwitch alloc] init];
        _delConversationSwitch.on = [EaseMob sharedInstance].chatManager.isAutoDeleteConversationWhenLeaveGroup;
        [_delConversationSwitch addTarget:self action:@selector(delConversationChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _delConversationSwitch;
}

- (UISwitch *)showCallInfoSwitch
{
    if (!_showCallInfoSwitch)
    {
        _showCallInfoSwitch = [[UISwitch alloc] init];
        _showCallInfoSwitch.on = [[[NSUserDefaults standardUserDefaults] objectForKey:@"showCallInfo"] boolValue];
        [_showCallInfoSwitch addTarget:self action:@selector(showCallInfoChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _showCallInfoSwitch;
}

#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"setting.autoLogin", @"automatic login");
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.autoLoginSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.autoLoginSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.autoLoginSwitch.frame.size.height) / 2, self.autoLoginSwitch.frame.size.width, self.autoLoginSwitch.frame.size.height);
            [cell.contentView addSubview:self.autoLoginSwitch];
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"title.apnsSetting", @"Apns Settings");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"title.buddyBlock", @"Black List");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.text = NSLocalizedString(@"title.debug", @"Debug");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 4){
            cell.textLabel.text = NSLocalizedString(@"setting.useIp", @"Use IP");
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.ipSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.ipSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.ipSwitch.frame.size.height) / 2, self.ipSwitch.frame.size.width, self.ipSwitch.frame.size.height);
            [cell.contentView addSubview:self.ipSwitch];
        }
        else if (indexPath.row == 5){
            cell.textLabel.text = NSLocalizedString(@"setting.deleteConWhenLeave", @"Delete conversation when leave a group");
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.delConversationSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.delConversationSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.delConversationSwitch.frame.size.height) / 2, self.delConversationSwitch.frame.size.width, self.delConversationSwitch.frame.size.height);
            [cell.contentView addSubview:self.delConversationSwitch];
        } else if (indexPath.row == 6){
            cell.textLabel.text = NSLocalizedString(@"setting.iospushname", @"iOS push nickname");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else if (indexPath.row == 7){
            cell.textLabel.text = NSLocalizedString(@"setting.showCallInfo", nil);
            cell.accessoryType = UITableViewCellAccessoryNone;
            self.showCallInfoSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.showCallInfoSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.showCallInfoSwitch.frame.size.height) / 2, self.showCallInfoSwitch.frame.size.width, self.showCallInfoSwitch.frame.size.height);
            [cell.contentView addSubview:self.showCallInfoSwitch];
        } else if (indexPath.row == 8){
            cell.textLabel.text = NSLocalizedString(@"setting.personalInfo", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            while (cell.contentView.subviews.count) {
                UIView* child = cell.contentView.subviews.lastObject;
                [child removeFromSuperview];
            }
        }
//        else if (indexPath.row == 8){
//            cell.textLabel.text = @"聊天记录备份和恢复";
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [cell.contentView addSubview:self.headImageView];
            [cell.contentView addSubview:self.usernameLabel];
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"my status", @"My Status");
            if (iffree == 0) {
                cell.detailTextLabel.text = NSLocalizedString(@"free", @"Free");
                cell.imageView.image = [UIImage imageNamed:@"Free"];
            }
            else if (iffree == 1) {
                cell.detailTextLabel.text = NSLocalizedString(@"busy", @"Busy");
                cell.imageView.image = [UIImage imageNamed:@"Busy"];
            }
            else if (iffree == 2) {
                cell.detailTextLabel.text = NSLocalizedString(@"away", @"Away");
                cell.imageView.image = [UIImage imageNamed:@"Away"];
            }
            else {
                cell.detailTextLabel.text = @"";
                cell.imageView.image = [[UIImage alloc]init];
            }
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 80;
    }
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            if (mySheet == nil) {
                mySheet = [[UIActionSheet alloc]init];
                mySheet.delegate = self;
                [mySheet addButtonWithTitle:NSLocalizedString(@"free", @"Free")];
                [mySheet addButtonWithTitle:NSLocalizedString(@"away", @"Away")];
                [mySheet addButtonWithTitle:NSLocalizedString(@"busy", @"Busy")];
                [mySheet addButtonWithTitle:NSLocalizedString(@"cancel", @"Cancel")];
                mySheet.cancelButtonIndex = 3;
            }
            [mySheet showInView:tableView];
        }
    }
    else {
    if (indexPath.row == 1) {
        PushNotificationViewController *pushController = [[PushNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:pushController animated:YES];
    }
    else if (indexPath.row == 2)
    {
        BlackListViewController *blackController = [[BlackListViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:blackController animated:YES];
    }
    else if (indexPath.row == 3)
    {
        DebugViewController *debugController = [[DebugViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:debugController animated:YES];
    } else if (indexPath.row == 6) {
        EditNicknameViewController *editName = [[EditNicknameViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:editName animated:YES];
    } else if (indexPath.row == 8){
        UserProfileEditViewController *userProfile = [[UserProfileEditViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:userProfile animated:YES];
        
    }
//    else if(indexPath.row == 8){
//        BackupViewController *backupController = [[BackupViewController alloc] initWithNibName:nil bundle:nil];
//        [self.navigationController pushViewController:backupController animated:YES];
//    }
    }
}

#pragma mark - getter

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 0, _footerView.frame.size.width - 10, 0.5)];
        line.backgroundColor = [UIColor lightGrayColor];
        [_footerView addSubview:line];
        
        UIButton *logoutButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 20, _footerView.frame.size.width - 200, 45)];
        [logoutButton setBackgroundColor:RGBACOLOR(0xfe, 0x64, 0x50, 1)];
//        NSDictionary *loginInfo = [[EaseMob sharedInstance].chatManager loginInfo];
        NSString *username = @"";
        NSString *logoutButtonTitle = [[NSString alloc] initWithFormat:NSLocalizedString(@"setting.loginUser", @"log out%@"), username];
        [logoutButton setTitle:logoutButtonTitle forState:UIControlStateNormal];
        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutButton];
    }
    
    return _footerView;
}

#pragma mark - action

- (void)autoLoginChanged:(UISwitch *)autoSwitch
{
    [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:autoSwitch.isOn];
}

- (void)useIpChanged:(UISwitch *)ipSwitch
{
    [[EaseMob sharedInstance].chatManager setIsUseIp:ipSwitch.isOn];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSNumber numberWithBool:ipSwitch.isOn] forKey:@"identifier_userip_enable"];
    [ud synchronize];
}

- (void)delConversationChanged:(UISwitch *)control
{
    [EaseMob sharedInstance].chatManager.isAutoDeleteConversationWhenLeaveGroup = control.isOn;
}

- (void)showCallInfoChanged:(UISwitch *)control
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:control.isOn] forKey:@"showCallInfo"];
    [userDefaults synchronize];
}

- (void)refreshConfig
{
    [self.autoLoginSwitch setOn:[[EaseMob sharedInstance].chatManager isAutoLoginEnabled] animated:YES];
    [self.ipSwitch setOn:[[EaseMob sharedInstance].chatManager isUseIp] animated:YES];
    
    [self.tableView reloadData];
}

- (void)logoutAction
{
    __weak SettingsViewController *weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutOngoing", @"loging out...")];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        [weakSelf hideHud];
        if (error && error.errorCode != EMErrorServerNotLogin) {
            [weakSelf showHint:error.description];
        }
        else{
            [[ApplyViewController shareController] clear];
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:@"" forKey:@"yo_token"];
            [ud synchronize];
//            [APService setAlias:@"" callbackSelector:nil object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
        }
    } onQueue:nil];
}

- (UIImageView*)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        _headImageView.frame = CGRectMake(20, 10, 60, 60);
        _headImageView.contentMode = UIViewContentModeScaleToFill;
        _headImageView.image = [UIImage imageNamed:@"chatListCellHead"];
    }
    return _headImageView;
}

- (UILabel*)usernameLabel
{
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.frame = CGRectMake(CGRectGetMaxX(_headImageView.frame) + 10.f, 10, 200, 20);
//        _usernameLabel.textColor = [UIColor lightGrayColor];
    }
    return _usernameLabel;
}

- (void)didReceiveAPIErrorOf:(API *)api data:(long)errorNo {
    if (api == urAPI) {
        TTAlertNoTitle(@"设置失败");
    }
}

- (void)didReceiveAPIResponseOf:(API *)api data:(NSDictionary *)data {
    if (api == myAPI) {
        NSDictionary *res = data[@"result"];
        if (res[@"username"] != nil) {
            nickname = res[@"nickname"];
            iffree = [res[@"iffree"] integerValue];
            _usernameLabel.text = nickname;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            if ([API getPicByKey:res[@"avatar"]] == nil) {
                NSString *str = [NSString stringWithFormat:@"%@%@", HOST, res[@"avatar"]];
                NSURL *url = [NSURL URLWithString:str];
                NSURLRequest *requst = [NSURLRequest requestWithURL:url];
                [NSURLConnection sendAsynchronousRequest:requst queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (connectionError == nil) {
                        UIImage *img = [UIImage imageWithData:data];
                        if (img != nil) {
                            [API setPicByKey:res[@"avatar"] pic:img];
                            self->_headImageView.image = img;
                        }
                    }
                }];
            }
            else {
                _headImageView.image = [API getPicByKey:res[@"avatar"]];
            }
        }
    }
    else if (api == urAPI) {
        [myAPI getMyInfo];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 3) {
        [urAPI setIffree:buttonIndex];
    }
}

@end
