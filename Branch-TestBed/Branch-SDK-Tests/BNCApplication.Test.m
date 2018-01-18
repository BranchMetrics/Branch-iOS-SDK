//
//  BNCApplication.Test.m
//  Branch-SDK-Tests
//
//  Created by Edward on 1/10/18.
//  Copyright © 2018 Branch, Inc. All rights reserved.
//

#import "BNCTestCase.h"
#import "BNCApplication.h"
#import "BNCKeyChain.h"

@interface BNCApplicationTest : BNCTestCase
@end

@implementation BNCApplicationTest

- (void)testApplication {
    // Test general info:

    if ([UIApplication sharedApplication] == nil) {
        NSLog(@"No host application for BNCApplication testing!");
        return;
    }

    BNCApplication *application = [BNCApplication currentApplication];
    XCTAssertEqualObjects(application.bundleID,                     @"io.branch.sdk.Branch-TestBed");
    XCTAssertEqualObjects(application.teamID,                       @"R63EM248DP");
    XCTAssertEqualObjects(application.applicationID,                @"R63EM248DP.io.branch.sdk.Branch-TestBed");
    XCTAssertEqualObjects(application.displayName,                  @"Branch-TestBed");
    XCTAssertEqualObjects(application.shortDisplayName,             @"Branch-TestBed");
    XCTAssertEqualObjects(application.displayVersionString,         @"1.1");
    XCTAssertEqualObjects(application.versionString,                @"1");
    XCTAssertEqualObjects(application.pushNotificationEnvironment,  @"development");
    XCTAssertEqual(application.keychainAccessGroups,                nil);
    NSArray *domains = @[
        @"applinks:bnc.lt",
        @"applinks:bnctestbed.app.link",
        @"applinks:bnctestbed.test-app.link"
    ];
    XCTAssertEqualObjects(application.associatedDomains, domains);
}

- (void) testAppDates {
    // App dates. Not a great test but tests basic function:

    if ([UIApplication sharedApplication] == nil) {
        NSLog(@"No host application for BNCApplication testing!");
        return;
    }

    NSTimeInterval const kAYearAgo = -365.0 * 24.0 * 60.0 * 60.0;

    BNCApplication *application = [BNCApplication currentApplication];
    XCTAssertTrue(application.firstInstallDate && [application.firstInstallDate timeIntervalSinceNow] > kAYearAgo);
    XCTAssertTrue(application.firstInstallBuildDate && [application.firstInstallBuildDate timeIntervalSinceNow] > kAYearAgo);
    XCTAssertTrue(application.currentInstallDate && [application.currentInstallDate timeIntervalSinceNow] > kAYearAgo);
    XCTAssertTrue(application.currentBuildDate && [application.currentBuildDate timeIntervalSinceNow] > kAYearAgo);

    NSString*const kBranchKeychainService          = @"BranchKeychainService";
//  NSString*const kBranchKeychainDevicesKey       = @"BranchKeychainDevices";
    NSString*const kBranchKeychainFirstBuildKey    = @"BranchKeychainFirstBuild";
    NSString*const kBranchKeychainFirstInstalldKey = @"BranchKeychainFirstInstall";

    NSDate * firstBuildDate =
        [BNCKeyChain retrieveValueForService:kBranchKeychainService
            key:kBranchKeychainFirstBuildKey
            error:nil];
    XCTAssertEqualObjects(application.firstInstallBuildDate, firstBuildDate);

    NSDate * firstInstallDate =
        [BNCKeyChain retrieveValueForService:kBranchKeychainService
            key:kBranchKeychainFirstInstalldKey
            error:nil];
    XCTAssertEqualObjects(application.firstInstallDate, firstInstallDate);
}

- (void) testIdentities {
    if ([UIApplication sharedApplication] == nil) {
        NSLog(@"No host application for BNCApplication testing!");
        return;
    }

    BNCApplication *application = [BNCApplication currentApplication];
    NSMutableDictionary * d =
        [NSMutableDictionary dictionaryWithDictionary:application.deviceKeyIdentityValueDictionary];
    XCTAssertTrue(d != nil);
    [application addDeviceID:@"a" identityID:@"1"];

    d[@"a"] = @"1";
    XCTAssertEqualObjects(d, application.deviceKeyIdentityValueDictionary);
}

@end
