//
//  CircleDetailViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#define TAG_LEAVE 1
#define TAG_DISBAND 2
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
    currentUserQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            userObject = object;
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    
    owner = (UserInfo *)self.circle.owner;
    self.navigationItem.title = self.circle.displayName;
    self.ownerName.text = [NSString stringWithFormat:@"%@ %@", owner.firstName, owner.lastName];
    self.membersCount.text = [NSString stringWithFormat:@"%d", self.circle.members.count];
    //    self.remindersCount.text = [NSString stringWithFormat:@"%d", self.circle.reminders.count];
    
    [self userQuery];
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


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
        controller.currentUSer = self.currentUser;
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

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageWithColor:[UIColor whiteColor] cornerRadius:1.0f];
    av.image = background;
    cell.backgroundView = av;
    
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    cell.textLabel.font = [UIFont boldFlatFontOfSize:16];
    cell.detailTextLabel.font = [UIFont flatFontOfSize:16];
    cell.detailTextLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Other Methods

- (IBAction)leaveCircle:(id)sender {
    
    if (self.circle.members.count > 1) {
        NSString *message = @"Are you sure you want to leave this circle?";
        
        UIColor *barColor = [UIColor colorFromHexCode:@"FF4100"];
        
        FUIAlertView *alertView = [[FUIAlertView alloc]
                                   initWithTitle:[NSString stringWithFormat:@"Leaving %@", self.circle.name]
                                   message:message
                                   delegate:self
                                   cancelButtonTitle:@"No"
                                   otherButtonTitles:@"Yes", nil];
        
        alertView.tag = TAG_LEAVE;
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
        alertView.alertContainer.backgroundColor = barColor;
        alertView.defaultButtonColor = [UIColor cloudsColor];
        alertView.defaultButtonShadowColor = [UIColor asbestosColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor asbestosColor];
        
        
        [alertView show];
    } else {
        NSString *message = @"You are the last member of this circle. By leaving you will disband this circle. Are you sure you want leave?";
        
        UIColor *barColor = [UIColor colorFromHexCode:@"FF4100"];
        
        FUIAlertView *alertView = [[FUIAlertView alloc]
                                   initWithTitle:[NSString stringWithFormat:@"Leaving %@", self.circle.name]
                                   message:message
                                   delegate:self
                                   cancelButtonTitle:@"No"
                                   otherButtonTitles:@"Yes", nil];
        
        alertView.tag = TAG_DISBAND;
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:16];
        alertView.messageLabel.textColor = [UIColor cloudsColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:14];
        alertView.backgroundOverlay.backgroundColor = [UIColor clearColor];
        alertView.alertContainer.backgroundColor = barColor;
        alertView.defaultButtonColor = [UIColor cloudsColor];
        alertView.defaultButtonShadowColor = [UIColor asbestosColor];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor asbestosColor];
        
        
        [alertView show];
    }
}

- (void)leave
{
    [userObject removeObject:self.circle forKey:@"circles"];
    [self.circle removeObject:userObject forKey:@"members"];
    [self.circle removeObject:userObject.user forKey:@"memberUsernames"];
    
    [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.circle saveInBackground];
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Left %@", self.circle.displayName]];
        [self performSegueWithIdentifier:@"UnwindToCircles" sender:nil];
    }];
    
}

- (void)disband
{
    NSMutableArray *postsToDelete = [[NSMutableArray alloc] init];
    [userObject removeObject:self.circle forKey:@"circles"];
    
    for (SocialPosts *post in self.circle.posts) {
        [postsToDelete addObject:post];
    }

    [self.circle deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [SocialPosts deleteAllInBackground:postsToDelete block:^(BOOL succeeded, NSError *error) {
            [userObject saveInBackground];
        }];;
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Left %@", self.circle.displayName]];
        [self performSegueWithIdentifier:@"UnwindToCircles" sender:nil];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_LEAVE) {
        if (buttonIndex == 0) {
            [self leave];
        }
    } else {
        if (buttonIndex == 0) {
            [self disband];
        }
    }
}

@end
