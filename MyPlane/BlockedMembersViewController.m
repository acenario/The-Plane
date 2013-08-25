//
//  BlockedMembersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "BlockedMembersViewController.h"

@interface BlockedMembersViewController ()

@end

@implementation BlockedMembersViewController {
    NSMutableArray *selectedUsers;
    UserInfo *currentUser;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.rowHeight = 70;
    self.unblockButton.enabled = NO;
    selectedUsers = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    [query includeKey:@"blockedUsers"];
    
    if (currentUser.blockedUsers.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    return query;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.objects.count > 0) {
        currentUser = (UserInfo *)[self.objects objectAtIndex:0];
        return currentUser.blockedUsers.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    UserInfo *user = [currentUser.blockedUsers objectAtIndex:indexPath.row];
    
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    UILabel *username = (UILabel *)[cell viewWithTag:2];
    PFImageView *image = (PFImageView *)[cell viewWithTag:11];
    
    name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    username.text = user.user;
    image.file = user.profilePicture;
    [image loadInBackground];
    
    if ([selectedUsers containsObject:user]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UserInfo *user = (UserInfo *)[currentUser.blockedUsers objectAtIndex:indexPath.row];
    
    NSUInteger index = [selectedUsers indexOfObject:user];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedUsers removeObjectAtIndex:index];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedUsers addObject:user];
    }
    [self configureDoneButton];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)unblock:(id)sender {
    for (UserInfo *user in selectedUsers) {
        [currentUser removeObject:[UserInfo objectWithoutDataWithObjectId:user.objectId] forKey:@"blockedUsers"];
        [currentUser removeObject:user.user forKey:@"blockedUsernames"];
    }
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self loadObjects];
    }];
}

- (void)configureDoneButton
{
    if (selectedUsers.count > 0) {
        self.unblockButton.enabled = YES;
    } else {
        self.unblockButton.enabled = NO;
    }
}

@end
