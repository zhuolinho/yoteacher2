//
//  OrdersViewController.m
//  ChatDemo-UI2.0
//
//  Created by HoJolin on 15/8/28.
//  Copyright (c) 2015年 HoJolin. All rights reserved.
//

#import "OrdersViewController.h"
#import "API.h"
#import "OrdersCell.h"
#import "ChatViewController.h"

@interface OrdersViewController ()<APIProtocol, UIAlertViewDelegate>{
    API *myAPI;
    API *urAPI;
    long uid;
    NSArray *arr;
    UITextField *usernameTF;
    UITextField *nicknameTF;
}

@end

@implementation OrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    myAPI = [[API alloc]init];
    myAPI.delegate = self;
    urAPI = [[API alloc]init];
    urAPI.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (uid) {
        [urAPI getMyMissions:uid];
    }
    else {
        [myAPI getMyInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return arr.count;
}

- (void)didReceiveAPIResponseOf:(API *)api data:(NSDictionary *)data {
    if (api == myAPI) {
        NSDictionary *res = data[@"result"];
        if (res[@"username"] != nil) {
            uid = [res[@"uid"] integerValue];
            [urAPI getMyMissions:uid];
        }
    }
    else if (api == urAPI) {
        arr = data[@"result"];
        NSLog(@"%@", arr);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

- (void)didReceiveAPIErrorOf:(API *)api data:(long)errorNo {
    NSLog(@"%ld",errorNo);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identify = @"chatListCell";
    OrdersCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (!cell) {
        cell = [[OrdersCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    
    NSDictionary *dict = [arr objectAtIndex:indexPath.row];
    cell.name = dict[@"studentNickname"];
    cell.detailMsg = @"已设置你为首席语伴";
    NSString *createTime = dict[@"setTime"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *setTime = [dateFormatter dateFromString:createTime];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    cell.time = [dateFormatter stringFromDate:setTime];
    if ([API getPicByKey:dict[@"studentAvatar"]] == nil) {
        NSString *str = [NSString stringWithFormat:@"%@%@", HOST, dict[@"studentAvatar"]];
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *requst = [NSURLRequest requestWithURL:url];
        [NSURLConnection sendAsynchronousRequest:requst queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            if (connectionError == nil) {
                UIImage *img = [UIImage imageWithData:data];
                if (img != nil) {
                    [API setPicByKey:dict[@"studentAvatar"] pic:img];
                    cell.placeholderImage = img;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                }
            }
        }];
    }
    else {
        cell.placeholderImage = [API getPicByKey:dict[@"studentAvatar"]];
    }

//    cell.placeholderImage ;
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatViewController *chatController;
    chatController = [[ChatViewController alloc] initWithChatter:arr[indexPath.row][@"studentUsername"]
                                                conversationType:eConversationTypeChat];
    chatController.title = arr[indexPath.row][@"studentNickname"];
    [self.navigationController pushViewController:chatController animated:YES];
}

- (void)chatAction {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"联系语伴" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    UIView *myView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 90)];
//    myView.backgroundColor = [UIColor redColor];
    usernameTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 250, 30)];
    usernameTF.placeholder = @"用户名";
    usernameTF.borderStyle = UITextBorderStyleRoundedRect;
    nicknameTF = [[UITextField alloc]initWithFrame:CGRectMake(10, 40, 250, 30)];
    nicknameTF.placeholder = @"昵称";
    nicknameTF.borderStyle = UITextBorderStyleRoundedRect;
    [myView addSubview:usernameTF];
    [myView addSubview:nicknameTF];
    [alertView setValue:myView forKey:@"accessoryView"];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [usernameTF resignFirstResponder];
    [nicknameTF resignFirstResponder];
    if (buttonIndex != alertView.cancelButtonIndex && ![usernameTF.text  isEqual: @""] && ![nicknameTF.text  isEqual: @""]) {
        ChatViewController *chatController;
        chatController = [[ChatViewController alloc] initWithChatter:usernameTF.text
                                                    conversationType:eConversationTypeChat];
        chatController.title = nicknameTF.text;
        [self.navigationController pushViewController:chatController animated:YES];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
