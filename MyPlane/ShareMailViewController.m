//
//  ShareMailViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 9/3/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ShareMailViewController.h"

@interface ShareMailViewController ()

@property (nonatomic, strong) NSMutableArray *firstNames;
@property (nonatomic, strong) NSMutableArray *lastNames;
@property (nonatomic, strong) NSMutableArray *emails;
@property (nonatomic, strong) NSMutableArray *lastNameIndex;
@property (nonatomic, strong) NSMutableArray *selectedEmails;


@end

@implementation ShareMailViewController

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
    self.firstNames = [[NSMutableArray alloc] initWithArray:[self.dictionary objectForKey:@"first"]];
    self.lastNames = [[NSMutableArray alloc] initWithArray:[self.dictionary objectForKey:@"last"]];
    self.emails = [[NSMutableArray alloc] initWithArray:[self.dictionary objectForKey:@"email"]];
    //    NSLog(@"%@", self.lastNames);
    
    self.lastNameIndex = [[NSMutableArray alloc] init];
    self.selectedEmails = [[NSMutableArray alloc] initWithArray:self.emails];
    self.doneButton.enabled = YES;
    
    for (NSString *lastName in self.lastNames){
        //---get the first char of each state---
        char alphabet = [lastName characterAtIndex:0];
        NSString *uniChar = [NSString stringWithFormat:@"%c", alphabet];
        
        //---add each letter to the index array---
        if (![self.lastNameIndex containsObject:uniChar])
        {
            [self.lastNameIndex addObject:uniChar];
        }
    }
    
    self.navigationItem.title = @"Select Contacts";
    self.tableView.rowHeight = 60;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return self.lastNameIndex.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.lastNameIndex objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //---get the letter in each section; e.g., A, B, C, etc.---
    NSString *alphabet = [self.lastNameIndex objectAtIndex:section];
    
    //---get all states beginning with the letter---
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alphabet];
    NSArray *states = [self.lastNames filteredArrayUsingPredicate:predicate];
    
    //---return the number of states beginning with the letter---
    return [states count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *firstname = (UILabel *)[cell viewWithTag:1];
    UILabel *lastname = (UILabel *)[cell viewWithTag:2];
    UILabel *email = (UILabel *)[cell viewWithTag:3];
    //---get the letter in the current section---
    NSString *alphabet = [self.lastNameIndex objectAtIndex:indexPath.section];
    
    //---get all states beginning with the letter---
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alphabet];
    NSArray *lastNames = [self.lastNames filteredArrayUsingPredicate:predicate];
    lastname.text = [lastNames objectAtIndex:indexPath.row];
    int path = [self.lastNames indexOfObject:lastname.text];
        
    firstname.text = [self.firstNames objectAtIndex:path];
    email.text = [self.emails objectAtIndex:path];
    
    if ([self.selectedEmails containsObject:email.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
//    self.doneButton.enabled = ([self.selectedEmails containsObject:email.text]);
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    NSString *alphabet = [self.lastNameIndex objectAtIndex:indexPath.section];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alphabet];
    NSArray *lastNames = [self.lastNames filteredArrayUsingPredicate:predicate];
    NSString *lastname = [lastNames objectAtIndex:indexPath.row];
    
    int index = [self.lastNames indexOfObject:lastname];
    NSString *email = [self.emails objectAtIndex:index];
    int path = [self.selectedEmails indexOfObject:email];

    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedEmails removeObjectAtIndex:path];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedEmails addObject:[self.emails objectAtIndex:index]];
    }
//    NSLog(@"%@", self.selectedEmails);
    [self configureDoneButton];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showMail
{
    MFMailComposeViewController *mViewController = [[MFMailComposeViewController alloc] init];
    mViewController.mailComposeDelegate = self;
    [mViewController setSubject:@"Try out Hey! Heads Up"];
    [mViewController setMessageBody:@"Insert sample promotion code" isHTML:NO];
    [mViewController setToRecipients:self.selectedEmails];
    [self presentViewController:mViewController animated:YES completion:nil];
    
    [[mViewController navigationBar] setTintColor:[UIColor colorFromHexCode:@"FF4100"]];
    UIImage *image = [UIImage imageNamed: @"custom_nav_background.png"];
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,320,42)];
    iv.image = image;
    iv.contentMode = UIViewContentModeCenter;
    [[[mViewController viewControllers] lastObject] navigationItem].titleView = iv;
    [[mViewController navigationBar] sendSubviewToBack:iv];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)configureDoneButton
{
    self.doneButton.enabled = (self.selectedEmails.count > 0);
}

- (IBAction)done:(id)sender {
    [self showMail];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
