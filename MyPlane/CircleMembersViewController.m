//
//  CircleMembersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/25/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "CircleMembersViewController.h"

@interface CircleMembersViewController ()

@end

@implementation CircleMembersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}
 
- (PFQuery *)queryForTable
{
    PFQuery *query = [Circles query];
    [query whereKey:@"name" equalTo:self.circle.name];
    [query includeKey:@"members"];
    
    return query;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.rowHeight = 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *identifier = @"Cell";
    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    
    UILabel *name = (UILabel *)[cell viewWithTag:6401];
    UILabel *username = (UILabel *)[cell viewWithTag:6402];
    PFImageView *image = (PFImageView *)[cell viewWithTag:6411];
    
    Circles *circle = (Circles *)object;
    UserInfo *member = (UserInfo *)[circle.members objectAtIndex:indexPath.row];
    
    name.text = [NSString stringWithFormat:@"%@ %@", member.firstName, member.lastName];
    username.text = member.user;
    image.file = member.profilePicture;
    
    [image loadInBackground];
    
    return cell;
}

@end
