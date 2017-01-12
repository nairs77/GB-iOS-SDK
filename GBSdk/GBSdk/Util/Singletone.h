//
//  Singletone.h
//  GBSdk
//
//  Created by nairs77 on 2017. 1. 11..
//  Copyright © 2017년 GeBros. All rights reserved.
//

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname, accessorname) \
+ (classname *)accessorname\
{\
static classname *accessorname = nil;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
accessorname = [[classname alloc] init];\
});\
return accessorname;\
}

#define SINGLETON_FOR_CLASS(classname)\
+ (id) sharedInstance {\
static dispatch_once_t pred = 0;\
static id _sharedObject = nil;\
dispatch_once(&pred, ^{\
_sharedObject = [[self alloc] init];\
});\
return _sharedObject;\
}
