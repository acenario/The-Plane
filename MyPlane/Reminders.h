//
//  Reminders.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface Reminders : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *description;
@property (retain) NSString *title;
@property (retain) NSString *fromUser;
@property (retain) NSString *user;
@property (retain) NSArray *comments;
@property (retain) NSDate *date;
@property (retain) PFObject *fromFriend;
@property (retain) PFObject *recipient;
@property (retain) PFObject *socialPost;

@end
