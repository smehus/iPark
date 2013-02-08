//
//  ScheduleViewController.m
//  iPark
//
//  Created by scott mehus on 10/25/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import "ScheduleViewController.h"
#import "Location.h"
#import "HudView.h"
#import "NSMutableString+AddText.h"


@implementation ScheduleViewController {
    
    NSDate *dueDate;
    BOOL shouldRemind;
    Location *lastLocation;
}

@synthesize addressLabel;
@synthesize placemark;
@synthesize date;
@synthesize coordinate;
@synthesize locationToEdit; 

@synthesize dueDateLabel;
@synthesize switchControl;

@synthesize managedObjectContext;
@synthesize delegate;
@synthesize imageView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark {
    
   NSMutableString *line = [NSMutableString stringWithCapacity:100];
    
    [line addText:thePlacemark.subThoroughfare withSeparator:@""];
    [line addText:thePlacemark.thoroughfare withSeparator:@" "];
    [line addText:thePlacemark.locality withSeparator:@"\n "];
    [line addText:thePlacemark.administrativeArea withSeparator:@", "];
    //[line addText:thePlacemark.postalCode withSeparator:@" "];
    
    
    
    
    return line;
}

- (void)updateDueDateLabel
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    self.dueDateLabel.text = [formatter stringFromDate:dueDate];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dvsup.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    
   self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.1f];

    
    self.switchControl.onTintColor = [UIColor blackColor];
    //self.switchControl.thumbTintColor = [UIColor blueColor];
    
   
    
    [self updateDueDateLabel];
    
    if (self.locationToEdit != nil) {
        self.title = @"Edit Parking Spot";
    }
    
    self.addressLabel.text = [self stringFromPlacemark:self.placemark];
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    lastLocation = [foundObjects lastObject];

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

#pragma mark - Table view data source





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


- (IBAction)cancel {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)closeScreen {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done {
    
    HudView *hudView = [HudView hudInView:self.navigationController.view animated:YES];
    hudView.text = @"Park'd";
    
    Location *location = nil;

    if (lastLocation != nil) {
        
        location = lastLocation;
        
    } else {
    
    location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    }
    
    location.placemark = self.placemark;
    location.date = dueDate;
    location.remindMe = self.switchControl.on;
    location.latitude = [NSNumber numberWithDouble:self.coordinate.latitude];
    location.longitude = [NSNumber numberWithDouble:self.coordinate.longitude];
    
        
    [location scheduleNotification];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        FATAL_CORE_DATA_ERROR(error)
        return;
    }
    
    
    [self.delegate schedule:self didPickDate:dueDate];
    [self performSelector:@selector(closeScreen) withObject:nil afterDelay:0.6];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 66;
    } else {
        
        return 44;
    }
}



 



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"PickDate"]) {
        
        DatePickerViewController *controller = segue.destinationViewController;
        controller.delegate = self;
        controller.date = dueDate;
        
    }
}


- (void)datePickerDidCancel:(DatePickerViewController *)picker {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)datePicker:(DatePickerViewController *)picker didPickDate:(NSDate *)theDate {
    
    
    dueDate = theDate;
    [self updateDueDateLabel];
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)setLocationToEdit:(Location *)newLocationToEdit {
    
    if (locationToEdit != newLocationToEdit) {
        locationToEdit = newLocationToEdit;
        
        self.addressLabel.text = [self stringFromPlacemark:self.locationToEdit.placemark];
        dueDate = self.locationToEdit.date;
        self.coordinate = CLLocationCoordinate2DMake([locationToEdit.latitude doubleValue], [locationToEdit.longitude doubleValue]);
        self.placemark = locationToEdit.placemark;
        shouldRemind = locationToEdit.remindMe;
        [self updateDueDateLabel];
    }
}


@end
