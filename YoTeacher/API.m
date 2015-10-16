//
//  API.m
//  GoodLuck
//
//  Created by HoJolin on 15/8/22.
//
//

#import "API.h"

static NSMutableDictionary *picDic;
static NSMutableDictionary *nameDic;

@implementation API

- (void)login:(NSString *)username password:(NSString *)password {
    NSDictionary *d = [[NSDictionary alloc]initWithObjectsAndKeys:username, @"username", password, @"password", @"1", @"type", nil];
    [self post:@"auth.action" dic:d];
}

- (void)setIffree:(NSInteger)status {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *yo_token = [ud objectForKey:@"yo_token"];
    NSString *iffree = [NSString stringWithFormat:@"%ld", (long)status];
    NSDictionary *d = [[NSDictionary alloc]initWithObjectsAndKeys:yo_token, @"token", iffree, @"iffree", nil];
    [self post:@"setIffree.action" dic:d];
}

- (void)getMyInfo {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *yo_token = [ud objectForKey:@"yo_token"];
    NSDictionary *d = [[NSDictionary alloc]initWithObjectsAndKeys:yo_token, @"token", nil];
    [self post:@"getMyInfo.action" dic:d];
}

- (void)getMyMissions:(long)uid {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *yo_token = [ud objectForKey:@"yo_token"];
    NSString *iffree = [NSString stringWithFormat:@"%ld", (long)uid];
    NSDictionary *d = [[NSDictionary alloc]initWithObjectsAndKeys:yo_token, @"token", iffree, @"uid", @"0", @"start", @"100", @"limit", nil];
    [self post:@"getTakeMissions.action" dic:d];
}

- (void)post:(NSString *)action dic:(NSDictionary *)dic {
    NSString *str = [NSString stringWithFormat:@"%@/yozaii2/api/%@", HOST, action];
    NSURL *url = [NSURL URLWithString:str];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    NSMutableArray *parametersArray = [[NSMutableArray alloc]init];
    for (NSString *key in [dic allKeys]) {
        id value = [dic objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [parametersArray addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
        }     
    }
    NSString *dicString = [parametersArray componentsJoinedByString:@"&"];
    NSData *data = [dicString dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = data;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            NSError *err = nil;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            if(jsonObject != nil && err == nil){
                if([jsonObject isKindOfClass:[NSDictionary class]]){
                    NSDictionary *deserializedDictionary = (NSDictionary *)jsonObject;
                    long errNo = [deserializedDictionary[@"errno"] integerValue];
                    if (errNo == 0) {
                        if (self->_delegate) {
                            [self->_delegate didReceiveAPIResponseOf:self data:deserializedDictionary];
                        }
                    }
                    else {
                        if (self->_delegate) {
                            [self->_delegate didReceiveAPIErrorOf:self data:errNo];
                        }
                    }
                }else if([jsonObject isKindOfClass:[NSArray class]]){
                    if (self->_delegate) {
                        [self->_delegate didReceiveAPIErrorOf:self data:-999];
                    }
                }
            }
            else if(err != nil){
                if (self->_delegate) {
                    [self->_delegate didReceiveAPIErrorOf:self data:-777];
                }
            }
        }
        else {
            if (self->_delegate) {
                [self->_delegate didReceiveAPIErrorOf:self data:-888];
            }
        }
    }];
}

+ (UIImage *)getPicByKey:(NSString *)key {
    if (picDic != nil) {
        return [picDic objectForKey:key];
    }
    return nil;
}

+ (void)setPicByKey:(NSString *)key pic:(UIImage *)pic {
    if (picDic == nil) {
        picDic = [[NSMutableDictionary alloc]init];
    }
    [picDic setValue:pic forKey:key];
}

+ (NSString *)getNameByKey:(NSString *)key {
    if (nameDic != nil) {
        return [nameDic objectForKey:key];
    }
    return nil;
}

+ (void)setNameByKey:(NSString *)key name:(NSString *)name {
    if (nameDic == nil) {
        nameDic = [[NSMutableDictionary alloc]init];
    }
    [nameDic setValue:name forKey:key];
}

@end
