//
//  FixNullValuesViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 12/28/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FixNullValuesViewController.h"

@interface FixNullValuesViewController ()

@end

@implementation FixNullValuesViewController

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.parseClassName = @"UserInfo";
        self.loadingViewEnabled = YES;
        
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

- (PFQuery *)queryForTable {
    PFQuery *query = [UserInfo query];
    
//    [query whereKeyDoesNotExist:@"hidden"];
    [query whereKey:@"hidden" notEqualTo:[NSNumber numberWithBool:YES]];
    return query;
}

- (IBAction)fix:(id)sender {
    NSMutableArray *fixthese = [[NSMutableArray alloc] init];
    
    for (UserInfo *user in self.objects) {
        if (!user.hidden) {
            user.hidden = NO;
            [fixthese addObject:user];
        }
    }
    
    [UserInfo saveAllInBackground:fixthese block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self loadObjects];
            [SVProgressHUD showSuccessWithStatus:@"Done"];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UserInfo *user = (UserInfo *)object;
    
    cell.textLabel.text = user.user;
    if (!user.hidden) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Hidden: NO"];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Hidden: %hhd", user.hidden];

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Set To Yes" message:nil delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Yes", nil];
    
    [alertView show];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        UserInfo *user = (UserInfo *)[self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        
        user.hidden = YES;
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@ hidden", user.user]];
            }
        }];
    }
}

@end
