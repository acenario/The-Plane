//
//  ReminderDateViewController.m
//  MyPlane
//
//  Created by Abhijay Bhatnagar on 7/12/13.
//  Copyright (c) 2013 Acubed Productions. All rights reserved.
//

#import "ReminderDateViewController.h"

@interface ReminderDateViewController ()

#define kPickerAnimationDuration 0.40

@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *dateIvar;

@end

@implementation ReminderDateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureViewController];
    
    self.dataArray = [NSArray arrayWithObjects:@"Date", nil];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    self.pickerView.datePickerMode = UIDatePickerModeDateAndTime;
    self.dateDetail.text = self.displayDate;
    
    [self datePicker];
}

-(void)configureViewController {
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageNamed:@"tableBackground"];
    av.image = background;
    
    self.tableView.backgroundView = av;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)datePicker
{
	self.pickerView.date = [self.dateFormatter dateFromString:self.dateDetail.text];
    self.pickerView.minimumDate = [NSDate date];
	
    
    CGRect startFrame = self.pickerView.frame;
    CGRect endFrame = self.pickerView.frame;
    
    // the start position is below the bottom of the visible frame
    startFrame.origin.y = self.view.frame.size.height;
    
    // the end position is slid up by the height of the view
    endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
    
    self.pickerView.frame = startFrame;
    
    [self.view addSubview:self.pickerView];
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:kPickerAnimationDuration];
    self.pickerView.frame = endFrame;
//    [UIView commitAnimations];
    
    // add the "Done" button to the nav bar
    
}


#pragma mark - Other Methods

- (IBAction)dateAction:(id)sender {
    self.dateDetail.text = [self.dateFormatter stringFromDate:self.pickerView.date];
    self.dateIvar = [self.dateFormatter dateFromString:self.dateDetail.text];
    self.doneButton.enabled = YES;
    
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it from the view hierarchy
	[self.pickerView removeFromSuperview];
}

- (IBAction)done:(id)sender
{
    CGRect pickerFrame = self.pickerView.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kPickerAnimationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
    self.pickerView.frame = pickerFrame;
    [UIView commitAnimations];
    
    [self.delegate reminderDateViewController:self didFinishSelectingDate:self.dateIvar];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIColor *selectedColor = [UIColor colorFromHexCode:@"FF7140"];
    
    UIImageView *av = [[UIImageView alloc] init];
    av.backgroundColor = [UIColor clearColor];
    av.opaque = NO;
    UIImage *background = [UIImage imageWithColor:[UIColor whiteColor] cornerRadius:1.0f];
    av.image = background;
    cell.backgroundView = av;
    
    
    UIView *bgView = [[UIView alloc]init];
    bgView.backgroundColor = selectedColor;
    
    
    [cell setSelectedBackgroundView:bgView];
    
    cell.textLabel.font = [UIFont flatFontOfSize:16];
    cell.detailTextLabel.font = [UIFont flatFontOfSize:16];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
    cell.detailTextLabel.backgroundColor = [UIColor whiteColor];
    
}


- (IBAction)cancel:(id)sender
{
    [self.delegate reminderViewControllerDidCancel:self];
}

@end
