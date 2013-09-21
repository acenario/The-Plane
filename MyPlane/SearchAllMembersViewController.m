//
//  SearchAllMembersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/5/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "SearchAllMembersViewController.h"

#import "CurrentUser.h"
#import "Reachability.h"

@interface SearchAllMembersViewController ()
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic,strong) UzysSlideMenu *uzysSMenu;
@property (nonatomic, strong) CurrentUser *sharedManaged;

@end

@implementation SearchAllMembersViewController {
    NSMutableArray *friendsArray;
    NSMutableArray *searchResults;
    NSMutableArray *selectedUsers;
    PFQuery *currentUserQuery;
    PFQuery *friendQuery;
    UserInfo *userObject;
    Reachability *reachability;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.sharedManaged = [CurrentUser sharedManager];
    
    [self.searchBar becomeFirstResponder];
    self.searchBar.delegate = self;
    UIColor *barColor = [UIColor colorFromHexCode:@"FF4100"];
    [[UISearchBar appearance] setBackgroundColor:barColor];
    [self configureViewController];
    
    //self.searchResults = [NSMutableArray array];
    //friendsUNArray = [NSMutableArray array];
    reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    if(reachability.currentReachabilityStatus == NotReachable) {
		self.doneBtn.enabled = NO;
	} else {
		self.doneBtn.enabled = YES;
        [self currentUserQuery];
    }
    
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"Remove Picture" image:[UIImage imageNamed:@"a1.png"] action:^(UzysSMMenuItem *item) {
        [self removePicture];
    }];
    item0.tag = 0;
    
    UzysSMMenuItem *item3 = [[UzysSMMenuItem alloc] initWithTitle:@"Ban User" image:[UIImage imageNamed:@"a1.png"] action:^(UzysSMMenuItem *item) {
        [self banUsers];
    }];
    item0.tag = 3;
    
    if (self.sharedManaged.currentUser.adminRank == 1) {
        UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Promote Selected Users to Admin" image:[UIImage imageNamed:@"a0.png"] action:^(UzysSMMenuItem *item) {
            [self promoteSelectedUsers];
        }];
        item0.tag = 1;
        
        self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0, item3, item1]];
    } else {
        self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0, item3]];;
    }
    
    [self.view addSubview:self.uzysSMenu];
    
    selectedUsers = [[NSMutableArray alloc] initWithCapacity:5];
    
    //    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    //    [self.tableView addGestureRecognizer:gestureRecognizer];
    //    gestureRecognizer.cancelsTouchesInView = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.tableView reloadData];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
	if(reachability.currentReachabilityStatus == NotReachable) {
		self.doneBtn.enabled = NO;
	} else {
		self.doneBtn.enabled = YES;
    }
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.rowHeight = 70;
    
    self.tableView.backgroundView = av;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

- (void)currentUserQuery
{
    currentUserQuery = [UserInfo query];
    [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    //[currentUserQuery includeKey:@"friends"];
    //[currentUserQuery includeKey:@"friends.user"];
    currentUserQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            //friendsArray = object.friends;
            userObject = object;
            friendsArray = [[NSMutableArray alloc]initWithArray:object.friends];
//            sentFriendRequestsArray = [[NSMutableArray alloc]initWithArray: object.sentFriendRequests];
        }
//        [self getIDs];
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

/*- (void)getUsername;
 {
 
 NSMutableArray *userName = [[NSMutableArray alloc]init];
 for (UserInfo *object in friendsArray) {
 NSString *name = object.user;
 [userName addObject:name];
 }
 friendsUNArray = userName;
 }*/

- (void)filterResults:(NSString *)searchTerm
{
    NSString *newTerm = [searchTerm lowercaseString];
    
    //[self.searchResults removeAllObjects];
    
    friendQuery = [UserInfo query];
    [friendQuery whereKey:@"user" hasPrefix:newTerm];
    
    if (searchResults.count == 0) {
        friendQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [searchResults removeAllObjects];
        searchResults = [[NSMutableArray alloc] initWithArray:[friendQuery findObjects]];
        /*NSArray *results = [query findObjects];
         [self.searchResults addObjectsFromArray:results];*/
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *uniqueIdentifier = @"Cell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    if (searchResults.count > 0) {
        UILabel *name = (UILabel *)[cell viewWithTag:1];
        UILabel *username = (UILabel *)[cell viewWithTag:2];
        PFImageView *picImage = (PFImageView *)[cell viewWithTag:11];
//        UIButton *addButton = (UIButton *)[cell viewWithTag:2121];
//        addButton.enabled = YES;
        
        UserInfo *searchedUser = [searchResults objectAtIndex:indexPath.row];
        name.text = [NSString stringWithFormat:@"%@ %@", searchedUser.firstName, searchedUser.lastName];
        username.text = searchedUser.user;
        picImage.file = searchedUser.profilePicture;
        
        [picImage loadInBackground];
        
        NSArray *users = [[NSArray alloc] initWithArray:selectedUsers];
        if ([users containsObject:searchedUser]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
//        [addButton addTarget:self action:@selector(adjustButtonState:) forControlEvents:UIControlEventTouchUpInside];
        
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
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:2101];
    UILabel *usernameLabel = (UILabel *)[cell viewWithTag:2101];
    
    nameLabel.font = [UIFont flatFontOfSize:16];
    usernameLabel.font = [UIFont flatFontOfSize:14];
    nameLabel.adjustsFontSizeToFitWidth = YES;
    usernameLabel.adjustsFontSizeToFitWidth = YES;
    
    nameLabel.textColor = [UIColor colorFromHexCode:@"A62A00"];
    
    
    return cell;
}

//- (IBAction)adjustButtonState:(id)sender
//{
//    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
//    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
////    UserInfo *friendAdded = [searchResults objectAtIndex:clickedButtonPath.row];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //    Circles *circle = (Circles *)[self.objects objectAtIndex:0];
    UserInfo *user = (UserInfo *)[self.objects objectAtIndex:indexPath.row];
    
    NSUInteger index = [selectedUsers indexOfObject:user];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedUsers removeObjectAtIndex:index];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedUsers addObject:user];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}

- (void)options:(id)sender
{
    [self.uzysSMenu toggleMenu];
}

- (void)banUsers
{
    NSLog(@"We'll implement banning later");
}

- (void)removePicture
{
    if (selectedUsers.count > 0) {
        NSMutableArray *users = [[NSMutableArray alloc] init];
        for (UserInfo *user in selectedUsers) {
            if (user.adminRank != 0) {
                [user removeObjectForKey:@"profilePicture"];
                [users addObject:[UserInfo objectWithoutDataWithObjectId:user.objectId]];
                NSLog(@"%d", user.adminRank);
            }
            NSLog(@"%@", users);
        }
        
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat: @"Removed %d Profile Pictures", users.count]];
        [UserInfo saveAllInBackground:users block:^(BOOL succeeded, NSError *error) {
            [selectedUsers removeAllObjects];
            [self loadObjects];
            [self.tableView reloadData];
        }];
        
    } else {
        [SVProgressHUD showErrorWithStatus:@"No Users Selected"];
    }
[self.uzysSMenu toggleMenu];
}

- (void)promoteSelectedUsers
{
    NSLog(@"Promote");
}

@end
