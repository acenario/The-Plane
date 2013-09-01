//
//  SocialPosts.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SocialPosts.h"
#import <Parse/PFObject+Subclass.h>

@implementation SocialPosts
+ (NSString *)parseClassName {
    return @"SocialPosts";
}

//@dynamic objectId;
@dynamic text;
@dynamic username;
@dynamic circle;
@dynamic reminderDate;
@dynamic reminderDescription;
@dynamic reminderTask;
@dynamic reminder;
@dynamic user;
@dynamic comments;
@dynamic isClaimed;
@dynamic claimers;
@dynamic claimerUsernames;

@end