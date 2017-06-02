//
//  Created by Jo Brunner on 30.05.17.
//  Copyright © 2017 Jo Brunner. All rights reserved.
//


@import Foundation;

@class CLLocation;

#define kRegionDatabaseDomain @"RegionDatabase"

typedef enum BindingType : NSInteger {
    kBindingTypeNull = 0,
    kBindingTypeInteger,
    kBindingTypeDouble,
    kBindingTypeText
} BindingType;

@interface BindParam: NSObject

@property (nonatomic) BindingType type;
@property (nonatomic) id value;

- (instancetype)initWithType:(BindingType)type value:(id)value;

@end

@interface RegionDatabase: NSObject

- (id)init;
- (id)initWithDbPath:(NSString *)dbPath;
- (void)dealloc;
- (NSArray *)execute:(NSString *)query with:(NSArray *)options error:(NSError **)error;

@end
