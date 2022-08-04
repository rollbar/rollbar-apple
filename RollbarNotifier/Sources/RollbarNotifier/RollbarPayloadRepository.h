//
//  RollbarPayloadRepository.h
//  
//
//  Created by Andrey Kornich on 2022-07-27.
//

#import <Foundation/Foundation.h>

#import "RollbarPayload.h"

NS_ASSUME_NONNULL_BEGIN

@interface RollbarPayloadRepository : NSObject

#pragma mark - instance initializers

- (instancetype)initWithStore:(nonnull NSString *)storePath
NS_DESIGNATED_INITIALIZER;

#pragma mark - Destinations related methods

- (nullable NSDictionary<NSString *, NSString *> *)addDestinationWithEndpoint:(nonnull NSString *)endpoint
                                                                andAccesToken:(nonnull NSString *)accessToken;

- (nullable NSDictionary<NSString *, NSString *> *)getDestinationWithEndpoint:(nonnull NSString *)endpoint
                                                                andAccesToken:(nonnull NSString *)accessToken;

- (nullable NSDictionary<NSString *, NSString *> *)getDestinationByID:(nonnull NSString *)destinationID;

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getAllDestinations;

- (BOOL)removeDestinationWithEndpoint:(nonnull NSString *)endpoint
                        andAccesToken:(nonnull NSString *)accessToken;

- (BOOL)removeDestinationByID:(nonnull NSString *)destinationID;

- (BOOL)removeUnusedDestinations;

- (BOOL)removeAllDestinations;

#pragma mark - Payloads related methods

- (nullable NSDictionary<NSString *, NSString *> *)addPayload:(nonnull NSString *)payload
                                                   withConfig:(nonnull NSString *)config
                                             andDestinationID:(nonnull NSString *)destinationID;

- (nullable NSDictionary<NSString *, NSString *> *)getPayloadByID:(nonnull NSString *)payloadID;

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getAllPayloadsWithDestinationID:(nonnull NSString *)destinationID;

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getPayloadsWithLimit:(NSUInteger)limit;

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getPayloadsWithOffset:(NSUInteger)offset
                                                                          andLimit:(NSUInteger)limit;

- (nonnull NSArray<NSDictionary<NSString *, NSString *> *> *)getAllPayloads;

- (BOOL)removePayloadByID:(nonnull NSString *)payloadID;

- (BOOL)removePayloadsOlderThan:(nonnull NSDate *)cutoffTime;

- (BOOL)removeAllPayloads;

#pragma mark - unit testing helper methods

- (BOOL)checkIfTableExists_Destinations;

- (BOOL)checkIfTableExists_Payloads;

- (BOOL)checkIfTableExists_Unknown;

- (BOOL)clearDestinations;

- (BOOL)clearPayloads;

- (BOOL)clear;

@end

NS_ASSUME_NONNULL_END
