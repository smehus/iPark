//
//  Location.m
//  iPark
//
//  Created by scott mehus on 10/25/12.
//  Copyright (c) 2012 scott mehus. All rights reserved.
//

#import "Location.h"


@implementation Location

@dynamic placemark;
@dynamic date;
@dynamic remindMe;
@dynamic latitude;
@dynamic longitude;


- (CLLocationCoordinate2D)coordinate {
    
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    
}


- (NSString *)title {
    
    return @"My Car";
}

- (NSString *)subtitle {
    
    return [self formatDate:self.date];
}

- (NSString *)formatDate:(NSDate *)theDate {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [formatter stringFromDate:theDate];
}

- (UILocalNotification *)notificationForThisItem {
    
    NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in allNotifications) {
        if (notification != nil) {
            return notification;
        }
    }
    
    return nil;
}




- (void)scheduleNotification {
    
    
    UILocalNotification *existingNotification = [self notificationForThisItem];
    if (existingNotification != nil) {
        NSLog(@"Found an exisitng Notificiation: %@", existingNotification);
        [[UIApplication sharedApplication] cancelLocalNotification:existingNotification];
    }
    
    if (self.remindMe && [self.date compare:[NSDate date]] != NSOrderedAscending) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = self.date;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertBody = [NSString stringWithFormat:@"Reminder!! Move your car on:\n%@", [self formatDate:self.date]];
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        NSLog(@"Scheduled Local Notification %@", localNotification);
        
        
    }
}

@end
