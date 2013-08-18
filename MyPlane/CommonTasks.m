//
//  CommonTasks.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/16/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CommonTasks.h"
#import <Parse/PFObject+Subclass.h>

@implementation CommonTasks
+ (NSString *)parseClassName {
    return @"CommonTasks";
}

@dynamic text;
@dynamic user;
@dynamic username;
@dynamic lastUsed;

@end
