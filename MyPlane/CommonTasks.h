//
//  CommonTasks.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/16/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface CommonTasks : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *text;
@property (retain) NSString *username;
@property (retain) NSDate *lastUsed;
@property (retain) PFObject *user;

@end
