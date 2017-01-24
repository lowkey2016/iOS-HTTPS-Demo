//
//  DMConfig.h
//  HTTPSDemo
//
//  Created by Jymn_Chen on 2017/1/24.
//  Copyright © 2017年 com.jymnchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMConfig : NSObject

+ (NSString *)loginURLString;
+ (NSDictionary *)loginBodyDict;
+ (NSURLRequest *)loginRequest;

@end
