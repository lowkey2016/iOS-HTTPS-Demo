//
//  DMConfig.m
//  HTTPSDemo
//
//  Created by Jymn_Chen on 2017/1/24.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "DMConfig.h"

#warning - Config Your user and password
// 如果没有，就注册一个吧：https://www.alertover.com/auth/register
#define DM_LOGIN_USER    @"???@youmi.net"
#define DM_LOGIN_PASS    @"???"

@implementation DMConfig

+ (NSString *)loginURLString {
    return @"https://api.alertover.com/api/v1/login";
}

+ (NSDictionary *)loginBodyDict {
    return @{@"email": DM_LOGIN_USER,
             @"password": DM_LOGIN_PASS
             };
}

+ (NSURLRequest *)loginRequest {
    NSURL *url = [NSURL URLWithString:[self loginURLString]];
    NSString *bodyStr = [NSString stringWithFormat:@"{\"email\":\"%@\", \"password\":\"%@\"}", DM_LOGIN_USER, DM_LOGIN_PASS];
    NSData *bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setHTTPMethod:@"POST"];
    [req setHTTPBody:bodyData];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return req.copy;
}

@end
