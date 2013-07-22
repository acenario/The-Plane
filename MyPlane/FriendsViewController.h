//
//  FriendsViewController.h
//  MyPlane
//
//  Created by Arjun Bhatnagar on 7/7/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddFriendViewController.h"
//#import "CirclesViewController.h"
#import "UserInfo.h"
#import "ReceivedFriendRequestsViewController.h"


@interface FriendsViewController : UITableViewController <AddFriendViewControllerDelegate, RecievedFriendRequestsDelegate>
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
//- (IBAction)segmentedSwitch:(id)sender;

@end
