//
//  GBLog.h
//  GBSdk
//
//  Created by nairs77 on 2016. 12. 30..
//  Copyright © 2016년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LOG_FLAG_ERROR    (1 << 0)  // 0...0001
#define LOG_FLAG_WARN     (1 << 1)  // 0...0010
#define LOG_FLAG_INFO     (1 << 2)  // 0...0100
#define LOG_FLAG_VERBOSE  (1 << 3)  // 0...1000

#define LOG_LEVEL_OFF     0
#define LOG_LEVEL_ERROR   (LOG_FLAG_ERROR)                                                    // 0...0001
#define LOG_LEVEL_WARN    (LOG_FLAG_ERROR | LOG_FLAG_WARN)                                    // 0...0011
#define LOG_LEVEL_INFO    (LOG_FLAG_ERROR | LOG_FLAG_WARN | LOG_FLAG_INFO)                    // 0...0111
#define LOG_LEVEL_VERBOSE (LOG_FLAG_ERROR | LOG_FLAG_WARN | LOG_FLAG_INFO | LOG_FLAG_VERBOSE) // 0...1111

#define LOG_ERROR   (ddLogLevel & LOG_FLAG_ERROR)
#define LOG_WARN    (ddLogLevel & LOG_FLAG_WARN)
#define LOG_INFO    (ddLogLevel & LOG_FLAG_INFO)
#define LOG_VERBOSE (ddLogLevel & LOG_FLAG_VERBOSE)

#define LOG_MACRO(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#define LOG_OBJC_MACRO(lvl, flg, fmt, ...) \
do { if(lvl & flg) LOG_MACRO(fmt, ##__VA_ARGS__); } while(0)

#define GBLogError(fmt, ...)    LOG_OBJC_MACRO(ddLogLevel, LOG_FLAG_ERROR, fmt, ##__VA_ARGS__)
#define GBLogWarn(fmt, ...)     LOG_OBJC_MACRO(ddLogLevel, LOG_FLAG_WARN, fmt, ##__VA_ARGS__)
#define GBLogInfo(fmt, ...)     LOG_OBJC_MACRO(ddLogLevel, LOG_FLAG_INFO, fmt, ##__VA_ARGS__)
#define GBLogVerbose(fmt, ...)  LOG_OBJC_MACRO(ddLogLevel, LOG_FLAG_VERBOSE, fmt, ##__VA_ARGS__)

extern int ddLogLevel;

@interface GBLog : NSObject

@end
