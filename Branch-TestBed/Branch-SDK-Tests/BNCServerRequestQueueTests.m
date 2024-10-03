//
//  BNCServerRequestQueueTests.m
//  Branch-SDK-Tests
//
//  Created by Ernest Cho on 5/14/21.
//  Copyright © 2021 Branch, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BNCServerRequestQueue.h"
#import "BNCServerRequest.h"

// Analytics requests
#import "BranchInstallRequest.h"
#import "BranchOpenRequest.h"
#import "BranchEvent.h"

@interface BNCServerRequestQueue ()
- (NSData *)archiveQueue:(NSArray<BNCServerRequest *> *)queue;
- (NSMutableArray<BNCServerRequest *> *)unarchiveQueueFromData:(NSData *)data;

- (NSData *)archiveObject:(NSObject *)object;
- (id)unarchiveObjectFromData:(NSData *)data;

// returns data in the legacy format
- (NSData *)oldArchiveQueue:(NSArray<BNCServerRequest *> *)queue;

+ (NSURL * _Nonnull) URLForQueueFile;
- (void)retrieve;

@end

@interface BNCServerRequestQueueTests : XCTestCase
@property (nonatomic, strong, readwrite) BNCServerRequestQueue *queue;
@end

@implementation BNCServerRequestQueueTests

- (void)setUp {
    self.queue = [BNCServerRequestQueue new];
}

- (void)tearDown {
    self.queue = nil;
}

- (void)testArchiveNil {
    NSString *object = nil;
    
    NSData *archived = [self.queue archiveObject:object];
    XCTAssertNotNil(archived);
    
    NSString *unarchived = [self.queue unarchiveObjectFromData:archived];
    XCTAssertNil(unarchived);
}

- (void)testArchiveString {
    NSString *object = @"Hello World";
    
    NSData *archived = [self.queue archiveObject:object];
    XCTAssertNotNil(archived);
    
    NSString *unarchived = [self.queue unarchiveObjectFromData:archived];
    XCTAssertNotNil(unarchived);
    XCTAssert([object isEqual:unarchived]);
}

- (void)testArchiveInstallRequest {
    BranchInstallRequest *object = [BranchInstallRequest new];
    
    NSData *archived = [self.queue archiveObject:object];
    XCTAssertNotNil(archived);
    
    BranchInstallRequest *unarchived = [self.queue unarchiveObjectFromData:archived];
    XCTAssertNotNil(unarchived);
    XCTAssert([unarchived isKindOfClass:[BranchInstallRequest class]]);

    // The request object is not very test friendly, so comparing the two is not helpful at the moment
}

- (void)testArchiveOpenRequest {
    BranchOpenRequest *object = [BranchOpenRequest new];
    
    NSData *archived = [self.queue archiveObject:object];
    XCTAssertNotNil(archived);
    
    BranchOpenRequest *unarchived = [self.queue unarchiveObjectFromData:archived];
    XCTAssertNotNil(unarchived);
    XCTAssert([unarchived isKindOfClass:[BranchOpenRequest class]]);

    // The request object is not very test friendly, so comparing the two is not helpful at the moment
}

- (void)testArchiveEventRequest {
    BranchEventRequest *object = [BranchEventRequest new];
    
    NSData *archived = [self.queue archiveObject:object];
    XCTAssertNotNil(archived);
    
    BranchEventRequest *unarchived = [self.queue unarchiveObjectFromData:archived];
    XCTAssertNotNil(unarchived);
    XCTAssert([unarchived isKindOfClass:[BranchEventRequest class]]);

    // The request object is not very test friendly, so comparing the two is not helpful at the moment
}

- (void)testArchiveArrayOfRequests {
    NSMutableArray<BNCServerRequest *> *tmp = [NSMutableArray<BNCServerRequest *> new];
    [tmp addObject:[BranchOpenRequest new]];
    [tmp addObject:[BranchEventRequest new]];
    
    NSData *data = [self.queue archiveQueue:tmp];
    XCTAssertNotNil(data);

    NSMutableArray *unarchived = [self.queue unarchiveQueueFromData:data];
    XCTAssertNotNil(unarchived);
    XCTAssert(unarchived.count == 2);
}

