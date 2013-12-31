//
//  Comments.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/16/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "Reminders.h"
#import "UserInfo.h"
#import "SocialPosts.h"

@interface Comments : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *text;
@property (retain) Reminders *reminder;
@property (retain) UserInfo *user;
@property (retain) SocialPosts *post;


@end