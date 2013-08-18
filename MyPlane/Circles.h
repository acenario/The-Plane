//
//  Circles.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface Circles : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *user;
@property (retain) NSString *searchName;
@property (retain) NSString *name;
@property (retain) PFObject *owner;
@property (retain) NSArray *members;
@property (retain) NSArray *memberUsernames;
@property (retain) NSArray *pendingMembers;
@property (retain) NSArray *posts;
@property (retain) NSString *privacy;
@property (retain) NSArray *reminders;
@property (retain) NSArray *requests;
@property (retain) NSArray *admins;
@property BOOL public;

@end