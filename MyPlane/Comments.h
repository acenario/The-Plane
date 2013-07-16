//
//  Comment.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/15/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface Comments : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) NSString *text;
@property (retain) PFObject *reminder;
@property (retain) PFObject *user;

@end
