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
    [self configureViewController];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    self.tableView.rowHeight = 70;
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
    
    UILabel *name = (UILabel *)[cell viewWithTag:6201];
    UILabel *username = (UILabel *)[cell viewWithTag:6202];
    PFImageView *userImage = (PFImageView *)[cell viewWithTag:6211];
    FUIButton *removeMember = (FUIButton *)[cell viewWithTag:6241];
    
    UserInfo *user = [invitedMembers objectAtIndex:indexPath.row];
    
    name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    username.text = user.user;
    userImage.file = user.profilePicture;
    [userImage loadInBackground];
    
    [removeMember addTarget:self action:@selector(removeInvitedMember:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"list-item"];
    av.image = background;
    
    cell.backgroundView = av;
    
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:6201];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:6202];
    FUIButton *removeBtn = (FUIButton *)[cell viewWithTag:6241];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    
    removeBtn.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
    removeBtn.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
    removeBtn.shadowHeight = 2.0f;
    removeBtn.cornerRadius = 3.0f;
    removeBtn.titleLabel.font = [UIFont boldFlatFontOfSize:13];
    
    [removeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [removeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    
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
//    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        PFRelation *relation = [self.circle relationforKey:@"requests"];
        NSMutableArray *requestsToSave = [[NSMutableArray alloc] initWithCapacity:invitedMembers.count];
        NSMutableArray *usersToSave = [[NSMutableArray alloc] initWithCapacity:invitedMembers.count];
        
        for (UserInfo *user in invitedMembers) {
            [user incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:1]];
            
            [usersToSave addObject:user];
            
            Requests *request = [Requests object];
            
            [request setCircle:self.circle];
            [request setSender:self.currentUser];
            [request setSenderUsername:self.currentUser.user];
            [request setReceiver:user];
            [request setReceiverUsername:user.user];
            
            [self.circle addObject:user.user forKey:@"pendingMembers"];
            
            [requestsToSave addObject:request];
            
        };
        [UserInfo saveAllInBackground:usersToSave block:^(BOOL succeeded, NSError *error) {
            [Requests saveAllInBackground:requestsToSave block:^(BOOL succeeded, NSError *error) {
                for (Requests *request in requestsToSave) {
                    [relation addObject:request];
                }
                [self.circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%d Members Invited", invitedMembers.count]];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }];
            }];
        }];
    }
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
