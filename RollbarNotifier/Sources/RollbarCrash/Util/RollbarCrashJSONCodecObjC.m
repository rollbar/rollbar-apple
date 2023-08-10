//
//  RollbarCrashJSONCodecObjC.m
//
//  Created by Karl Stenerud on 2012-01-08.
//
//  Copyright (c) 2012 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import "RollbarCrashJSONCodecObjC.h"

#import "RollbarCrashJSONCodec.h"
#import "NSError+SimpleConstructor.h"
#import "RollbarCrashDate.h"


@interface RollbarCrashJSONCodec ()

#pragma mark Properties

/** Callbacks from the C library */
@property(nonatomic,readwrite,assign) RollbarCrashJSONDecodeCallbacks* callbacks;

/** Stack of arrays/objects as the decoded content is built */
@property(nonatomic,readwrite,retain) NSMutableArray* containerStack;

/** Current array or object being decoded (weak ref) */
@property(nonatomic,readwrite,assign) id currentContainer;

/** Top level array or object in the decoded tree */
@property(nonatomic,readwrite,retain) id topLevelContainer;

/** Data that has been serialized into JSON form */
@property(nonatomic,readwrite,retain) NSMutableData* serializedData;

/** Any error that has occurred */
@property(nonatomic,readwrite,retain) NSError* error;

/** If true, pretty print while encoding */
@property(nonatomic,readwrite,assign) bool prettyPrint;

/** If true, sort object keys while encoding */
@property(nonatomic,readwrite,assign) bool sorted;

/** If true, don't store nulls in arrays */
@property(nonatomic,readwrite,assign) bool ignoreNullsInArrays;

/** If true, don't store nulls in objects */
@property(nonatomic,readwrite,assign) bool ignoreNullsInObjects;


#pragma mark Constructors

/** Convenience constructor.
 *
 * @param encodeOptions Optional behavior when encoding to JSON.
 *
 * @param decodeOptions Optional behavior when decoding from JSON.
 *
 * @return A new codec.
 */
+ (RollbarCrashJSONCodec*) codecWithEncodeOptions:(RollbarCrashJSONEncodeOption) encodeOptions
                          decodeOptions:(RollbarCrashJSONDecodeOption) decodeOptions;

/** Initializer.
 *
 * @param encodeOptions Optional behavior when encoding to JSON.
 *
 * @param decodeOptions Optional behavior when decoding from JSON.
 *
 * @return The initialized codec.
 */
- (id) initWithEncodeOptions:(RollbarCrashJSONEncodeOption) encodeOptions
               decodeOptions:(RollbarCrashJSONDecodeOption) decodeOptions;

@end


#pragma mark -
#pragma mark -


@implementation RollbarCrashJSONCodec

#pragma mark Properties

@synthesize topLevelContainer = _topLevelContainer;
@synthesize currentContainer = _currentContainer;
@synthesize containerStack = _containerStack;
@synthesize callbacks = _callbacks;
@synthesize serializedData = _serializedData;
@synthesize error = _error;
@synthesize prettyPrint = _prettyPrint;
@synthesize sorted = _sorted;
@synthesize ignoreNullsInArrays = _ignoreNullsInArrays;
@synthesize ignoreNullsInObjects = _ignoreNullsInObjects;

#pragma mark Constructors/Destructor

+ (RollbarCrashJSONCodec*) codecWithEncodeOptions:(RollbarCrashJSONEncodeOption) encodeOptions
                          decodeOptions:(RollbarCrashJSONDecodeOption) decodeOptions
{
    return [[self alloc] initWithEncodeOptions:encodeOptions decodeOptions:decodeOptions];
}

