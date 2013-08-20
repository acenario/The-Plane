//
//  PickMembersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubclassHeader.h"
//#import "AddCircleReminderViewController.h"

@class PickMembersViewController;

@protocol PickMembersViewControllerDelegate <NSObject>

- (void)pickMembersViewController:(PickMembersViewController *)controller didFinishPickingMembers:(NSArray *)members withUsernames:(NSArray *)usernames withCircle:(Circles *)circle;

@end

@interface PickMembersViewController : UITableViewController

@property (nonatomic, weak) id <PickMembersViewControllerDelegate> delegate;
@property (nonatomic, strong) Circles *circle;
//@property (nonatomic, strong) UserInfo *currentUser;
@property (nonatomic, strong) NSMutableArray *invitedMembers;
@property (nonatomic, strong) NSMutableArray *invitedUsernames;
@property (strong, nonatomic) IBOutlet UIButton *checkAllButton;
- (IBAction)checkAll:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;
@property BOOL isFromCircles;

@end
