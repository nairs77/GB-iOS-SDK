//
//  NSData+Formatter.h
//  Joyple
//
//  Created by Professional on 2014. 6. 17..
//  Copyright (c) 2014년 Joycity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (Formatter)

- (NSString *)stringByBase64Encoding;
- (NSString *)dataXORWithData:(NSString *)key;
@end
