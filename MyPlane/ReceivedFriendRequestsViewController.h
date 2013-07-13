//
//  ReceivedFriendRequestsViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/12/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfo.h"

@class ReceivedFriendRequestsViewController;

@protocol RecievedFriendRequestsDelegate <NSObject>
@end

@interface ReceivedFriendRequestsViewController : UITableViewController

@property (nonatomic, weak) id <RecievedFriendRequestsDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *receivedFriendRequestsArray;

@end
