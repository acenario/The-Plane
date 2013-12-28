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

#pragma mark - Dates
@dynamic date;
@dynamic recipientUpdateTime;
@dynamic senderUpdateTime;
@dynamic reRemindTime;

#pragma mark - Booleans
@dynamic archived;
@dynamic isParent;
@dynamic isChild;

#pragma mark - Pointers
@dynamic fromFriend;
@dynamic parent;
@dynamic socialPost;
@dynamic recipient;
@dynamic comments;

#pragma mark - Strings
@dynamic description;
@dynamic title;
@dynamic user;
@dynamic fromUser;

#pragma mark - Integers
@dynamic popularity;
@dynamic state;
@dynamic amountOfChildren;


@end
