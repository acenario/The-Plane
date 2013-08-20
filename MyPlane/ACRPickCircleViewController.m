//
//  ACRPickCircleViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 8/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ACRPickCircleViewController.h"

@interface ACRPickCircleViewController ()

@end

@implementation ACRPickCircleViewController

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

#pragma mark - Parse Methods

- (PFQuery *)queryForTable
{
    PFQuery *query = [Circles query];
    [query whereKey:@"members" matchesQuery:self.currentUserQuery];
    [query includeKey:@"members"];
    
    return query;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Circles *circle = (Circles *)[self.objects objectAtIndex:indexPath.row];
    cell.textLabel.text = circle.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d Members", circle.members.count];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PickMembers"]) {
        UINavigationController *nav = (UINavigationController *)[segue destinationViewController];
        PickMembersViewController *controller = (PickMembersViewController *)nav.topViewController;
        controller.delegate = self;
        controller.circle = sender;
        controller.isFromCircles = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"PickMembers" sender:(Circles *)[self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
}

- (void)pickMembersViewController:(PickMembersViewController *)controller didFinishPickingMembers:(NSArray *)members withUsernames:(NSArray *)usernames withCircle:(Circles *)circle
{
    NSLog(@"test");
    [self.delegate acrPickCircleViewController:self
                       didFinishPickingMembers:members
                                 withUsernames:usernames
                                    withCircle:circle];
}

@end
