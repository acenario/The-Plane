//
//  FriendsForRemindersViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/9/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@class FriendsForRemindersViewController;

@protocol FriendsForRemindersDelegate <NSObject>

-(void)friendsForReminders:(FriendsForRemindersViewController *)controller didFinishSelectingContactWithUsername:(NSString *)username
    withName:(NSString *)name
    withProfilePicture:(UIImage *)image
    withObjectId:(PFObject *)objectID;

@end

@interface FriendsForRemindersViewController : UITableViewController

@property (nonatomic, strong) id <FriendsForRemindersDelegate> delegate;

@end
