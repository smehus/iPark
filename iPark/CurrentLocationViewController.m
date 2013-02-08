//
//  FirstViewController.m
//  iPark
//
//  Created by scott mehus on 10/24/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import "ScheduleViewController.h"
#import "Location.h"

@interface CurrentLocationViewController ()
- (void)updateLabels;

@end

@implementation CurrentLocationViewController {
    
    CLLocationManager *locationManager;
    CLLocation *location;
    BOOL updatingLocation;
    NSError *lastLocationError;
    
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    BOOL performingReverseGeocoding;
    NSError *lastGeocodingError;
    
    NSDate *dueDate;
    Location *lastLocation;
    
    UIActivityIndicatorView *spinner;
}

@synthesize messageLabel;
@synthesize addressLabel;
@synthesize parkButton;
@synthesize scheduleButton;
@synthesize dateLabel;
@synthesize managedObjectContext;

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        locationManager = [[CLLocationManager alloc] init];
        geocoder = [[CLGeocoder alloc] init];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.managedObjectContext];
    }
    
    return self;
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)thePlacemark {
    
    return [NSString stringWithFormat:@" %@ %@\n%@ %@ %@",
            thePlacemark.subThoroughfare, thePlacemark.thoroughfare,
            thePlacemark.locality, thePlacemark.administrativeArea,
            thePlacemark.postalCode];
}

- (NSString *)formatDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [formatter stringFromDate:date];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
  
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"dvsup.png"]];
    

   
    
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    lastLocation = [foundObjects lastObject];
    


   
    //UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"]
                            //resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
                            //[parkButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
                           // [scheduleButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
     
    //[self.parkButton setBackgroundColor:[UIColor clearColor]];
    //[self.scheduleButton setBackgroundColor:[UIColor clearColor]];
    
    parkButton.layer.cornerRadius = 25;
    scheduleButton.layer.cornerRadius = 25;
    
    
    
    
    //UIColor *clearColor = [UIColor clearColor];
    
    //[parkButton setBackgroundColor:clearColor];
    
    
    
   //UIImage *parkButtonImage = [UIImage imageNamed:@"button.png"];
   // UIImage *highlightedButtonImage = [UIImage imageNamed:@"greyButtonHighlight.png"];
    
    //[parkButton setBackgroundImage:parkButtonImage forState:UIControlStateNormal];
    //[parkButton setBackgroundImage:highlightedButtonImage forState:UIControlStateHighlighted];
    
    
    [self updateLabels];
    [self configureGetButton];
    
    
	
}

- (void)updateLabels {
    
    
    if (location != nil) {
        
        self.messageLabel.text = @"Found Your Spot!";
        self.scheduleButton.hidden = NO;
        
   
        
        
        if (dueDate == nil) {
            self.dateLabel.text = @"";
            
        } else {
            
        self.dateLabel.text = [NSString stringWithFormat:@"Move Date: %@",[self formatDate:dueDate]];
            
        }
        
        if (placemark != nil) {
            self.addressLabel.text = [self stringFromPlacemark:placemark];
            
          
        } else if (performingReverseGeocoding || updatingLocation) {
            self.addressLabel.text = @"Searching For Address";
        } else if (lastGeocodingError != nil) {
            self.addressLabel.text = @"Error Finding Address";
        } else {
            self.addressLabel.text = @"No Address Found";
        }
        
      
     
  
        
    } else {

        self.scheduleButton.hidden = YES;
        self.addressLabel.text = @"";
        self.dateLabel.text = @"";
        
        NSString *statusMessage;
        if (lastLocationError != nil) {
            if ([lastLocationError.domain isEqualToString:kCLErrorDomain] && lastLocationError.code == kCLErrorDenied) {
                statusMessage = @"Location Services Disabled";
            } else {
                statusMessage = @"Error Getting Location";
            }
        } else if (![CLLocationManager locationServicesEnabled]) {
            statusMessage = @"Location Services Disabled";
        } else if (updatingLocation) {
            statusMessage = @"Searching For Spot...";
        } else {
            statusMessage = @"Press Park!";
        }
        self.messageLabel.text = statusMessage;
    }
}


