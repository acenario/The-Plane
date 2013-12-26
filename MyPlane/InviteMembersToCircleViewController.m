//
//  InviteMembersToCircleViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/23/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "InviteMembersToCircleViewController.h"

@interface InviteMembersToCircleViewController ()

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation InviteMembersToCircleViewController {
    NSMutableArray *searchResults;
    PFQuery *currentUserQuery;
    UserInfo *userObject;
    BOOL didSearch;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        self.parseClassName = @"UserInfo";
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    //    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;
    
    [self currentUserQuery];
    
    
    didSearch = NO;
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

- (void)currentUserQuery
{
    currentUserQuery = [UserInfo query];
    [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [currentUserQuery includeKey:@"friends"];
    currentUserQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    
    [currentUserQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        userObject = (UserInfo *)object;
        NSMutableArray *subarray = [[NSMutableArray alloc] initWithArray:userObject.friends];
        NSMutableArray *usernames = [[NSMutableArray alloc] initWithArray:self.circle.memberUsernames];
        NSMutableArray *pendingMembers = [[NSMutableArray alloc] initWithArray:self.circle.pendingMembers];
        for (UserInfo *friend in userObject.friends) {
            if ([friend.user isEqualToString:[PFUser currentUser].username]) {
                [subarray removeObject:friend];
            } else if ([usernames containsObject:friend.user]) {
                [subarray removeObject:friend];
            } else if ([pendingMembers containsObject:friend.user]) {
                [subarray removeObject:friend];
            }
        }
        
        searchResults = [[NSMutableArray alloc] initWithArray:subarray];
        [self loadObjects];
    }];
}

//-(void)getIDs {
//
//    friendsObjectId = [[NSMutableArray alloc]init];
//    sentFriendRequestsObjectId = [[NSMutableArray alloc] init];
//
//    for (PFObject *object in userObject.friends) {
//        [friendsObjectId addObject:[object objectId]];
//    }
//    for (PFObject *object in userObject.sentFriendRequests) {
//        [sentFriendRequestsObjectId addObject:[object objectId]];
//    }
//
//}

- (void)filterResults:(NSString *)searchTerm
{
    didSearch = YES;
    NSString *newTerm = [searchTerm lowercaseString];
    
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" hasPrefix:newTerm];
    [query whereKey:@"user" notEqualTo:[PFUser currentUser].username];
    [query whereKey:@"user" notContainedIn:self.circle.memberUsernames];
    [query whereKey:@"user" notContainedIn:self.circle.pendingMembers];
    
    if (searchResults.count == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [searchResults removeAllObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:[query findObjects]];
        NSMutableArray *usernames = [[NSMutableArray alloc] initWithArray:self.circle.memberUsernames];
        NSMutableArray *pendingMembers = [[NSMutableArray alloc] initWithArray:self.circle.pendingMembers];
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:searchResults];
        for (UserInfo *friend in self.circle.members) {
            if ([friend.user isEqualToString:[PFUser currentUser].username]) {
                [newArray removeObject:friend];
            } else if ([usernames containsObject:friend.user]) {
                [newArray removeObject:friend];
            } else if ([pendingMembers containsObject:friend.user]) {
                [newArray removeObject:friend];
            }
        }
        searchResults = newArray;
        [self loadObjects];
    });
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterResults:searchBar.text];
    [searchBar resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return searchResults.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (!didSearch) {
        return @"Friends";
    } else {
        return @"Searched Users";
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *uniqueIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    
    if (searchResults.count > 0) {
        
        UILabel *name = (UILabel *)[cell viewWithTag:6301];
        UILabel *username = (UILabel *)[cell viewWithTag:6302];
        PFImageView *picImage = (PFImageView *)[cell viewWithTag:6311];
        
        
        UserInfo *searchedUser = [searchResults objectAtIndex:indexPath.row];
        name.text = [NSString stringWithFormat:@"%@ %@", searchedUser.firstName, searchedUser.lastName];
        username.text = searchedUser.user;
        picImage.file = searchedUser.profilePicture;
        
        [picImage loadInBackground];
        
        if ([self.invitedUsernames containsObject:searchedUser.user]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
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
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:6301];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:6302];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    
    

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UserInfo *user = [searchResults objectAtIndex:indexPath.row];
    //    UserInfo *user2 = [UserInfo objectWithoutDataWithObjectId:user.objectId];
    
    NSUInteger index = [self.invitedUsernames indexOfObject:user.user];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.currentlyInvitedMembers removeObjectAtIndex:index];
        
        [self.invitedUsernames removeObject:user.user];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.currentlyInvitedMembers addObject:user];
        [self.invitedUsernames addObject:user.user];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self.delegate inviteMembersToCircleViewController:self didFinishWithMembers:self.currentlyInvitedMembers andUsernames:self.invitedUsernames];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
