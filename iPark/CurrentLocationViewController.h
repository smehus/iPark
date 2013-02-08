//
//  FirstViewController.h
//  iPark
//
//  Created by scott mehus on 10/24/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleViewController.h"


@interface CurrentLocationViewController : UIViewController <CLLocationManagerDelegate, ScheduleViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel *messageLabel;
@property (nonatomic, strong) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) IBOutlet UIButton *parkButton;
@property (nonatomic, strong) IBOutlet UIButton *scheduleButton;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (IBAction)getLocation:(id)sender;

- (void)updateLabels;

@end
