//
//  MapViewController.m
//  iPark
//
//  Created by scott mehus on 11/3/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import "MapViewController.h"
#import "Location.h"
#import "ScheduleViewController.h"
#import "CurrentLocationViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController {
    
    NSArray *locations;
}

@synthesize managedObjectContext;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {

    if ((self = [super initWithCoder:aDecoder])) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contextDidChange:)
                                                     name:NSManagedObjectContextObjectsDidChangeNotification
                                                   object:self.managedObjectContext];
    }
    return self;
}

- (void)updateLocations {
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (foundObjects == nil) {
        FATAL_CORE_DATA_ERROR(error);
        return;
    }
    
    
    if (locations != nil) {
        [self.mapView removeAnnotations:locations];
    }
    
    locations = foundObjects;
    [self.mapView addAnnotations:locations];
    
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateLocations];
    
    if ([locations count] > 0) {
        [self showLocation];
    }

	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
    
    MKCoordinateRegion region;
    
    if ([annotations count] == 1) {
        id <MKAnnotation> annotation = [annotations lastObject];
        region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500);
    } else {
        
        region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
        
        
    }
    
    return [self.mapView regionThatFits:region];
}


- (IBAction)showUser {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (IBAction)showLocation {
    
    MKCoordinateRegion region = [self regionForAnnotations:locations];
    [self.mapView setRegion:region animated:YES];
    
    
    
}

- (void)showLocationDetails:(UIButton *)button {
    
    [self performSegueWithIdentifier:@"EditLocation" sender:button];
    
    
}


#pragma mark - MKMapViewDelegate


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[Location class]]) {
        
        static NSString *identifier = @"Location";

        MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.animatesDrop = NO;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showLocationDetails:) forControlEvents:UIControlEventTouchUpInside];
            annotationView.rightCalloutAccessoryView = rightButton;
        } else {
            annotationView.annotation = annotation;
        }
        
        UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
        button.tag = [locations indexOfObject:(Location *)annotation];
        
        return annotationView;
        
        
    }
    return nil;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        
        UINavigationController *navigationController = segue.destinationViewController;
        ScheduleViewController *controller = (ScheduleViewController *)navigationController.topViewController;
        controller.managedObjectContext= self.managedObjectContext;
        
        Location *location = [locations objectAtIndex:((UIButton *)sender).tag];
        controller.locationToEdit = location;
        
    }
}


- (void)contextDidChange:(NSNotification *)notification {
    
    if ([self isViewLoaded]) {
        [self updateLocations];
        
        
    }
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextObjectsDidChangeNotification
                                                  object:self.managedObjectContext];
}





@end