- (void)scheduleButtonAnimation {
    
    if (self.scheduleButton.hidden == NO) {
        
        CABasicAnimation *logoMover = [CABasicAnimation animationWithKeyPath:@"position"];
        logoMover.removedOnCompletion = NO;
        logoMover.fillMode = kCAFillModeForwards;
        logoMover.duration = 0.5f;
        logoMover.fromValue = [NSValue valueWithCGPoint:CGPointMake(-160.0f, self.scheduleButton.center.y)];
        logoMover.toValue = [NSValue valueWithCGPoint:self.scheduleButton.center];
        logoMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [self.scheduleButton.layer addAnimation:logoMover forKey:@"logoMover"];
        
    } else {
        return;
    }
    
    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}


- (void)configureGetButton {
    
    if (updatingLocation) {
        [self.parkButton setTitle:@"" forState:UIControlStateNormal];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        spinner.center = CGPointMake(self.parkButton.bounds.size.width - spinner.bounds.size.width/2.0f - 10,
                                     self.parkButton.bounds.size.height / 2.0f);
        [spinner startAnimating];
        [self.parkButton addSubview:spinner];
        
        
    } else {
        [self.parkButton setTitle:@"" forState:UIControlStateNormal];
        [self scheduleButtonAnimation];
        [spinner removeFromSuperview];
        spinner = nil;
    }
}



- (void)stopLocationManager {
    
   
        [locationManager stopUpdatingLocation];
        locationManager.delegate = nil;
        updatingLocation = NO;
    
    NSLog(@"****Stopping Location Manager");
    
}

- (void)startLocationManager {
    
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        [locationManager startUpdatingLocation];
        updatingLocation = YES;
    }
}


- (IBAction)getLocation:(id)sender {
    
    if (updatingLocation) {
        [self stopLocationManager];
        updatingLocation = NO;
    } else {
        
        location = nil;
        lastLocationError = nil;
        placemark = nil;
        lastGeocodingError = nil;
        self.scheduleButton.hidden = YES;
        [self startLocationManager];
    }
    
    
    //[self updateLabels];
    [self configureGetButton];
    
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"This did fail with error: %@", error);
    
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    
    [self stopLocationManager];
    lastLocationError = nil;
    //[self updateLabels];
    [self configureGetButton];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //NSLog(@"updated to location: %@", locations);
    
    //CLLocation *newLocation = [locations lastObject];
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    
    CLLocationDistance distance = MAXFLOAT;
    if (location != nil) {
        distance = [newLocation distanceFromLocation:location];
    }

    
    if (location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        
        updatingLocation = NO;
        lastLocationError = nil;
        //location = [locations lastObject];
        location = newLocation;
        [self updateLabels];
        [self configureGetButton];
  
        if (newLocation.horizontalAccuracy <= 65) {
            NSLog(@"***We're Done");
           
            
            
            [self stopLocationManager];
            [self configureGetButton];
            [self updateLabels];
            
            if (distance > 0) {
                performingReverseGeocoding = NO;
            }
        }
        
        if (!performingReverseGeocoding) {
            NSLog(@"***Going to Reverse GeoCode");
            performingReverseGeocoding = YES;
            [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
                
                NSLog(@"Found Placemarks: %@, and error: %@", placemarks, error);
                
                lastLocationError = error;
                if (error == nil && [placemarks count] > 0) {
                    placemark = [placemarks lastObject];
                } else {
                    placemark = nil;
                }
                
                performingReverseGeocoding = NO;
                [self updateLabels];
               //[self scheduleButtonAnimation];
                
            }];
        }
        
        
    } else if (distance < 1.0) {
        
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:location.timestamp];
        if (timeInterval > 5) {
            [self stopLocationManager];
            [self updateLabels];
            [self configureGetButton];
            updatingLocation = NO;
        }
    }
    
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Schedule"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        ScheduleViewController *controller = (ScheduleViewController *)navigationController.topViewController;
        controller.placemark = placemark;
        controller.managedObjectContext = self.managedObjectContext;
        controller.coordinate = location.coordinate;
        controller.delegate = self;

        
    }
}


- (void)schedule:(ScheduleViewController *)scheduler didPickDate:(NSDate *)theDate {
    
    dueDate = theDate;
    //[self updateLabels];
    
}

- (void)contextDidChange:(NSNotification *)notification {
    
    if ([self isViewLoaded]) {
        //[self updateLabels];
        
        
    }
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:self.managedObjectContext];
}





@end
