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
    BOOL isAdmin;
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
    CurrentUser *sharedmanager = [CurrentUser sharedManager];
    PFQuery * currentUserQuery = [UserInfo query];
    [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    currentUserQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            userObject = object;
           
            NSLog(@"singleton: %@", sharedmanager.currentUser.user);
        }
    }];
    NSLog(@"singleton DUO: %@", sharedmanager.currentUser.user);
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
    
    if (![self.circle.admins containsObject:[PFUser currentUser].username]) {
        self.inviteCell.hidden = YES;
        self.inviteCell.frame = CGRectMake(0, 0, 0, 0);
        isAdmin = NO;
    } else {
        isAdmin = YES;
    }
    
    [self userQuery];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    PFQuery *query = [Circles query];
    [query includeKey:@"owner"];
    [query includeKey:@"members"];
    [query includeKey:@"adminPointers"];
    [query includeKey:@"posts"];
    [query includeKey:@"requestsArray"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query getObjectInBackgroundWithId:self.circle.objectId block:^(PFObject *object, NSError *error) {
        self.circle = (Circles *)object;
        if (![self.circle.admins containsObject:[PFUser currentUser].username]) {
            self.inviteCell.hidden = YES;
            self.inviteCell.frame = CGRectMake(0, 0, 0, 0);
            isAdmin = NO;
        } else {
            self.inviteCell.hidden = NO;
//            self.inviteCell.frame = CGRectMake(0, 0, 0, 0);
            isAdmin = YES;
        }
    }];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((!isAdmin) && (indexPath.section == 1)) {
        return 1;
    } else {
        return 44;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ((!isAdmin) && (section < 2)) {
        if (section == 0) {
            return 7;
        }
        return 2;
    } else {
        return 10;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((!isAdmin) && (section > 0) && (section < 3)) {
        if (section == 2) {
            return 7;
        }
        return 1;
    } else {
        return 10;
    }
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
        controller.currentUser = self.currentUser;
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
        
        UIColor *barColor = [UIColor colorFromHexCode:@"A62A00"];
//        UIColor *barColor = [UIColor wetAsphaltColor];
        
        FUIAlertView *alertView = [[FUIAlertView alloc]
                                   initWithTitle:[NSString stringWithFormat:@"Leaving %@", self.circle.displayName]
                                   message:message
                                   delegate:self
                                   cancelButtonTitle:@"No"
                                   otherButtonTitles:@"Yes", nil];
        
        alertView.tag = TAG_LEAVE;
        alertView.titleLabel.textColor = [UIColor cloudsColor];
        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
        alertView.messageLabel.textColor = [UIColor whiteColor];
        alertView.messageLabel.font = [UIFont flatFontOfSize:15];
        alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
        alertView.alertContainer.backgroundColor = barColor;
        alertView.defaultButtonColor = [UIColor colorFromHexCode:@"FF9773"];
        alertView.defaultButtonShadowColor = [UIColor colorFromHexCode:@"BF5530"];
        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
        alertView.defaultButtonTitleColor = [UIColor whiteColor];
        
        
        [alertView show];
    } else {
        NSString *message = @"You are the last member of this circle. By leaving you will disband this circle. Are you sure you want leave?";
        
        UIColor *barColor = [UIColor colorFromHexCode:@"FF4100"];
//        UIColor *barColor = [UIColor wetAsphaltColor];
        
        FUIAlertView *alertView = [[FUIAlertView alloc]
                                   initWithTitle:[NSString stringWithFormat:@"Leaving %@", self.circle.displayName]
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
    [self.circle removeObject:userObject forKey:@"members"];
    [self.circle removeObject:userObject.user forKey:@"memberUsernames"];
    if ([self.circle.admins containsObject:userObject.user]) {
        [self.circle removeObject:userObject forKey:@"adminPointers"];
        [self.circle removeObject:userObject.user forKey:@"admins"];
    }
    NSMutableArray *usersToSave = [[NSMutableArray alloc] init];
    NSMutableArray *requestsToDelete = [[NSMutableArray alloc] init];
    
    for (Requests *request in self.circle.requestsArray) {
        if ([request.senderUsername isEqualToString:[PFUser currentUser].username]) {
            UserInfo *sender = (UserInfo *)request.receiver;
            [sender incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:-1]];
            [self.circle removeObject:request.receiverUsername forKey:@"pendingMembers"];
            [self.circle removeObject:[Requests objectWithoutDataWithObjectId:request.objectId] forKey:@"requestsArray"];
            [usersToSave addObject:sender];
            [requestsToDelete addObject:[Requests objectWithoutDataWithObjectId:request.objectId]];
        } else if ([self.circle.admins containsObject:[PFUser currentUser].username]) {
            [self.currentUser incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:-1]];
            CurrentUser *sharedManager = [CurrentUser sharedManager];
            sharedManager.currentUser = self.currentUser;
            [usersToSave addObject:self.currentUser];
        }
    }
    
//    NSLog(@"self circle: %@", self.circle);
    
    [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"test7");
        [UserInfo saveAllInBackground:usersToSave block:^(BOOL succeeded, NSError *error) {
            NSLog(@"test8");
            [Requests deleteAllInBackground:requestsToDelete block:^(BOOL succeeded, NSError *error) {
                NSLog(@"test9");
            }];
        }];
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Left %@", self.circle.displayName]];
        [self performSegueWithIdentifier:@"UnwindToCircles" sender:nil];
    }];
    
}

- (void)disband
{
    [SVProgressHUD showWithStatus:@"Disbanding circle..."];
    NSMutableArray *postsToDelete = [[NSMutableArray alloc] init];
    NSMutableArray *usersToSave = [[NSMutableArray alloc] init];
    NSMutableArray *requestsToDelete = [[NSMutableArray alloc] init];
    
    //    [userObject removeObject:self.circle forKey:@"circles"];
    
    for (SocialPosts *post in self.circle.posts) {
        [postsToDelete addObject:post];
        NSLog(@"test0");
    }
    
    for (Requests *request in self.circle.requestsArray) {
        if ((request.sender)) {
            UserInfo *sender = (UserInfo *)request.receiver;
            [sender incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:-1]];
            [usersToSave addObject:sender];
            NSLog(@"test3");
        } else if ([self.circle.admins containsObject:[PFUser currentUser].username]) {
            [self.currentUser incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:-1]];
            CurrentUser *sharedManager = [CurrentUser sharedManager];
            sharedManager.currentUser = self.currentUser;
            [usersToSave addObject:self.currentUser];
            NSLog(@"test7");
        }
        [requestsToDelete addObject:[Requests objectWithoutDataWithObjectId:request.objectId]];
        NSLog(@"test8");
    }
    
//    NSLog(@"self circle: %@", self.circle);
    
    [self.circle deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"test9");

        [SocialPosts deleteAllInBackground:postsToDelete block:^(BOOL succeeded, NSError *error) {
            NSLog(@"test10");
            [Requests deleteAllInBackground:requestsToDelete block:^(BOOL succeeded, NSError *error) {
                NSLog(@"test11");
                [UserInfo saveAllInBackground:usersToSave];
            }];
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Left %@", self.circle.displayName]];
            [self performSegueWithIdentifier:@"UnwindToCircles" sender:nil];
        }];
    }];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_LEAVE) {
        if (buttonIndex == 1) {
            [self leave];
        }
    } else {
        if (buttonIndex == 1) {
            [self disband];
        }
    }
}

@end
