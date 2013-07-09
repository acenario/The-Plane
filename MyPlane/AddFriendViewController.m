//
//  AddFriendViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/8/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController () <UISearchDisplayDelegate, UISearchBarDelegate> {
    
}

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;
    self.searchController.delegate = self;
    
    
    CGPoint offset = CGPointMake(0, self.searchBar.frame.size.height);
    self.tableView.contentOffset = offset;
    
    self.searchResults = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (PFQuery *)queryForTable
//{
//    
//    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
//    [query whereKeyExists:@"firstName"];
//    [query whereKeyExists:@"lastName"];
//    [query whereKeyExists:@"user"];  //this is based on whatever query you are trying to accomplish
//    
//    
//    return query;
//}

- (void)filterResults:(NSString *)searchTerm
{
    
    [self.searchResults removeAllObjects];
    
    PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
    [query whereKeyExists:@"firstName"];
    [query whereKeyExists:@"lastName"];
    [query whereKeyExists:@"user"];  //this is based on whatever query you are trying to accomplish
    [query whereKey:@"user" containsString:searchTerm];
    
    NSArray *results  = [query findObjects];
    
    NSLog(@"%@", results);
    NSLog(@"%u", results.count);
    
    [self.searchResults addObjectsFromArray:results];
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterResults:searchString];
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        //if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        return self.objects.count;
        
    } else {
        
        return self.searchResults.count;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    static NSString *uniqueIdentifier = @"friendCell";
    
    PFTableViewCell *cell = (PFTableViewCell *) [self.tableView dequeueReusableCellWithIdentifier:uniqueIdentifier];
    
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        NSString *first = [object objectForKey:@"firstName"];
        NSString *last = [object objectForKey:@"lastName"];
        //cell.textLabel.text = last;
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", first, last];
        cell.detailTextLabel.text = [object objectForKey:@"user"];
    }
    
    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
        
        PFUser *obj2 = [self.searchResults objectAtIndex:indexPath.row];
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];
        PFObject *searchedUser = [query getObjectWithId:obj2.objectId];
        NSString *first = [searchedUser objectForKey:@"firstName"];
        NSString *last = [searchedUser objectForKey:@"lastName"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", first, last];
        cell.detailTextLabel.text = [searchedUser objectForKey:@"user"];
    }
    return cell;
    
}

@end
