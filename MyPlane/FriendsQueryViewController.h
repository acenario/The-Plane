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
//#import "FCContainerViewController.h"

@class FriendsQueryViewController;

@protocol FriendsQueryViewControllerDelegate <NSObject>

- (void)friendsSegmentChanged:(UISegmentedControl *)segmentedController;

@end

@interface FriendsQueryViewController : PFQueryTableViewController <AddFriendViewControllerDelegate, RecievedFriendRequestsDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (nonatomic, strong) id <FriendsQueryViewControllerDelegate> delegate;
- (IBAction)addFriend:(id)sender;
- (IBAction)segmentChanged:(id)sender;

@end
 