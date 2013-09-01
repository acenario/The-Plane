//
//  SocialPosts.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface SocialPosts : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

//@property (retain) NSString *objectId;
@property (retain) NSString *text;
@property (retain) NSString *username;
@property (retain) NSString *reminderTask;
@property (retain) NSString *reminderDescription;
@property (retain) NSDate *reminderDate;
@property BOOL isClaimed;
@property (retain) PFObject *circle;
@property (retain) PFObject *user;
@property (retain) NSArray *comments;
@property (retain) NSArray *claimers;
@property (retain) NSArray *claimerUsernames;
@property (retain) NSArray *reminder;

@end