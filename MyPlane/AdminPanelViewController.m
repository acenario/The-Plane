//
//  AdminPanelViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/4/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "AdminPanelViewController.h"
#import "SubclassHeader.h"
#import "Reachability.h"
#import "CurrentUser.h"

@interface AdminPanelViewController ()

@end

@implementation AdminPanelViewController {
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
}
//
//- (void)reachabilityChanged:(NSNotification*)notification
//{
//	if(reachability.currentReachabilityStatus == NotReachable) {
//        [self dismissViewControllerAnimated:YES completion:^{
//            [SVProgressHUD showErrorWithStatus:@"Internet Connect Failed"];
//        }];
//	}
//}
//
-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.rowHeight = 70;
    
    self.tableView.backgroundView = av;
}

- (void)objectsDidLoad:(NSError *)error
{
    //    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
/*
//- (IBAction)adjustButtonState:(id)sender
//{
//    UITableViewCell *clickedCell = (UITableViewCell *)[[sender superview] superview];
//    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
////    UserInfo *friendAdded = (UserInfo *)[self.objects objectAtIndex:clickedButtonPath.row];
//    //NSString *friendAddedName = friendAdded.user;
//    NSString *friendObjectID = friendAdded.objectId;
//    NSString *userID = userObject.objectId;
//    
//    UserInfo *friendToAdd = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:friendObjectID];
//    UserInfo *userObjectID = [UserInfo objectWithoutDataWithClassName:@"UserInfo" objectId:userID];
//    
//    [sentFriendRequestsObjectId addObject:friendAdded.objectId];
//    //[userObject addObject:friendAdded forKey:@"sentFriendRequests"];
//    [userObject addObject:friendToAdd forKey:@"sentFriendRequests"];
//    [userObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        CurrentUser *sharedManager = [CurrentUser sharedManager];
//        sharedManager.currentUser = userObject;
//        //[friendAdded addObject:userObject forKey:@"receivedFriendRequests"];
//        [friendAdded addObject:userObjectID forKey:@"receivedFriendRequests"];
//        [friendAdded saveInBackground];
//        
//        [SVProgressHUD showSuccessWithStatus:@"Friend Request Sent"];
//        
//        //        NSDictionary *data = @{
//        //                               @"f": @"add"
//        //                               };
//        //
//        //        PFQuery *pushQuery = [PFInstallation query];
//        //        [pushQuery whereKey:@"user" equalTo:friendAddedName];
//        //
//        //        PFPush *push = [[PFPush alloc] init];
//        //        [push setQuery:pushQuery];
//        //        [push setData:data];
//        //        [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        //        }];
//        
//    }];
//    
//    UIButton *addFriendButton = (UIButton *)sender;
//    addFriendButton.enabled = NO;
//
//}
*/
 
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Search"]) {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
