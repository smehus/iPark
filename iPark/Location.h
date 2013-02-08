//
//  Location.h
//  iPark
//
//  Created by scott mehus on 10/25/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Location : NSManagedObject <MKAnnotation>

@property (nonatomic, retain) CLPlacemark *placemark;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, assign) BOOL remindMe;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;


- (void)scheduleNotification;

@end
