//
//  FriendsForRemindersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/9/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>
#import "SubclassHeader.h"

@class FriendsForRemindersViewController;

@protocol FriendsForRemindersDelegate <NSObject>

-(void)friendsForReminders:(FriendsForRemindersViewController *)controller friend:(UserInfo *)friend currentUser:(UserInfo *)currentUser;

-(void)friendsForReminders:(FriendsForRemindersViewController *)controller didFinishSelectingFriends:(NSArray *)friends currentUser:(UserInfo *)currentUser;

/*-(void)friendsForReminders:(FriendsForRemindersViewController *)controller didFinishSelectingContactWithUsername:(NSString *)username
    withName:(NSString *)name
    withProfilePicture:(UIImage *)image
    withObjectId:(PFObject *)objectID
    selfUserObject:(UserInfo *)userObject; */

@end

@interface FriendsForRemindersViewController : UITableViewController

@property (nonatomic, strong) id <FriendsForRemindersDelegate> delegate;
- (IBAction)cancel:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)done:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *toolbarLabel;
- (IBAction)toolbarLabelSwitch:(id)sender;


@end

