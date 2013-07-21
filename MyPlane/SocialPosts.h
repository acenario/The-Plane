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
@property (retain) PFObject *circle;
@property (retain) PFObject *user;
@property (retain) NSArray *comments;

@end