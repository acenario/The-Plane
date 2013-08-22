//
//  CircleDetailViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CircleDetailViewController.h"

@interface CircleDetailViewController ()

@end

@implementation CircleDetailViewController {
    UserInfo *owner;
    UserInfo *userObject;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)userQuery
{
    PFQuery * currentUserQuery = [UserInfo query];
    [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            userObject = object;
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    owner = (UserInfo *)self.circle.owner;
    self.navigationItem.title = self.circle.displayName;
    self.ownerName.text = [NSString stringWithFormat:@"%@ %@", owner.firstName, owner.lastName];
    self.membersCount.text = [NSString stringWithFormat:@"%d", self.circle.members.count];
    self.postsCount.text = [NSString stringWithFormat:@"%d", self.circle.posts.count];
//    self.remindersCount.text = [NSString stringWithFormat:@"%d", self.circle.reminders.count];
    
    [self userQuery];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
} 

#pragma mark - Table view data source


#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Members"]) {
        CircleMembersViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.circle = self.circle;
        controller.currentUser = self.currentUser;
    } else if ([segue.identifier isEqualToString:@"Posts"]) {
        CirclePostsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.circle = self.circle;
    } else if ([segue.identifier isEqualToString:@"InviteMembers"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        IndependentInviteMenuViewController *controller = (IndependentInviteMenuViewController *)nav.topViewController;
        controller.delegate = self;
        controller.circle = self.circle;
        controller.currentUser = userObject;
    } else if ([segue.identifier isEqualToString:@"Reminders"]) {
        CircleRemindersViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.circle = self.circle;
        controller.circles = self.circles;
        controller.currentUser = self.currentUser;
    }
}

#pragma mark - Other Methods

- (IBAction)leaveCircle:(id)sender {
    [userObject removeObject:self.circle forKey:@"circles"];
    [self.circle removeObject:userObject forKey:@"members"];
    [self.circle removeObject:userObject.user forKey:@"memberUsernames"];
    
    [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.circle saveInBackground];
        [self dismissViewControllerAnimated:YES completion:^{
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Left %@", self.circle.displayName]];
        }];
    }];
}

@end
