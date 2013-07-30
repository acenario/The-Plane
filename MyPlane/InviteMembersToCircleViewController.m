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
//    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;

    [self currentUserQuery];
    
    self.tableView.rowHeight = 60;
    
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
    
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            userObject = object;
            NSMutableArray *subarray = [[NSMutableArray alloc] initWithArray:object.friends];
            for (UserInfo *obj in object.friends) {
                if ([obj.user isEqualToString:[PFUser currentUser].username]) {
                    [subarray removeObject:obj];
                }
            }
            NSLog(@"%@", [subarray objectAtIndex:0]);
            searchResults = [[NSMutableArray alloc] initWithArray:subarray];
            [self loadObjects];
        }
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
    NSString *newTerm = [searchTerm lowercaseString];
        
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" containsString:newTerm];
    [query whereKey:@"user" notEqualTo:[PFUser currentUser].username];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [searchResults removeAllObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:[query findObjects]];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *uniqueIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    
    if (searchResults.count > 0) {
        UILabel *name = (UILabel *)[cell viewWithTag:6301];
        UILabel *username = (UILabel *)[cell viewWithTag:6302];
        PFImageView *picImage = (PFImageView *)[cell viewWithTag:6311];
//        UIButton *addButton = (UIButton *)[cell viewWithTag:2121];
//        addButton.enabled = YES;
        
        UserInfo *searchedUser = [searchResults objectAtIndex:indexPath.row];
        name.text = [NSString stringWithFormat:@"%@ %@", searchedUser.firstName, searchedUser.lastName];
        username.text = searchedUser.user;
        picImage.file = searchedUser.profilePicture;
        
        [picImage loadInBackground];
        
//        NSLog(@"%@", self.currentlyInvitedMembers);
        
        if ([self.invitedUsernames containsObject:searchedUser.user]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSLog(@"yES");
        }
        
    }
        
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UserInfo *user = [searchResults objectAtIndex:indexPath.row];
//    UserInfo *user2 = [UserInfo objectWithoutDataWithObjectId:user.objectId];
    
    NSUInteger index = [self.invitedUsernames indexOfObject:user.user];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.currentlyInvitedMembers removeObjectAtIndex:index];
        NSLog(@"%@", user);
        NSLog(@"%@", self.currentlyInvitedMembers);
        [self.invitedUsernames removeObject:user.user];
        NSLog(@"%@", self.invitedUsernames);
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
