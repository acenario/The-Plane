//
//  AddFriendViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <Parse/Parse.h>

@class AddFriendViewController;

@protocol AddFriendViewControllerDelegate <NSObject>

- (void)addFriendViewControllerDidFinishAddingFriends:(AddFriendViewController *)controller;

@end

@interface AddFriendViewController : PFQueryTableViewController <UISearchBarDelegate>
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@property (nonatomic, weak) id <AddFriendViewControllerDelegate> delegate;

@end
