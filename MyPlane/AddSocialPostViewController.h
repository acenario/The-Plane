//
//  AddSocialPostViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickCircleViewController.h"
#import "AttachReminderViewController.h"
#import "Circles.h"
#import "SocialPosts.h"
#import "UserInfo.h"

@class AddSocialPostViewController;

@protocol AddSocialPostViewControllerDelegate <NSObject>

- (void)addSocialDidFinishAdding:(AddSocialPostViewController *)controller;

@end

@interface AddSocialPostViewController : UITableViewController <PickCircleViewControllerDelegate, UITextViewDelegate, AttachReminderViewControllerDelegate>


#pragma mark - Labels
@property (strong, nonatomic) IBOutlet UILabel *circleLabel; //actual name
@property (strong, nonatomic) IBOutlet UILabel *reminderTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *reminderSubtitle;
@property (strong, nonatomic) IBOutlet UILabel *circleName; //static label
@property (strong, nonatomic) IBOutlet UILabel *limitLabel;

#pragma mark - Other Outlets
@property (strong, nonatomic) IBOutlet UITextView *postTextField;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong, nonatomic) IBOutlet UITableViewCell *pickCircleCell;

#pragma mark - Objects

@property (nonatomic, weak) id <AddSocialPostViewControllerDelegate> delegate;
@property (strong, nonatomic) UserInfo *currentUser;
@property (nonatomic, strong) PFQuery *userQuery;
@property (nonatomic, strong) Circles *circle;

#pragma mark - Actions

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
