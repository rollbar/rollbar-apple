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

#pragma mark - repository methods

- (void)clear;

- (void)addPayload:(nonnull RollbarPayload *)payload;

#pragma mark - instance initializers

- (instancetype)initWithStore:(nonnull NSString *)storePath
NS_DESIGNATED_INITIALIZER;

#pragma mark - unit testing helper methods

- (BOOL)checkIfTableExists_Destinations;

- (BOOL)checkIfTableExists_Payloads;

- (BOOL)checkIfTableExists_Unknown;

@end

NS_ASSUME_NONNULL_END
