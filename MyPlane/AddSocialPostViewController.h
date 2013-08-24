//
//  AddSocialPostViewController.h
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/18/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickCircleViewController.h"
#import "Circles.h"
#import "SocialPosts.h"
#import "UserInfo.h"

@class AddSocialPostViewController;

@protocol AddSocialPostViewControllerDelegate <NSObject>

- (void)addSocialDidFinishAdding:(AddSocialPostViewController *)controller;
 
@end

@interface AddSocialPostViewController : UITableViewController <PickCircleViewControllerDelegate, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITextView *postTextField;
@property (nonatomic, weak) id <AddSocialPostViewControllerDelegate> delegate;
@property (strong, nonatomic) UserInfo *currentUser;
@property (nonatomic, strong) PFQuery *userQuery;
@property (strong, nonatomic) IBOutlet UILabel *circleLabel; //actual name
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) Circles *circle;
@property (weak, nonatomic) IBOutlet UILabel *circleName; //static label
@property (strong, nonatomic) IBOutlet UITableViewCell *pickCircleCell;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;


@end
