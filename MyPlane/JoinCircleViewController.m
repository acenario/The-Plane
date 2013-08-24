//
//  JoinCircle.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/22/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "JoinCircleViewController.h"

@interface JoinCircleViewController ()

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@end

@implementation JoinCircleViewController {
    NSMutableArray *circlesArray;
    NSMutableArray *searchResults;
    PFQuery *circleQuery;
    UserInfo *userObject;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = NO;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        self.parseClassName = @"Circles";
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;
    [self configureViewController];
    [self currentUserQuery];
    
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.rowHeight = 60;
    
    self.tableView.backgroundView = av;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)currentUserQuery
{
    PFQuery *currentUserQuery = [UserInfo query];
    [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            userObject = object;
        }
    }];
}

- (void)filterResults:(NSString *)searchTerm
{
    NSString *newTerm = [searchTerm lowercaseString];
    //    NSLog(@"%@", newTerm);
    circleQuery = [Circles query];
    [circleQuery whereKey:@"name" containsString:newTerm];
    [circleQuery whereKey:@"public" equalTo:[NSNumber numberWithBool:YES]];
//    [circleQuery includeKey:@"requests"];
    [circleQuery includeKey:@"members"];
    
    if (self.objects.count == 0) {
        circleQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [searchResults removeAllObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:[circleQuery findObjects]];
        
        [self loadObjects];
    });
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterResults:searchBar.text];
    [searchBar resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    //NSLog(@"Rows upon NumberofRowsInSections %d", self.searchResults.count);
    return searchResults.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *uniqueIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    
    if (searchResults.count > 0) {
        UILabel *name = (UILabel *)[cell viewWithTag:6101];
        UILabel *membersLabel = (UILabel *)[cell viewWithTag:6102];
        FUIButton *addButton = (FUIButton *)[cell viewWithTag:6131];
        addButton.hidden = YES;
        
        Circles *searchedCircle = [searchResults objectAtIndex:indexPath.row];
        name.text = searchedCircle.displayName;
        membersLabel.text = [NSString stringWithFormat:@"%d member(s)", searchedCircle.members.count];
        
        NSMutableArray *objIds = [[NSMutableArray alloc] init];
        NSMutableArray *names = [[NSMutableArray alloc ] init];
        
        for (NSString *usernames in searchedCircle.memberUsernames) {
            [objIds addObject:usernames];
        }
        
        if (searchedCircle.pendingMembers.count > 0) {
            for (NSString *name in searchedCircle.pendingMembers) {
                [names addObject:name];
            }
        }
        
        if ((![objIds containsObject:userObject.user]) && (![names containsObject:userObject.user]) ) {
            addButton.hidden = NO;
        }
        
        if ([searchedCircle.privacy isEqualToString:@"closed"]) {
            [addButton setTitle:@"Request" forState:UIControlStateNormal];
            [addButton addTarget:self action:@selector(requestToJoin:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [addButton addTarget:self action:@selector(adjustButtonState:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
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
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:6101];
    UILabel *memberCount = (UILabel *)[cell viewWithTag:6102];
    FUIButton *joinBtn = (FUIButton *)[cell viewWithTag:6131];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    memberCount.font = [UIFont flatFontOfSize:12];
    
    nameLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    
    joinBtn.buttonColor = [UIColor colorFromHexCode:@"FF7140"];
    joinBtn.shadowColor = [UIColor colorFromHexCode:@"FF9773"];
    joinBtn.shadowHeight = 2.0f;
    joinBtn.cornerRadius = 3.0f;
    joinBtn.titleLabel.font = [UIFont boldFlatFontOfSize:13];
    
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    nil;
    [self.searchBar resignFirstResponder];
}

- (void)adjustButtonState:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    Circles *circle = [searchResults objectAtIndex:clickedButtonPath.row];
    UIButton *addFriendButton = (UIButton *)sender;
    addFriendButton.hidden = YES;
    
    [circle addObject:userObject forKey:@"members"];
    [circle addObject:userObject.user forKey:@"memberUsernames"];
    
    if ([circle.pendingMembers containsObject:userObject.user]) {
        [circle removeObject:userObject.user forKey:@"pendingMembers"];
    }
    [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self loadObjects];
        }];
    }];
    
}

- (void)requestToJoin:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    Circles *circle = [searchResults objectAtIndex:clickedButtonPath.row];
    UIButton *addFriendButton = (UIButton *)sender;
    addFriendButton.hidden = YES;
    
    Requests *request = [Requests object];
    
    request.receiver = userObject;
    request.receiverUsername = [PFUser currentUser].username;
    request.circle = circle;
    NSMutableArray *usersToSave = [[NSMutableArray alloc] initWithCapacity:circle.members.count];
    
    [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFRelation *relation = [circle relationforKey:@"requests"];
        [relation addObject:request];
        [circle addObject:userObject.user forKey:@"pendingMembers"];
        [circle saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            for (UserInfo *user in circle.members) {
                [user incrementKey:@"circleRequestsCount" byAmount:[NSNumber numberWithInt:1]];
                [usersToSave addObject:user];
            }
            [UserInfo saveAllInBackground:usersToSave];
            [SVProgressHUD showSuccessWithStatus:@"Request Sent"];
        }];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate joinCircleViewControllerDidFinishAddingFriends:self];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
