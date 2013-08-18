//
//  IndependentInviteMenuViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/14/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "IndependentInviteMenuViewController.h"

@interface IndependentInviteMenuViewController ()

@end

@implementation IndependentInviteMenuViewController {
    NSMutableArray *invitedMembers;
    NSMutableArray *invitedUsernames;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    if (invitedMembers.count > 0) {
        self.doneButton.enabled = YES;
    } else {
        self.doneButton.enabled = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return invitedMembers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UITextView *name = (UITextView *)[cell viewWithTag:6201];
    UITextView *username = (UITextView *)[cell viewWithTag:6202];
    PFImageView *userImage = (PFImageView *)[cell viewWithTag:6211];
    UIButton *removeMember = (UIButton *)[cell viewWithTag:6241];
    
    UserInfo *user = [invitedMembers objectAtIndex:indexPath.row];
    
    name.text = user.firstName;
    username.text = user.user;
    userImage.file = user.profilePicture;
    [userImage loadInBackground];
    
    [removeMember addTarget:self action:@selector(removeInvitedMember:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)inviteMembersToCircleViewController:(InviteMembersToCircleViewController *)controller didFinishWithMembers:(NSMutableArray *)members andUsernames:(NSMutableArray *)usernames
{
    invitedMembers = members;
    invitedUsernames = usernames;
    [self.tableView reloadData];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (invitedMembers.count > 0) {
        return @"Invited Members";
    } else {
        //        return @"Invite some friends";
        return nil;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *nav = [segue destinationViewController];
    InviteMembersToCircleViewController *controller = (InviteMembersToCircleViewController *)nav.topViewController;
    
    controller.delegate = self;
    controller.currentlyInvitedMembers = [[NSMutableArray alloc] initWithArray:invitedMembers];
    controller.invitedUsernames = [[NSMutableArray alloc] initWithArray:invitedUsernames];
    controller.circle = self.circle;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    if (invitedMembers.count > 0) {
        for (UserInfo *user in invitedMembers) {
            [self.circle addObject:user forKey:@"pendingMembers"];
        }
    }
    
    [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        for (UserInfo *user in invitedMembers) {
            [user addObject:[Circles objectWithoutDataWithObjectId:self.circle.objectId] forKey:@"circleRequests"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                Requests *request = [Requests object];
                
                [request setCircle:self.circle];
                [request setInvitedBy:self.currentUser];
                [request setInvitedUsername:self.currentUser.user];
                [request setInvited:user];
                [request setInvitedUsername:user.user];
                
                [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    nil;
                }];
            }];
        }
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%d Members Invited", invitedMembers.count]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)removeInvitedMember:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UserInfo *user = [invitedMembers objectAtIndex:indexPath.row];
    
    [invitedMembers removeObject:user];
    [invitedUsernames removeObject:user.user];
    if (invitedMembers.count == 0) {
        self.doneButton.enabled = NO;
    }
    [self.tableView reloadData];
}

@end
