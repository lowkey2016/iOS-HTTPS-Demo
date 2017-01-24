//
//  DMURLConnection.m
//  HTTPSDemo
//
//  Created by Jymn_Chen on 2017/1/24.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "DMURLConnection.h"
#import <UIKit/UIKit.h>
#import "DMConfig.h"

@interface DMURLConnection () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation DMURLConnection

#pragma mark - DMAPI

- (void)login {
    self.data = [NSMutableData dataWithCapacity:0];
    
    self.connection = [NSURLConnection connectionWithRequest:[DMConfig loginRequest] delegate:self];
    [_connection start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"conn 出错了 ** error = %@", error);
}

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection {
    NSLog(@"conn 启用 Credential Storage");
    // 是否启用 credential storage , 如果返回 NO, 就可以由开发者自己查询和决定是否存储 credential
    // 默认返回 YES
    return YES;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // 获取 trust object
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    SecTrustResultType result;
    
    // SecTrustEvaluate 对 trust 进行验证
    OSStatus status = SecTrustEvaluate(trust, &result);
    if (status == errSecSuccess && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
        // 验证成功，生成 NSURLCredential 证书，告知 challenge 的 sender 使用这个证书来继续连接
        NSURLCredential *cred = [NSURLCredential credentialForTrust:trust];
        [challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
        NSLog(@"conn 认证挑战 ** succ");
    } else {
        // 验证失败，取消这次验证流程
        [challenge.sender cancelAuthenticationChallenge:challenge];
        NSLog(@"conn 认证挑战 ** fail");
    }
}

#pragma mark - NSURLConnectionDataDelegate

- (nullable NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(nullable NSURLResponse *)response
{
    NSLog(@"conn 重定向 ** 被重定向的 url = %@", response.URL);
    NSLog(@"conn 重定向 ** 重定向后的 url = %@", request.URL);
    return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"conn 收到响应 ** response = %@", response);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"conn 收到数据 ** data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [_data appendData:data];
}

//- (nullable NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request {
//    
//}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (nullable NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    NSLog(@"conn 想要缓存响应 ** cachedResponse = %@", cachedResponse);
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"conn 完成加载 ** data = %@", [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding]);
}

@end
