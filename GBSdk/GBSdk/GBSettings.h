//
//  GBSettings.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 4..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GBSettings : NSObject

+ (GBSettings *)currentSettings;

@property (nonatomic) BOOL hasLasetSession;
@property (nonatomic, copy) NSString *sessionInfo;
//@property (nonatomic)

@end
