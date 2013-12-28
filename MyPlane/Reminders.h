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
@property (retain) PFObject *fromFriend;
@property (retain) PFObject *recipient;
@property (retain) PFObject *socialPost;
@property (retain) PFObject *parent;
@property (retain) NSDate *date;
@property (retain) NSDate *recipientUpdateTime;
@property (retain) NSDate *senderUpdateTime;
@property (retain) NSDate *reRemindTime;
@property (retain) NSArray *comments;
@property int popularity;
@property int state;
@property int amountOfChildren;
@property BOOL archived;
@property BOOL isParent;
@property BOOL isChild;

@end
