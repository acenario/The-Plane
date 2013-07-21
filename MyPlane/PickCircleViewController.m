//
//  PickCircleViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/19/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "PickCircleViewController.h"

@interface PickCircleViewController ()

@end

@implementation PickCircleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForTable
{
    PFQuery *query = [Circles query];
    [query whereKey:@"members" matchesQuery:self.userQuery];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    static NSString *identifier = @"CircleCell";
    PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    NSArray *members = [object objectForKey:@"members"];
    
    cell.textLabel.text = [object objectForKey:@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%d member(s)", members.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Circles *object = [self.objects objectAtIndex:indexPath.row];
    [self.delegate pickCircleViewController:self didSelectCircle:object];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
