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
    
    self.lastNameIndex = [[NSMutableArray alloc] init];
    
    for (int i=0; i<[self.lastNames count]-1; i++){
        //---get the first char of each state---
        char alphabet = [[self.lastNames objectAtIndex:i] characterAtIndex:0];
        NSString *uniChar = [NSString stringWithFormat:@"%c", alphabet];
        
        //---add each letter to the index array---
        if (![self.lastNameIndex containsObject:uniChar])
        {
            [self.lastNameIndex addObject:uniChar];
        }
    }
    
    self.navigationItem.title = @"Select Contacts";
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
    NSArray *states = [self.lastNameIndex filteredArrayUsingPredicate:predicate];
    
    //---return the number of states beginning with the letter---
    return [states count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    //---get the letter in the current section---
    NSString *alphabet = [self.lastNameIndex objectAtIndex:indexPath.section];
    
    //---get all states beginning with the letter---
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", alphabet];
    NSArray *lastNames = [self.lastNameIndex filteredArrayUsingPredicate:predicate];
    
    if ([lastNames count]>0) {
        //---extract the relevant state from the states object---
        NSString *cellValue = [lastNames objectAtIndex:indexPath.row];
        cell.textLabel.text = cellValue;
//        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