- (void)testOldArchiveArrayOfRequests {
    NSMutableArray<BNCServerRequest *> *tmp = [NSMutableArray<BNCServerRequest *> new];
    [tmp addObject:[BranchOpenRequest new]];
    [tmp addObject:[BranchEventRequest new]];
    
    NSData *data = [self.queue oldArchiveQueue:tmp];
    XCTAssertNotNil(data);

    NSMutableArray *unarchived = [self.queue unarchiveQueueFromData:data];
    XCTAssertNotNil(unarchived);
    XCTAssert(unarchived.count == 2);
}

- (void)testArchiveArrayOfInvalidObjects {
    NSMutableArray<BNCServerRequest *> *tmp = [NSMutableArray<BNCServerRequest *> new];
    [tmp addObject:[BranchOpenRequest new]];
    [tmp addObject:@"Hello World"];
    [tmp addObject:[BranchEventRequest new]];
    
    NSData *data = [self.queue archiveQueue:tmp];
    XCTAssertNotNil(data);

    NSMutableArray *unarchived = [self.queue unarchiveQueueFromData:data];
    
    XCTAssertNotNil(unarchived);
    XCTAssert(unarchived.count == 2);
}

- (void)testOldArchiveArrayOfInvalidObjects {
    NSMutableArray<BNCServerRequest *> *tmp = [NSMutableArray<BNCServerRequest *> new];
    [tmp addObject:[BranchOpenRequest new]];
    [tmp addObject:@"Hello World"];
    [tmp addObject:[BranchEventRequest new]];
    
    NSData *data = [self.queue oldArchiveQueue:tmp];
    XCTAssertNotNil(data);

    NSMutableArray *unarchived = [self.queue unarchiveQueueFromData:data];
    
    XCTAssertNotNil(unarchived);
    XCTAssert(unarchived.count == 2);
}

- (void)testMultipleRequests {
    BranchEventRequest *eventObject = [BranchEventRequest new];
    BranchOpenRequest *openObject = [BranchOpenRequest new];
 
    [_queue enqueue: eventObject];
    [_queue enqueue: openObject];
    [_queue persistImmediately];
    
    NSMutableArray *decodedQueue = nil;
    NSData *data = [NSData dataWithContentsOfURL:[BNCServerRequestQueue URLForQueueFile] options:0 error:nil];
    if (data) {
        decodedQueue = [_queue unarchiveQueueFromData:data];
    }
    XCTAssert([decodedQueue count] == 2);
    [_queue clearQueue];
    XCTAssert([_queue queueDepth] == 0);
    [_queue retrieve];
    XCTAssert([_queue queueDepth] == 2);

     // Request are loaded. So there should not be any queue file on disk.
    XCTAssert([NSFileManager.defaultManager fileExistsAtPath:[[BNCServerRequestQueue URLForQueueFile] path]] == NO);
}

- (void)testUUIDANDTimeStampPersistence {
    BranchEventRequest *eventObject = [BranchEventRequest new];
    BranchOpenRequest *openObject = [BranchOpenRequest new];
    NSString *uuidFromEventObject = eventObject.requestUUID;
    NSNumber *timeStampFromEventObject = eventObject.requestCreationTimeStamp;
    NSString *uuidFromOpenObject = openObject.requestUUID;
    NSNumber *timeStampFromOpenObject = openObject.requestCreationTimeStamp;
    
    XCTAssertTrue(![uuidFromEventObject isEqualToString:uuidFromOpenObject]);
    
    [_queue enqueue: eventObject];
    [_queue enqueue: openObject];
    [_queue persistImmediately];
    
    NSMutableArray *decodedQueue = nil;
    NSData *data = [NSData dataWithContentsOfURL:[BNCServerRequestQueue URLForQueueFile] options:0 error:nil];
    if (data) {
        decodedQueue = [_queue unarchiveQueueFromData:data];
    }
    
    for (id requestObject in decodedQueue) {
        if ([requestObject isKindOfClass:BranchEventRequest.class]) {
            XCTAssertTrue([uuidFromEventObject isEqualToString:[(BranchEventRequest *)requestObject requestUUID]]);
            XCTAssertTrue([timeStampFromEventObject isEqualToNumber:[(BranchEventRequest *)requestObject requestCreationTimeStamp]]);
        }
        if ([requestObject isKindOfClass:BranchOpenRequest.class]) {
            
            XCTAssertTrue([uuidFromOpenObject isEqualToString:[(BranchOpenRequest *)requestObject requestUUID]]);
            XCTAssertTrue([timeStampFromOpenObject isEqualToNumber:[(BranchOpenRequest *)requestObject requestCreationTimeStamp]]);
        }
    }
}

@end
