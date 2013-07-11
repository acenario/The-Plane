//
//  AddFriendViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController ()

- (IBAction)adjustButtonState:(id)sender;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController {
    NSArray *friendsArray;
    NSMutableArray *friendsUNArray;
    PFQuery *currentUserQuery;
}


- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
        self.parseClassName = @"UserInfo";
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchBar becomeFirstResponder];
    
    self.searchResults = [NSMutableArray array];
    friendsUNArray = [NSMutableArray array];
    [self currentUserQuery];
    
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
    //[currentUserQuery includeKey:@"friends.user"];
    
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (UserInfo *object in objects) {
            friendsArray = object.friends;
            
        }
        [self getUsername];
    }];
}

- (void)getUsername;
{
    
    NSMutableArray *userName = [[NSMutableArray alloc]init];
    for (UserInfo *object in friendsArray) {
        NSString *name = object.user;
        [userName addObject:name];
    }
    friendsUNArray = userName;
}

- (void)filterResults:(NSString *)searchTerm
{
    NSString *newTerm = [searchTerm lowercaseString];
    
    //[self.searchResults removeAllObjects];
    
    PFQuery *query = [UserInfo query];
    [query whereKey:@"user" containsString:newTerm];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.searchResults removeAllObjects];
        NSArray *results = [query findObjects];
        [self.searchResults addObjectsFromArray:results];
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
    return self.searchResults.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *uniqueIdentifier = @"friendCell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    //NSLog(@"Number of Rows within CellforRow %d", self.searchResults.count);
    
    if (self.searchResults.count > 0) {
        UILabel *name = (UILabel *)[cell viewWithTag:2101];
        UILabel *username = (UILabel *)[cell viewWithTag:2102];
        UIImageView *picImage = (UIImageView *)[cell viewWithTag:2111];
        UIButton *addButton = (UIButton *)[cell viewWithTag:2121];
        addButton.enabled = YES;
        
        UserInfo *searchedUser = [self.searchResults objectAtIndex:indexPath.row];
        name.text = [NSString stringWithFormat:@"%@ %@", searchedUser.firstName, searchedUser.lastName];
        username.text = searchedUser.user;
        
        if ([friendsUNArray containsObject:searchedUser.user]) {
            addButton.enabled = NO;
        }
        
        
        [addButton addTarget:self action:@selector(adjustButtonState:) forControlEvents:UIControlEventTouchUpInside];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            PFFile *pictureFile = searchedUser.profilePicture;
            UIImage *profilePic = [[UIImage alloc] initWithData:pictureFile.getData];
            dispatch_async(dispatch_get_main_queue(), ^{
                picImage.image = profilePic;
            });
        });
        
    }
    
    return cell;
}

- (IBAction)adjustButtonState:(id)sender
{
    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            PFObject *friendAdded = (PFObject *)[self.searchResults objectAtIndex:clickedButtonPath.row];
            PFObject *userObject = (PFObject *)[objects objectAtIndex:0];
            [userObject addObject:friendAdded forKey:@"friends"];
            [userObject saveInBackground];
        }
    }];
    
    
    UIButton *addFriendButton = (UIButton *)sender;
    addFriendButton.enabled = NO;
    
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self.delegate addFriendViewControllerDidFinishAddingFriends:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