- (id) initWithEncodeOptions:(RollbarCrashJSONEncodeOption) encodeOptions
               decodeOptions:(RollbarCrashJSONDecodeOption) decodeOptions
{
    if((self = [super init]))
    {
        self.containerStack = [NSMutableArray array];
        self.callbacks = malloc(sizeof(*self.callbacks));
        self.callbacks->onBeginArray = onBeginArray;
        self.callbacks->onBeginObject = onBeginObject;
        self.callbacks->onBooleanElement = onBooleanElement;
        self.callbacks->onEndContainer = onEndContainer;
        self.callbacks->onEndData = onEndData;
        self.callbacks->onFloatingPointElement = onFloatingPointElement;
        self.callbacks->onIntegerElement = onIntegerElement;
        self.callbacks->onNullElement = onNullElement;
        self.callbacks->onStringElement = onStringElement;
        self.prettyPrint = (encodeOptions & RollbarCrashJSONEncodeOptionPretty) != 0;
        self.sorted = (encodeOptions & RollbarCrashJSONEncodeOptionSorted) != 0;
        self.ignoreNullsInArrays = (decodeOptions & RollbarCrashJSONDecodeOptionIgnoreNullInArray) != 0;
        self.ignoreNullsInObjects = (decodeOptions & RollbarCrashJSONDecodeOptionIgnoreNullInObject) != 0;
    }
    return self;
}

- (void) dealloc
{
    free(self.callbacks);
}

#pragma mark Utility

static inline NSString* stringFromCString(const char* const string)
{
    if(string == NULL)
    {
        return nil;
    }
    return [NSString stringWithCString:string encoding:NSUTF8StringEncoding];
}

#pragma mark Callbacks

static int onElement(RollbarCrashJSONCodec* codec, NSString* name, id element)
{
    if(codec->_currentContainer == nil)
    {
        codec.error = [NSError errorWithDomain:@"RollbarCrashJSONCodecObjC"
                                          code:0
                                   description:@"Type %@ not allowed as top level container",
                       [element class]];
        return RollbarCrashJSON_ERROR_INVALID_DATA;
    }

    if([codec->_currentContainer isKindOfClass:[NSMutableDictionary class]])
    {
        [(NSMutableDictionary*)codec->_currentContainer setValue:element
                                                          forKey:name];
    }
    else
    {
        [(NSMutableArray*)codec->_currentContainer addObject:element];
    }
    return RollbarCrashJSON_OK;
}

static int onBeginContainer(RollbarCrashJSONCodec* codec, NSString* name, id container)
{
    if(codec->_topLevelContainer == nil)
    {
        codec->_topLevelContainer = container;
    }
    else
    {
        int result = onElement(codec, name, container);
        if(result != RollbarCrashJSON_OK)
        {
            return result;
        }
    }
    codec->_currentContainer = container;
    [codec->_containerStack addObject:container];
    return RollbarCrashJSON_OK;
}

static int onBooleanElement(const char* const cName, const bool value, void* const userData)
{
    NSString* name = stringFromCString(cName);
    id element = [NSNumber numberWithBool:value];
    RollbarCrashJSONCodec* codec = (__bridge RollbarCrashJSONCodec*)userData;
    return onElement(codec, name, element);
}

static int onFloatingPointElement(const char* const cName, const double value, void* const userData)
{
    NSString* name = stringFromCString(cName);
    id element = [NSNumber numberWithDouble:value];
    RollbarCrashJSONCodec* codec = (__bridge RollbarCrashJSONCodec*)userData;
    return onElement(codec, name, element);
}

static int onIntegerElement(const char* const cName,
                                       const int64_t value,
                                       void* const userData)
{
    NSString* name = stringFromCString(cName);
    id element = [NSNumber numberWithLongLong:value];
    RollbarCrashJSONCodec* codec = (__bridge RollbarCrashJSONCodec*)userData;
    return onElement(codec, name, element);
}

