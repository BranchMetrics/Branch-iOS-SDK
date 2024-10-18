//
//  BranchShortUrlRequest.m
//  Branch-TestBed
//
//  Created by Graham Mueller on 5/26/15.
//  Copyright (c) 2015 Branch Metrics. All rights reserved.
//

#import "BranchShortUrlRequest.h"
#import "BNCPreferenceHelper.h"
#import "BNCEncodingUtils.h"
#import "BranchConstants.h"
#import "BNCConfig.h"
#import "BNCRequestFactory.h"
#import "BNCServerAPI.h"

@interface BranchShortUrlRequest ()

@property (strong, nonatomic) NSArray *tags;
@property (copy, nonatomic) NSString *alias;
@property (assign, nonatomic) BranchLinkType type;
@property (assign, nonatomic) NSInteger matchDuration;
@property (copy, nonatomic) NSString *channel;
@property (copy, nonatomic) NSString *feature;
@property (copy, nonatomic) NSString *stage;
@property (copy, nonatomic) NSString *campaign;
@property (strong, nonatomic) NSDictionary *params;
@property (strong, nonatomic) BNCLinkCache *linkCache;
@property (strong, nonatomic) BNCLinkData *linkData;
@property (strong, nonatomic) callbackWithUrl callback;

@end

@implementation BranchShortUrlRequest

- (id)initWithTags:(NSArray *)tags alias:(NSString *)alias type:(BranchLinkType)type matchDuration:(NSInteger)duration channel:(NSString *)channel feature:(NSString *)feature stage:(NSString *)stage campaign:campaign params:(NSDictionary *)params linkData:(BNCLinkData *)linkData linkCache:(BNCLinkCache *)linkCache callback:(callbackWithUrl)callback {
    if ((self = [super init])) {
        _tags = tags;
        _alias = alias;
        _type = type;
        _matchDuration = duration;
        _channel = channel;
        _feature = feature;
        _stage = stage;
        _campaign = campaign;
        _params = params;
        _callback = callback;
        _linkCache = linkCache;
        _linkData = linkData;
        _isSpotlightRequest = NO;
    }
    
    return self;
}

- (void)makeRequest:(BNCServerInterface *)serverInterface
                key:(NSString *)key
           callback:(BNCServerCallback)callback {
    
    BNCRequestFactory *factory = [[BNCRequestFactory alloc] initWithBranchKey:key UUID:self.requestUUID TimeStamp:self.requestCreationTimeStamp];
    NSDictionary *json = [factory dataForShortURLWithLinkDataDictionary:[self.linkData.data mutableCopy] isSpotlightRequest:self.isSpotlightRequest];

    [serverInterface postRequest:json
        url:[[BNCServerAPI sharedInstance] linkServiceURL]
        key:key
        callback:callback];
}

- (void)processResponse:(BNCServerResponse *)response error:(NSError *)error {
    if (error) {
        if (self.callback) {
            BNCPreferenceHelper *preferenceHelper = [BNCPreferenceHelper sharedInstance];
            NSString *baseUrl = preferenceHelper.userUrl;
            if (baseUrl.length)
                baseUrl = [preferenceHelper sanitizedMutableBaseURL:baseUrl];
            else
            if (Branch.branchKeyIsSet) {
                baseUrl = [[NSMutableString alloc] initWithFormat:@"%@/a/%@?",
                    BNC_LINK_URL,
                    Branch.branchKey];
            }
            if (baseUrl)
                baseUrl = [self createLongUrlForUserUrl:baseUrl];
            self.callback(baseUrl, error);
        }
        return;
    }
    
    NSString *url = response.data[BRANCH_RESPONSE_KEY_URL];
    
    // cache the link
    if (url) {
        [self.linkCache setObject:url forKey:self.linkData];
    }
    if (self.callback) {
        self.callback(url, nil);
    }
}

- (NSString *)createLongUrlForUserUrl:(NSString *)userUrl {
    NSMutableString *longUrl = [[BNCPreferenceHelper sharedInstance] sanitizedMutableBaseURL:userUrl];
    for (NSString *tag in self.tags) {
        [longUrl appendFormat:@"tags=%@&", [BNCEncodingUtils stringByPercentEncodingStringForQuery:tag]];
    }
    
    if ([self.alias length]) {
        [longUrl appendFormat:@"alias=%@&", [BNCEncodingUtils stringByPercentEncodingStringForQuery:self.alias]];
    }
    
    if ([self.channel length]) {
        [longUrl appendFormat:@"channel=%@&", [BNCEncodingUtils stringByPercentEncodingStringForQuery:self.channel]];
    }
    
    if ([self.feature length]) {
        [longUrl appendFormat:@"feature=%@&", [BNCEncodingUtils stringByPercentEncodingStringForQuery:self.feature]];
    }
    
    if ([self.stage length]) {
        [longUrl appendFormat:@"stage=%@&", [BNCEncodingUtils stringByPercentEncodingStringForQuery:self.stage]];
    }
    if (self.type) {
        [longUrl appendFormat:@"type=%ld&", (long)self.type];
    }
    if (self.matchDuration) {
        [longUrl appendFormat:@"duration=%ld&", (long)self.matchDuration];
    }

    NSData *jsonData = [BNCEncodingUtils encodeDictionaryToJsonData:self.params];
    NSString *base64EncodedParams = [BNCEncodingUtils base64EncodeData:jsonData];
    [longUrl appendFormat:@"source=ios&data=%@", base64EncodedParams];
    
    return longUrl;
}

@end
