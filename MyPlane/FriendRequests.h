//
//  FriendRequests.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/21/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@interface FriendRequests : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property (retain) PFObject *sender;
@property (retain) PFObject *receiver;
@property (retain) NSString *senderUsername;
@property (retain) NSString *receiverUsername;


@end
