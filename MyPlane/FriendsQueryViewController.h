//
//  FriendsQueryViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/17/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddFriendViewController.h"
#import "UserInfo.h"
#import "ReceivedFriendRequestsViewController.h"
#import "AddReminderViewController.h"

@interface FriendsQueryViewController : PFQueryTableViewController <AddFriendViewControllerDelegate, RecievedFriendRequestsDelegate>

- (IBAction)addFriend:(id)sender;

@end
 