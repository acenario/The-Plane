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
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    owner = (UserInfo *)self.circle.owner;
    self.navigationItem.title = self.circle.searchName;
    self.ownerName.text = [NSString stringWithFormat:@"%@ %@", owner.firstName, owner.lastName];
    self.membersCount.text = [NSString stringWithFormat:@"%d", self.circle.members.count];
    self.postsCount.text = [NSString stringWithFormat:@"%d", self.circle.posts.count];
    self.remindersCount.text = [NSString stringWithFormat:@"%d", self.circle.reminders.count];

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
    } else if ([segue.identifier isEqualToString:@"Posts"]) {
        CirclePostsViewController *controller = [segue destinationViewController];
        controller.delegate = self;
        controller.circle = self.circle;
    }
//    } else if ([segue.identifier isEqualToString:@"Reminders"]) {
//        controller.segue = @"Reminders";
//    }
        
}


@end
