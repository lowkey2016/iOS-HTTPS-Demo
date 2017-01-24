//
//  DMAFSession.m
//  HTTPSDemo
//
//  Created by Jymn_Chen on 2017/1/24.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import "DMAFSession.h"
#import <AFNetworking/AFNetworking.h>
#import "DMConfig.h"

@interface DMAFSession ()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation DMAFSession

#pragma mark - DMAPI

- (void)login {
    if (!_sessionManager) {
        /**
         AFSecurityPolicy 分三种验证模式：
         AFSSLPinningModeNone: 只是验证证书是否在信任列表中
         AFSSLPinningModeCertificate: 该模式会验证证书是否在信任列表中，然后再对比服务端证书和客户端证书是否一致
         AFSSLPinningModePublicKey: 只验证服务端证书与客户端证书的公钥是否一致
         */
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = NO; // 是否允许使用自签名证书
        securityPolicy.validatesDomainName = YES; // 是否需要验证域名，默认YES
        
        self.sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy = securityPolicy;
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        _sessionManager.requestSerializer.timeoutInterval = 20.f;
        _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        _sessionManager.responseSerializer.acceptableContentTypes  = [NSSet setWithObjects:@"application/xml",@"text/xml",@"text/plain",@"application/json",nil];
        
        __weak typeof(self) weakSelf = self;
        [_sessionManager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *_credential) {
            
//            SecTrustRef serverTrust = [[challenge protectionSpace] serverTrust];
//            /**
//             *  导入多张CA证书
//             */
//            NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"cer"];//自签名证书
//            NSData* caCert = [NSData dataWithContentsOfFile:cerPath];
//            if (caCert) {
//                NSSet<NSData *> *cerSet = [NSSet setWithObject:caCert];
//                weakSelf.sessionManager.securityPolicy.pinnedCertificates = cerSet;
//                SecCertificateRef caRef = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)caCert);
//                NSArray *caArray = @[(__bridge id)(caRef)];
//                __unused OSStatus status = SecTrustSetAnchorCertificates(serverTrust, (__bridge CFArrayRef)caArray);
//                SecTrustSetAnchorCertificatesOnly(serverTrust, NO);
//            }
            
            NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
            __autoreleasing NSURLCredential *credential = nil;
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                if ([weakSelf.sessionManager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                    credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                    if (credential) {
                        disposition = NSURLSessionAuthChallengeUseCredential;
                    } else {
                        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                    }
                } else {
                    disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
                }
            } else {
                disposition = NSURLSessionAuthChallengePerformDefaultHandling;
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
            
            return disposition;
        }];
    }
    
    [_sessionManager POST:[DMConfig loginURLString]
               parameters:[DMConfig loginBodyDict]
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      NSData *data = (NSData *)responseObject;
                      NSLog(@"af session ** succ, response = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      NSLog(@"af session ** fail, error = %@", error);
                  }];
}

@end
