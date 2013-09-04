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
@property (nonatomic, strong) NSMutableArray *lastNameFullIndex;
@property (nonatomic, strong) NSMutableArray *selectedEmails;


@end

@implementation ShareMailViewController {
    int TrueCellCount;
}

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
//    self.firstNames = [[NSMutableArray alloc] initWithArray:[self.dictionary objectForKey:@"first"]];
    //    NSLog(@"%@", self.lastNames);
    //    self.emails = [[NSMutableArray alloc] initWithArray:[self.dictionary objectForKey:@"email"]];
    
    
    self.lastNames = [[NSMutableArray alloc] initWithCapacity:self.dictionary.count];
    self.lastNameFullIndex = [[NSMutableArray alloc] initWithCapacity:self.dictionary.count];
    self.emails = [[NSMutableArray alloc] initWithCapacity:self.dictionary.count];
    
    for (NSDictionary *dict in self.dictionary) {
        [self.lastNames addObject:[dict objectForKey:@"last"]];
        [self.emails addObject:[dict objectForKey:@"email"]];
    }
    self.selectedEmails = [[NSMutableArray alloc] initWithArray:self.emails];
    
    self.lastNameIndex = [[NSMutableArray alloc] init];
    self.doneButton.enabled = YES;
    self.doneButton.title = [NSString stringWithFormat:@"Done (Send %d invites)", self.selectedEmails.count];
    
    for (NSString *lastName in self.lastNames){
        char alphabet = [lastName characterAtIndex:0];
        NSString *uniChar = [NSString stringWithFormat:@"%c", alphabet];
        [self.lastNameFullIndex addObject:uniChar];
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
    return self.lastNameIndex.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.lastNameIndex objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *alphabet = [self.lastNameIndex objectAtIndex:section];
        
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alphabet];
    NSArray *count = [self.lastNames filteredArrayUsingPredicate:predicate];
    
    return [count count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *firstname = (UILabel *)[cell viewWithTag:1];
    UILabel *lastname = (UILabel *)[cell viewWithTag:2];
    UILabel *email = (UILabel *)[cell viewWithTag:3];
    
    NSString *alphabet = [self.lastNameIndex objectAtIndex:indexPath.section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alphabet];
    NSArray *lastNames = [self.lastNameFullIndex filteredArrayUsingPredicate:predicate];
    
//    NSLog(@"OBJECT AT INDEX %@", [self.dictionary objectAtIndex:[self.lastNameFullIndex indexOfObject:[lastNames objectAtIndex:indexPath.row]] + indexPath.row]);
    
    int path = [self.lastNameFullIndex indexOfObject:[lastNames objectAtIndex:indexPath.row]] + indexPath.row;
    NSDictionary *dict = [self.dictionary objectAtIndex:path];
    
    firstname.text = [dict objectForKey:@"first"];
    lastname.text = [dict objectForKey:@"last"];
    email.text = [dict objectForKey:@"email"];
    
    if ([self.selectedEmails containsObject:email.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
     } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSString *alphabet = [self.lastNameIndex objectAtIndex:indexPath.section];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alphabet];
    NSArray *lastNames = [self.lastNameFullIndex filteredArrayUsingPredicate:predicate];
    
    //    NSLog(@"OBJECT AT INDEX %@", [self.dictionary objectAtIndex:[self.lastNameFullIndex indexOfObject:[lastNames objectAtIndex:indexPath.row]] + indexPath.row]);
    
    int path = [self.lastNameFullIndex indexOfObject:[lastNames objectAtIndex:indexPath.row]] + indexPath.row;
    NSDictionary *dict = [self.dictionary objectAtIndex:path];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedEmails removeObjectAtIndex:[self.selectedEmails indexOfObject:[dict objectForKey:@"email"]]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedEmails addObject:[dict objectForKey:@"email"]];
    }
    
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

- (void)showTexts
{
    MFMessageComposeViewController *mViewController = [[MFMessageComposeViewController alloc] init];
    mViewController.messageComposeDelegate = self;
    [mViewController setBody:@"Insert sample promotion code"];
    [mViewController setRecipients:self.selectedEmails];
    if ([MFMessageComposeViewController canSendText]) {
        [self presentViewController:mViewController animated:YES completion:nil];
    } else {
//        UIColor *barColor = [UIColor colorFromHexCode:@"A62A00"];
//        
//        //NSInteger red   = 178;
//        //NSInteger green = 8;
//        //NSInteger blue  = 56;
//        
//        //UIColor *barColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
//        
//        FUIAlertView *alertView = [[FUIAlertView alloc] initWithTitle:@"Error!"
//                                                              message:@"You are unable to send text messages"
//                                   
//                                                    delegate:nil
//                                                    cancelButtonTitle:@"Okay"
//                                                    otherButtonTitles:nil];
//        
//        
//        alertView.titleLabel.textColor = [UIColor cloudsColor];
//        alertView.titleLabel.font = [UIFont boldFlatFontOfSize:17];
//        alertView.messageLabel.textColor = [UIColor whiteColor];
//        alertView.messageLabel.font = [UIFont flatFontOfSize:15];
//        alertView.backgroundOverlay.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
//        alertView.alertContainer.backgroundColor = barColor;
//        alertView.defaultButtonColor = [UIColor colorFromHexCode:@"FF9773"];
//        alertView.defaultButtonShadowColor = [UIColor colorFromHexCode:@"BF5530"];
//        alertView.defaultButtonFont = [UIFont boldFlatFontOfSize:16];
//        alertView.defaultButtonTitleColor = [UIColor whiteColor];
//        
//        
//        [alertView show];
    }
    
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
    self.doneButton.title = [NSString stringWithFormat:@"Done (Send %d invites)", self.selectedEmails.count];
    self.doneButton.enabled = (self.selectedEmails.count > 0);
}

- (IBAction)done:(id)sender {
    if (self.isForMessages) {
        [self showTexts];
    } else {
        [self showMail];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"D", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
}
- (IBAction)deselectAll:(id)sender {
    
    if (self.selectedEmails.count == 0) {
        [self.selectedEmails removeAllObjects];
        for (NSString *email in self.emails) {
            [self.selectedEmails addObject:email];
        }
        self.deselectAllButton.title = @"Deselect All";
    } else {
        [self.selectedEmails removeAllObjects];
        self.deselectAllButton.title = @"Select All";
    }
    
    [self.tableView reloadData];
    [self configureDoneButton];
}

@end