static int onNullElement(const char* const cName, void* const userData)
{
    NSString* name = stringFromCString(cName);
    RollbarCrashJSONCodec* codec = (__bridge RollbarCrashJSONCodec*)userData;

    if((codec->_ignoreNullsInArrays &&
        [codec->_currentContainer isKindOfClass:[NSArray class]]) ||
       (codec->_ignoreNullsInObjects &&
        [codec->_currentContainer isKindOfClass:[NSDictionary class]]))
    {
        return RollbarCrashJSON_OK;
    }

    return onElement(codec, name, [NSNull null]);
}

static int onStringElement(const char* const cName, const char* const value, void* const userData)
{
    NSString* name = stringFromCString(cName);
    id element = [NSString stringWithCString:value
                                    encoding:NSUTF8StringEncoding];
    RollbarCrashJSONCodec* codec = (__bridge RollbarCrashJSONCodec*)userData;
    return onElement(codec, name, element);
}

static int onBeginObject(const char* const cName, void* const userData)
{
    NSString* name = stringFromCString(cName);
    id container = [NSMutableDictionary dictionary];
    RollbarCrashJSONCodec* codec = (__bridge RollbarCrashJSONCodec*)userData;
    return onBeginContainer(codec, name, container);
}

static int onBeginArray(const char* const cName, void* const userData)
{
    NSString* name = stringFromCString(cName);
    id container = [NSMutableArray array];
    RollbarCrashJSONCodec* codec = (__bridge RollbarCrashJSONCodec*)userData;
    return onBeginContainer(codec, name, container);
}

static int onEndContainer(void* const userData)
{
    RollbarCrashJSONCodec* codec = (__bridge RollbarCrashJSONCodec*)userData;

    if([codec->_containerStack count] == 0)
    {
        codec.error = [NSError errorWithDomain:@"RollbarCrashJSONCodecObjC"
                                          code:0
                                   description:@"Already at the top level; no container left to end"];
        return RollbarCrashJSON_ERROR_INVALID_DATA;
    }
    [codec->_containerStack removeLastObject];
    NSUInteger count = [codec->_containerStack count];
    if(count > 0)
    {
        codec->_currentContainer = [codec->_containerStack objectAtIndex:count - 1];
    }
    else
    {
        codec->_currentContainer = nil;
    }
    return RollbarCrashJSON_OK;
}

static int onEndData(__unused void* const userData)
{
    return RollbarCrashJSON_OK;
}

static int addJSONData(const char* const bytes, const int length, void* const userData)
{
    NSMutableData* data = (__bridge NSMutableData*)userData;
    [data appendBytes:bytes length:(unsigned)length];
    return RollbarCrashJSON_OK;
}

