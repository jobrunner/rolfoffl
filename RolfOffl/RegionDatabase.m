//
//  Created by Jo Brunner on 30.05.17.
//  Copyright © 2017 Jo Brunner. All rights reserved.
//

@import CoreLocation;
#import "RegionDatabase.h"

//#include <sqlite3.h>
//#include <spatialite/gaiageo.h>
//#include <spatialite.h>

#import <sqlite3.h>
#import <spatialite/gaiageo.h>
#import <spatialite.h>

@implementation BindParam

- (instancetype)initWithType:(BindingType)type value:(id)value {
    
    if (self = [super init]) {
        _type = type;
        _value = value;
    }
    
    return self;
}

@end

@interface RegionDatabase()

@property (nonatomic, assign) sqlite3 *connection;
@property (nonatomic, assign) void *cache;

@end

@implementation RegionDatabase

- (id)init {
    
    if ((self = [super init])) {
        
        NSString *sqliteDbPath = [[NSBundle mainBundle] pathForResource:@"plz"
                                                                 ofType:@"sqlite"];
        return [self initWithDbPath:sqliteDbPath];
    }
    
    return self;
}


- (id)initWithDbPath:(NSString *)dbPath {
    
    if (self = [super init]) {
        
        int ret = sqlite3_open_v2([dbPath UTF8String],
                                  &_connection,
                                  SQLITE_OPEN_READONLY,
                                  NULL);
        if (ret != SQLITE_OK) {

            sqlite3_close(_connection);
        }
        
        _cache = spatialite_alloc_connection();
        spatialite_init_ex(_connection, _cache, 0);
    }
    
    return self;
}


- (void)dealloc {

    sqlite3_close(_connection);
    spatialite_cleanup_ex(_cache);
}


- (NSArray *)execute:(NSString *)query with:(NSArray *)values error:(NSError **)error {
    
    sqlite3_stmt *stmt;
    
    int ret = sqlite3_prepare_v2(_connection,
                                 [query cStringUsingEncoding:NSUTF8StringEncoding],
                                 (int)query.length,
                                 &stmt,
                                 NULL);

    [self bindValues:values statement:stmt];

    if (ret != SQLITE_OK) {

        NSString *errorMessage = [NSString stringWithFormat:@"Query SQL error: %s", sqlite3_errmsg(_connection)];
        NSDictionary * userInfo = @{NSLocalizedDescriptionKey:errorMessage};

        *error = [NSError errorWithDomain:kRegionDatabaseDomain
                                     code:0
                                 userInfo:userInfo];
        return @[];
    }
    
    sqlite3_reset(stmt);
    
    int n_columns = sqlite3_column_count(stmt);
    
    NSMutableArray *result = [NSMutableArray new];
    
    while (YES) {
        ret = sqlite3_step(stmt);
        
        if (ret == SQLITE_DONE) {
            
            break;
        }
        
        if (ret == SQLITE_ROW) {
            for (int ic = 0; ic < n_columns; ic++) {
                
                if (sqlite3_column_type(stmt, ic) == SQLITE_TEXT) {
                    NSString *key = [NSString stringWithUTF8String:(char *)sqlite3_column_name(stmt, ic)];
                    NSString *value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stmt, ic)];
                    NSDictionary *row = [NSDictionary dictionaryWithObject:value forKey:key];
                    
                    [result addObject:row];
                }
            }
        }
    }
    
    *error = nil;
    
    return result.mutableCopy;
}


- (void)bindValues:(NSArray *)values
        statement:(sqlite3_stmt *)stmt {

    for (int ic = 1; ic <= values.count; ic++) {
        [self bindValue:values[ic - 1]
                  index:ic
              statement:stmt];
    }
}


- (void)bindValue:(BindParam *)param
            index:(int)position
        statement:(sqlite3_stmt *)stmt {

    switch (param.type) {
        case kBindingTypeNull:
            sqlite3_bind_null(stmt, position);
            break;
            
        case kBindingTypeInteger: {
            int i = [param.value intValue];
            sqlite3_bind_int(stmt, position, i);
            break;
        }
            
        case kBindingTypeDouble: {
            double d = [param.value doubleValue];
            sqlite3_bind_double(stmt, position, d);
            break;
        }

        case kBindingTypeText: {
            NSString *s = [param.value stringValue];
            const char *text = [s cStringUsingEncoding:NSUTF8StringEncoding];
            sqlite3_bind_text(stmt,
                              position,
                              text, // [t cStringUsingEncoding:NSUTF8StringEncoding],
                              sizeof(text), //  .length,
                              SQLITE_STATIC);
            break;
        }
        default:
            NSLog(@"Warning: Unsupported Type of BindParam.");
    }
}

@end
