//
//  API.m
//  GoodLuck
//
//  Created by HoJolin on 15/8/22.
//
//

#import "API.h"

@implementation API

- (void)login:(NSString *)username password:(NSString *)password {
    NSDictionary *d = [[NSDictionary alloc]initWithObjectsAndKeys:username, @"username", password, @"password", @"1", @"type", nil];
    [self post:@"auth.action" dic:d];
}

- (void)getMyInfo {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *yo_token = [ud objectForKey:@"yo_token"];
    NSDictionary *d = [[NSDictionary alloc]initWithObjectsAndKeys:yo_token, @"token", nil];
    [self post:@"getMyInfo.action" dic:d];
}

- (void)post:(NSString *)action dic:(NSDictionary *)dic {
    NSString *str = [NSString stringWithFormat:@"http://115.29.166.167:8080/yozaii2/api/%@", action];
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

@end
