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
    NSMutableArray *resultsArray;
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)filterResults:(NSString *)searchTerm
{
    NSString *newTerm = [searchTerm lowercaseString];
    
    //[self.searchResults removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
//    [query whereKeyExists:@"firstName"];
//    [query whereKeyExists:@"lastName"];
//    [query whereKeyExists:@"user"];  //this is based on whatever query you are trying to accomplish
    [query whereKey:@"user" containsString:newTerm];
    
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.searchResults removeAllObjects];
        NSLog(@"Number of rows after alledgly clearing %d", self.searchResults.count);
        NSArray *results = [query findObjects];
        [self.searchResults addObjectsFromArray:results];
        [self loadObjects];
    });
    
}

//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
//{
//    NSLog(@"Did End Editing");
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self filterResults:searchBar.text];
    [searchBar resignFirstResponder];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSLog(@"Rows upon NumberofRowsInSections %d", self.searchResults.count);
    if (self.searchResults.count < 1) {
        return 0;
    } else {
        return self.searchResults.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *uniqueIdentifier = @"friendCell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];

    NSLog(@"Number of Rows within CellforRow %d", self.searchResults.count);
    
    if (self.searchResults.count > 0) {
        UILabel *name = (UILabel *)[cell viewWithTag:2101];
        UILabel *username = (UILabel *)[cell viewWithTag:2102];
        UIImageView *picImage = (UIImageView *)[cell viewWithTag:2111];
        [(UIButton *)[cell viewWithTag:2121] addTarget:self action:@selector(adjustButtonState:) forControlEvents:UIControlEventTouchUpInside];
        
        PFObject *searchedUser = [self.searchResults objectAtIndex:indexPath.row];
        NSString *first = [searchedUser objectForKey:@"firstName"];
        NSString *last = [searchedUser objectForKey:@"lastName"];
        
        NSLog(@"%@", first);
        
        name.text = [NSString stringWithFormat:@"%@ %@", first, last];
        username.text = [searchedUser objectForKey:@"user"];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
        PFFile *pictureFile = [searchedUser objectForKey:@"profilePicture"];
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
    
    
    PFQuery *currentUserQuery = [PFQuery queryWithClassName:@"UserInfo"];
    [currentUserQuery whereKey:@"user" equalTo:[PFUser currentUser].username];
    [currentUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            PFObject *friendAdded = (PFObject *)[self.searchResults objectAtIndex:clickedButtonPath.row];
            NSString* userName = [friendAdded objectForKey:@"user"];
            NSLog(@"userName: %@", userName);
            PFObject *userObject = (PFObject *)[objects objectAtIndex:0];
            NSLog(@"%@", userObject);
            [userObject addObject:userName forKey:@"friends"];
            [userObject saveInBackground];
        }
    }];
    
    
    UIButton *addFriendButton = (UIButton *)sender;
    addFriendButton.enabled = NO;
    
}

@end
