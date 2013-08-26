//
//  Circles.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "Circles.h"
#import <Parse/PFObject+Subclass.h>

@implementation Circles
+ (NSString *)parseClassName {
    return @"Circles";
}

@dynamic user;
@dynamic displayName;
@dynamic name;
@dynamic members;
@dynamic memberUsernames;
@dynamic pendingMembers;
@dynamic posts;
@dynamic owner;
@dynamic reminders;
@dynamic public;
@dynamic requests;
@dynamic requestsArray;
@dynamic privacy;
@dynamic admins;
@dynamic adminPointers;

@end