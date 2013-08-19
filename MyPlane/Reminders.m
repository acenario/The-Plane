//
//  Reminders.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "Reminders.h"
#import <Parse/PFObject+Subclass.h>

@implementation Reminders
+ (NSString *)parseClassName {
    return @"Reminders";
}

@dynamic description;
@dynamic title;
@dynamic user;
@dynamic fromFriend;
@dynamic fromUser;
@dynamic comments;
@dynamic recipient;
@dynamic date;

@end
