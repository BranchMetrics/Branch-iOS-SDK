//
//  BranchUniversalObject.h
//  Branch-TestBed
//
//  Created by Derrick Staten on 10/16/15.
//  Copyright © 2015 Branch Metrics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BranchLinkProperties.h"
#import "Branch.h"

@interface BranchUniversalObject : NSObject

typedef NS_ENUM(NSInteger, ContentIndexMode) {
    ContentIndexModePublic,
    ContentIndexModePrivate
};

@property (nonatomic, strong) NSString *canonicalIdentifier;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *contentDescription;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSDictionary *metatdata;
@property (nonatomic, strong) NSString *type;
@property (nonatomic) ContentIndexMode contentIndexMode;
@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic) NSUInteger expirationInMilliSec;

- (instancetype)initWithCanonicalIdentifier:(NSString *)canonicalIdentifier;
- (instancetype)initWithTitle:(NSString *)title;
- (void)registerView;
- (void)registerViewWithCallback:(callbackWithParams)callback;
- (NSString *)getShortUrlWithLinkProperties:(BranchLinkProperties *)linkProperties;
- (void)getShortUrlWithLinkProperties:(BranchLinkProperties *)linkProperties andCallback:(callbackWithUrl)callback;
- (UIActivityItemProvider *)getBranchActivityItemWithLinkProperties:(BranchLinkProperties *)linkProperties;

// TODO V2: Core Spotlight Indexing

@end
