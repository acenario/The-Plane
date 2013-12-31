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

// Dates
@dynamic date;
@dynamic recipientUpdateTime;
@dynamic senderUpdateTime;
@dynamic reRemindTime;

// Booleans
@dynamic archived;
@dynamic isParent;
@dynamic isChild;
@dynamic isShared;

// Pointers
@dynamic fromFriend;
@dynamic parent;
@dynamic socialPost;
@dynamic recipient;

// Arrays
@dynamic comments;
@dynamic children;

// Strings
@dynamic description;
@dynamic title;
@dynamic user;
@dynamic fromUser;

// Integers
@dynamic popularity;
@dynamic state;
@dynamic amountOfChildren;


@end
