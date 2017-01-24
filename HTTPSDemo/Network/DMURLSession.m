//
//  DMURLSession.m
//  HTTPSDemo
//
//  Created by Jymn_Chen on 2017/1/24.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "DMURLSession.h"
#import "DMConfig.h"

@interface DMURLSession () <NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation DMURLSession

#pragma mark - DMAPI

- (void)login {
    self.data = [NSMutableData new];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:[DMConfig loginRequest]];
    [task resume];
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(nullable NSError *)error {
    NSLog(@"session 无效了 ** error = %@", error);
}

- (void)URLSession:(NSURLSession *)session
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    // 判断服务器返回的证书是否是服务器信任的
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        /*
         disposition：如何处理证书
         NSURLSessionAuthChallengePerformDefaultHandling:默认方式处理
         NSURLSessionAuthChallengeUseCredential：使用指定的证书
         NSURLSessionAuthChallengeCancelAuthenticationChallenge：取消请求
         */
        if (credential) {
            disposition = NSURLSessionAuthChallengeUseCredential;
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
    } else {
        disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
    }
    
    NSString *dispose;
    switch (disposition) {
        case NSURLSessionAuthChallengeUseCredential: {
            dispose = @"信任证书";
            break;
        }
        case NSURLSessionAuthChallengePerformDefaultHandling: {
            dispose = @"默认处理";
            break;
        }
        case NSURLSessionAuthChallengeCancelAuthenticationChallenge: {
            dispose = @"取消认证挑战";
            break;
        }
        case NSURLSessionAuthChallengeRejectProtectionSpace: {
            dispose = @"拒绝这个证书";
            break;
        }
    }
    NSLog(@"session 认证挑战 ** disposition = %@", dispose);
    // 安装证书
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

//- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
//    
//}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler
{
    NSLog(@"conn 重定向 ** 被重定向的 url = %@", response.URL);
    NSLog(@"conn 重定向 ** 重定向后的 url = %@", request.URL);
    completionHandler(request);
}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler
//{
//    
//}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
// needNewBodyStream:(void (^)(NSInputStream * _Nullable bodyStream))completionHandler
//{
//    
//}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//   didSendBodyData:(int64_t)bytesSent
//    totalBytesSent:(int64_t)totalBytesSent
//totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
//{
//    
//}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics
//{
//    
//}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"session 完成了 ** data = %@, error = %@", [[NSString alloc] initWithData:_data encoding:NSUTF8StringEncoding], error);
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"session 收到响应 ** %@", response);
    completionHandler(NSURLSessionResponseAllow);
}

//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
//{
//    
//}

//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
//didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask
//{
//    
//}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"session 收到数据 ** data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [_data appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler
{
    NSLog(@"conn 想要缓存响应 ** cachedResponse = %@", proposedResponse);
    completionHandler(nil);
}

@end
