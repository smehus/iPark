//
//  ScheduleViewController.h
//  iPark
//
//  Created by scott mehus on 10/25/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerViewController.h"
#import "Location.h"

@class ScheduleViewController;

@protocol ScheduleViewControllerDelegate <NSObject>

- (void)schedule:(ScheduleViewController *)scheduler didPickDate:(NSDate *)theDate;

@end


@interface ScheduleViewController : UITableViewController <DatePickerViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) CLPlacemark *placemark;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) IBOutlet UISwitch *switchControl;
@property (nonatomic, strong) IBOutlet UILabel *dueDateLabel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, weak) id <ScheduleViewControllerDelegate> delegate;
@property (nonatomic, strong) Location *locationToEdit;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;



- (IBAction)cancel;
- (IBAction)done;

@end
