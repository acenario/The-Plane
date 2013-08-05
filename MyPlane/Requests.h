//
//  Requests.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/4/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface Requests : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) PFObject *circle;
@property (retain) PFObject *invitedBy;
@property (retain) PFObject *requester;
@property (retain) NSString *requesterUsername;
@property (retain) NSString *inviterUsername;

@end
