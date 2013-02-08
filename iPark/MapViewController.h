//
//  MapViewController.h
//  iPark
//
//  Created by scott mehus on 11/3/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

- (IBAction)showUser;
- (IBAction)showLocation;



@end
