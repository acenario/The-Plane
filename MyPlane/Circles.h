//
//  Circles.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserInfo.h"

@interface Circles : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *user;
@property (retain) NSString *displayName;
@property (retain) NSString *name;
@property (retain) UserInfo *owner;
@property (retain) NSArray *members;
@property (retain) NSArray *memberUsernames;
@property (retain) NSArray *pendingMembers;
@property (retain) NSArray *posts;
@property (retain) NSString *privacy;
@property (retain) NSArray *reminders;
@property (retain) NSArray *requests;
@property (retain) NSArray *requestsArray;
@property (retain) NSArray *admins;
@property (retain) NSArray *adminPointers;
@property BOOL public;

@end