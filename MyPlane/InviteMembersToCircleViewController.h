//
//  InviteMembersToCircleViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"

@class InviteMembersToCircleViewController;

@protocol InviteMembersToCircleViewControllerDelegate <NSObject>

- (void)inviteMembersToCircleViewController:(InviteMembersToCircleViewController *)controller didFinishWithMembers:(NSMutableArray *) members andUsernames:(NSMutableArray *)usernames;

@end

@interface InviteMembersToCircleViewController : PFQueryTableViewController <UISearchBarDelegate>

@property (nonatomic, strong) id <InviteMembersToCircleViewControllerDelegate> delegate;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (nonatomic, strong) NSMutableArray *currentlyInvitedMembers;
@property (nonatomic, strong) NSMutableArray *invitedUsernames;

@end
 