static int encodeObject(RollbarCrashJSONCodec* codec, id object, NSString* name, RollbarCrashJSONEncodeContext* context)
{
    int result;
    const char* cName = [name UTF8String];
    if([object isKindOfClass:[NSString class]])
    {
        NSData* data = [object dataUsingEncoding:NSUTF8StringEncoding];
        result = rcjson_addStringElement(context, cName, data.bytes, (int)data.length);
        if(result == RollbarCrashJSON_ERROR_INVALID_CHARACTER)
        {
            codec.error = [NSError errorWithDomain:@"RollbarCrashJSONCodecObjC"
                                              code:0
                                       description:@"Invalid character in %@", object];
        }
        return result;
    }

    if([object isKindOfClass:[NSNumber class]])
    {
        switch (CFNumberGetType((__bridge CFNumberRef)object))
        {
            case kCFNumberFloat32Type:
            case kCFNumberFloat64Type:
            case kCFNumberFloatType:
            case kCFNumberCGFloatType:
            case kCFNumberDoubleType:
                return rcjson_addFloatingPointElement(context, cName, [object doubleValue]);
            case kCFNumberCharType:
                return rcjson_addBooleanElement(context, cName, [object boolValue]);
            default:
                return rcjson_addIntegerElement(context, cName, [object longLongValue]);
        }
    }

    if([object isKindOfClass:[NSArray class]])
    {
        if((result = rcjson_beginArray(context, cName)) != RollbarCrashJSON_OK)
        {
            return result;
        }
        for(id subObject in object)
        {
            if((result = encodeObject(codec, subObject, NULL, context)) != RollbarCrashJSON_OK)
            {
                return result;
            }
        }
        return rcjson_endContainer(context);
    }

    if([object isKindOfClass:[NSDictionary class]])
    {
        if((result = rcjson_beginObject(context, cName)) != RollbarCrashJSON_OK)
        {
            return result;
        }
        NSArray* keys = [(NSDictionary*)object allKeys];
        if(codec->_sorted)
        {
            keys = [keys sortedArrayUsingSelector:@selector(compare:)];
        }
        for(id key in keys)
        {
            if((result = encodeObject(codec, [object valueForKey:key], key, context)) != RollbarCrashJSON_OK)
            {
                return result;
            }
        }
        return rcjson_endContainer(context);
    }

    if([object isKindOfClass:[NSNull class]])
    {
        return rcjson_addNullElement(context, cName);
    }

    if([object isKindOfClass:[NSDate class]])
    {
        char string[21];
        time_t timestamp = (time_t)((NSDate*)object).timeIntervalSince1970;
        rcdate_utcStringFromTimestamp(timestamp, string);
        NSData* data = [NSData dataWithBytes:string length:strnlen(string, 20)];
        return rcjson_addStringElement(context, cName, data.bytes, (int)data.length);
    }

    if([object isKindOfClass:[NSData class]])
    {
        NSData* data = (NSData*)object;
        return rcjson_addDataElement(context, cName, data.bytes, (int)data.length);
    }

    codec.error = [NSError errorWithDomain:@"RollbarCrashJSONCodecObjC"
                                      code:0
                               description:@"Could not determine type of %@", [object class]];
    return RollbarCrashJSON_ERROR_INVALID_DATA;
}


#pragma mark Public API

+ (NSData*) encode:(id) object
           options:(RollbarCrashJSONEncodeOption) encodeOptions
             error:(NSError* __autoreleasing *) error
{
    NSMutableData* data = [NSMutableData data];
    RollbarCrashJSONEncodeContext JSONContext;
    rcjson_beginEncode(&JSONContext,
                       encodeOptions & RollbarCrashJSONEncodeOptionPretty,
                       addJSONData,
                       (__bridge void*)data);
    RollbarCrashJSONCodec* codec = [self codecWithEncodeOptions:encodeOptions
                                        decodeOptions:RollbarCrashJSONDecodeOptionNone];

    int result = encodeObject(codec, object, NULL, &JSONContext);
    if(error != nil)
    {
        *error = codec.error;
    }
    return result == RollbarCrashJSON_OK ? data : nil;
}

+ (id) decode:(NSData*) JSONData
      options:(RollbarCrashJSONDecodeOption) decodeOptions
        error:(NSError* __autoreleasing *) error
{
    RollbarCrashJSONCodec* codec = [self codecWithEncodeOptions:0
                                        decodeOptions:decodeOptions];
    NSMutableData* stringData = [NSMutableData dataWithLength:RCMAX_STRINGBUFFERSIZE+1];
    int errorOffset;
    int result = rcjson_decode(JSONData.bytes,
                               (int)JSONData.length,
                               stringData.mutableBytes,
                               (int)stringData.length,
                               codec.callbacks,
                               (__bridge void*)codec, &errorOffset);
    if(result != RollbarCrashJSON_OK && codec.error == nil)
    {
        codec.error = [NSError errorWithDomain:@"RollbarCrashJSONCodecObjC"
                                          code:0
                                   description:@"%s (offset %d)",
                       rcjson_stringForError(result),
                       errorOffset];
    }
    if(error != nil)
    {
        *error = codec.error;
    }

    if(result != RollbarCrashJSON_OK && !(decodeOptions & RollbarCrashJSONDecodeOptionKeepPartialObject))
    {
        return nil;
    }
    return codec.topLevelContainer;
}

@end
