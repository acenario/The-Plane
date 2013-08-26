//
//  CreateCircleViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InviteMembersToCircleViewController.h"
#import "SubclassHeader.h"

@class CreateCircleViewController;

@protocol CreateCircleViewControllerDelegate <NSObject>

- (void)createCircleViewControllerDidFinishCreatingCircle:(CreateCircleViewController *)controller;

@end

@interface CreateCircleViewController : UITableViewController <UITextFieldDelegate, InviteMembersToCircleViewControllerDelegate>
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (nonatomic, weak) id <CreateCircleViewControllerDelegate> delegate;
@property (nonatomic, strong) UserInfo *currentUser;

@end
 