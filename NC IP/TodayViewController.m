//
//  TodayViewController.m
//  NC IP
//
//  Created by Justin Loew on 4/8/15.
//  Copyright (c) 2015 Lustin' Joew. All rights reserved.
//

#import "TodayViewController.h"
@import NotificationCenter;
#import <ifaddrs.h>
#import <arpa/inet.h>


@interface TodayViewController () <NCWidgetProviding>

@property (weak, nonatomic) IBOutlet UILabel *ipLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

- (void)refreshIPAddress;
- (nullable NSString *)getIPAddress;

@end


@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	NSLog(@"Started.");
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
	NSLog(@"Performing widget update.");
	
	[self refreshIPAddress];
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData
	
	// The date displayed is always updated, so we always return new data.
	completionHandler(NCUpdateResultNewData);
}

- (void)refreshIPAddress {
	NSString *ipStr = [self getIPAddress];
	NSLog(@"Done loading IP address.");
	
	// Update the UI.
	self.ipLabel.text = ipStr ?: @"Error";
	// Create a pretty date string.
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	fmt.dateStyle = NSDateFormatterMediumStyle;
	fmt.timeStyle = NSDateFormatterMediumStyle;
	fmt.doesRelativeDateFormatting = YES;
	NSString *dateStr = [fmt stringFromDate:[NSDate date]];
	self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last updated: %@", dateStr];
}

- (nullable NSString *)getIPAddress {
	// From: https://stackoverflow.com/questions/28084853/how-to-get-the-local-host-ip-address-on-iphone-in-swift
	NSString *address = nil;
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	// retrieve the current interfaces - returns 0 on success
	success = getifaddrs(&interfaces);
	if (success != 0) {
		NSLog(@"Error getting interface addresses.");
		goto cleanup;
	}
	// loop through linked list of interfaces
	temp_addr = interfaces;
	while (temp_addr != NULL) {
		if (temp_addr->ifa_addr->sa_family == AF_INET) {
			// check if interface is en0 which is the Wi-Fi connection on the iPhone
			if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
				// get NSString from C string
				address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
			}
		}
		
		temp_addr = temp_addr->ifa_next;
	}
	
cleanup:
	// free memory
	freeifaddrs(interfaces);
	return address;
}

@end
