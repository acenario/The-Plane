//
//  IndependentInviteMenuViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InviteMembersToCircleViewController.h"
#import "SubclassHeader.h"

@class IndependentInviteMenuViewController;

@protocol IndependentInviteMenuViewControllerDelegate <NSObject>

@end

@interface IndependentInviteMenuViewController : UITableViewController <InviteMembersToCircleViewControllerDelegate>

@property (nonatomic, weak) id <IndependentInviteMenuViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;
@property (nonatomic, strong) UserInfo *currentUser;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end
