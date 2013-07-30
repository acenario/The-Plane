//
//  CreateCircleViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CreateCircleViewController.h"

@interface CreateCircleViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButton;


@end

@implementation CreateCircleViewController {
    BOOL public;
    NSMutableArray *invitedMembers;
    NSMutableArray *invitedUsernames;
    NSString *circleName;
    UserInfo *currentUser;
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
    
    public = YES;
    
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentUser = (UserInfo *)object;
    }];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
            
        default:
            return invitedMembers.count;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFTableViewCell *cell;
    
    // I configure the cells based on section; where section 0 = Name and Bool cells,
    // section 1 = invite members cell, and section 2 = invited members details.
    
    if (indexPath.section == 0) { // Name and Bool Cells
        
        if (indexPath.row == 0) { // Name Cell
            static NSString *CellIdentifier = @"NameCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            UITextField *name = (UITextField *)[cell viewWithTag:6221];
            name.delegate = self;
            
            [name addTarget:self action:@selector(checkTextField:) forControlEvents:UIControlEventEditingChanged];
            
        } else if (indexPath.row == 1){ // Bool Cell
            static NSString *CellIdentifier = @"BoolCell";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            UISwitch *boolSwitch = (UISwitch *)[cell viewWithTag:6251];
            
            [boolSwitch addTarget:self action:@selector(publicBoolSwitch:) forControlEvents:UIControlEventValueChanged];
        }
        
    } else if (indexPath.section == 1){ // Invite Members (Segue) Cell
        static NSString *CellIdentifier = @"InviteCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        cell.textLabel.text = @"Invite Members";
        
    } else { // Invited members cell(s)
        static NSString *CellIdentifier = @"MemberCell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        UILabel *name = (UILabel *)[cell viewWithTag:6201];
        UILabel *username = (UILabel *)[cell viewWithTag:6202];
        PFImageView *userImage = (PFImageView *)[cell viewWithTag:6211];
        UIButton *removeMember = (UIButton *)[cell viewWithTag:6241];
        
        UserInfo *user = [invitedMembers objectAtIndex:indexPath.row];
        
        name.text = user.firstName;
        username.text = user.user;
        userImage.file = user.profilePicture;
        [userImage loadInBackground];
        
        [removeMember addTarget:self action:@selector(removeInvitedMember:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Other Methods

- (void)publicBoolSwitch:(id)sender {
    UISwitch *boolSwitch = (UISwitch *)sender;
    public = boolSwitch.on;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *nav = [segue destinationViewController];
    InviteMembersToCircleViewController *controller = (InviteMembersToCircleViewController *)nav.topViewController;
    
    controller.delegate = self;
    controller.currentlyInvitedMembers = [[NSMutableArray alloc] initWithArray:invitedMembers];
    controller.invitedUsernames = [[NSMutableArray alloc] initWithArray:invitedUsernames];
}

- (void)inviteMembersToCircleViewController:(InviteMembersToCircleViewController *)controller didFinishWithMembers:(NSMutableArray *)members andUsernames:(NSMutableArray *)usernames
{
    invitedMembers = members;
    invitedUsernames = usernames;
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 2) {
        return 44;
    } else {
        return 60;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((invitedMembers.count > 0) && (section == 2)) {
        return @"Invited Members";
    } else {
        return nil;
    }
}

- (void)checkTextField:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    
    circleName = textField.text;
    if (circleName.length > 0) {
        self.doneBarButton.enabled = YES;
    } else {
        self.doneBarButton.enabled = NO;
    }
}

- (void)removeInvitedMember:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    UserInfo *user = [invitedMembers objectAtIndex:indexPath.row];
    
    [invitedMembers removeObject:user];
    [invitedUsernames removeObject:user.user];
    [self.tableView reloadData];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    Circles *circle = [Circles object];
    circle.name = [circleName lowercaseString];
    circle.searchName = circleName;
    circle.user = [PFUser currentUser].username;
    circle.owner = currentUser;
    circle.public = public;
    [circle addObject:currentUser forKey:@"members"];
    
    if (invitedMembers.count > 0) {
        for (UserInfo *user in invitedMembers) {
            [circle addObject:user forKey:@"pendingMembers"];
        }
    }
     
    [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        for (UserInfo *user in invitedMembers) {
//            NSLog(@"%@", user.circleRequests);
            [user addObject:[Circles objectWithoutDataWithObjectId:circle.objectId] forKey:@"circleRequests"];
            [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                nil;
            }];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

@end
