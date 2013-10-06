//
//  FlaggedUsersViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 10/6/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "FlaggedUsersViewController.h"

@interface FlaggedUsersViewController ()

@end

@implementation FlaggedUsersViewController

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
    PFQuery *query = [UserInfo query];
    [query whereKey:@"flagged" equalTo:[NSNumber numberWithBool:YES]];
    
    return query;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserInfo *user = [self.objects objectAtIndex:indexPath.section];
    
    if (indexPath.row == 0) {
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        
        PFImageView *image = (PFImageView *)[cell viewWithTag:11];
        UILabel *name = (UILabel *)[cell viewWithTag:1];
        UILabel *username = (UILabel *)[cell viewWithTag:2];
        
        image.file = user.profilePicture;
        name.text = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
        username.text = user.user;
        
        [image loadInBackground];
        return cell;
    } else {
        PFTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FlagCell"];
                
        cell.detailTextLabel.text = user.fReason;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 70;
            break;
            
        default:
            return 60;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FUIAlertView *alertView = [[FUIAlertView alloc]
                               initWithTitle:@"Admin Panel"
                               message:@"Pick an action."
                               delegate:self
                               cancelButtonTitle:@"Cancel"
                               otherButtonTitles:@"Remove Picture", @"Delete Flag", nil];
    
    UIColor *barColor = [UIColor colorFromHexCode:@"A62A00"];
    alertView.titleLabel.textColor = [UIColor cloudsColor];
    alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
    alertView.messageLabel.textColor = [UIColor whiteColor];
    alertView.messageLabel.font = [UIFont flatFontOfSize:15];
    alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
    alertView.alertContainer.backgroundColor = barColor;
    alertView.defaultButtonColor = [UIColor colorFromHexCode:@"FF9773"];
    alertView.defaultButtonShadowColor = [UIColor colorFromHexCode:@"BF5530"];
    alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
    alertView.defaultButtonTitleColor = [UIColor whiteColor];
    
    [alertView show];
    
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(FUIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self removePicture];
    } else if (buttonIndex == 2) {
        [self deleteFlag];
    } else {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

- (void)removePicture
{
    
    UserInfo *user = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].section];
    
    UIImage *image = [UIImage imageNamed:@"inapropro"];
    NSData *data = UIImagePNGRepresentation(image);
    PFFile *file = [PFFile fileWithName:@"Inappropriate.png" data:data];
//    NSLog(@"%@",image);
    user.profilePicture = file;
    user.flagged = NO;
    user.fReason = @"";
    [user incrementKey:@"flagCount" byAmount:[NSNumber numberWithInt:1]];
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self loadObjects];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }];
}

- (void)deleteFlag
{
    UserInfo *user = [self.objects objectAtIndex:[self.tableView indexPathForSelectedRow].section];
    
    user.flagged = NO;
    user.fReason = @"";
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self loadObjects];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }];

}

@end
