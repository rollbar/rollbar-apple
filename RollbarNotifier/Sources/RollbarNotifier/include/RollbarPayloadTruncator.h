#ifndef RollbarPayloadTruncator_h
#define RollbarPayloadTruncator_h

@import Foundation;

/// Payload truncation utility
@interface RollbarPayloadTruncator : NSObject

/// Truncates a provided payload
/// @param payload the payload to truncate
+(void)truncatePayload:(NSMutableDictionary *)payload;

/// Truncates multiple payloads to provided byte size
/// @param payloads payloads to truncate
/// @param maxByteSize max payload byte sixe to achieve
+(void)truncatePayloads:(NSArray *)payloads
          toMaxByteSize:(unsigned long)maxByteSize;

/// Truncates a payload to a total bytes limit
/// @param payload a payload to truncate
/// @param limit total bytes limit to truncate to
+(void)truncatePayload:(NSMutableDictionary *)payload
          toTotalBytes:(unsigned long) limit;

/// Measures byte size of a string using specified encoding
/// @param string a string to measure
/// @param encoding string encoding to use
+(unsigned long)measureTotalEncodingBytes:(NSString *)string
                            usingEncoding:(NSStringEncoding)encoding;

/// Measures byte size of a string using default encoding
/// @param string a string to measure
+(unsigned long)measureTotalEncodingBytes:(NSString *)string;

/// Truncates a string to a total bytes limit
/// @param inputString a string to truncate
/// @param totalBytesLimit a limit to truncate to
+(NSString*)truncateString:(NSString *)inputString
              toTotalBytes:(unsigned long)totalBytesLimit;

@end

#endif //RollbarPayloadTruncator_h
