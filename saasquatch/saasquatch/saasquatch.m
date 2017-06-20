//
//  saasquatch.m
//  saasquatch
//
//  Created by Brendan Crawford on 2016-04-14.
//  Updated by Trevor Lee on 2017-06-20
//

#import <Foundation/Foundation.h>
#import "saasquatch.h"


#ifdef DEBUG
static NSString *const urlString = @"http://localhost:8080/api/v1";
#else
static NSString *const urlString = @"https://app.referralsaasquatch.com/api/v1";
#endif

static NSURL *baseURL;
static NSURLSession *session;

@implementation Saasquatch

+ (void)initialize {
    baseURL = [[NSURL alloc] initWithString:urlString];
    session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

+ (void)registerUserForTenant:(NSString *)tenant
                   withUserID:(NSString *)userID
                withAccountID:(NSString *)accountID
                    withToken:(NSString *)token
                 withUserInfo:(id)userInfo
            completionHandler:(void (^)(id, NSError *))completionHandler {
    
    NSURL *url = [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@/open/account/%@/user/%@", tenant, accountID, userID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"X-SaaSquatch-User-Token"];
    request.HTTPMethod = @"POST";
    
    NSData *data;
    NSError *error;
    data = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
    if (error) {
        completionHandler(nil, error);
        return;
    }
    
    request.HTTPBody = data;
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        if (error){
            completionHandler(nil, error);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString *textEncodingName = response.textEncodingName;
        CFStringRef cfTestEncodingName = (__bridge CFStringRef) textEncodingName;
        if (textEncodingName) {
            CFStringEncoding cfStringEncoding = CFStringConvertIANACharSetNameToEncoding(cfTestEncodingName);
            encoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding);
        }
        
        if ([httpResponse statusCode] == 201) {
            id userInfo;
            NSError *error;
            
            userInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                completionHandler(nil, error);
                return;
            }
            
            completionHandler(userInfo, nil);
            
        } else {
            NSString *errorString = [[NSString alloc] initWithData:data encoding:encoding];
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorString };
            NSError *error = [NSError errorWithDomain:@"HTTP error" code:[httpResponse statusCode] userInfo:userInfo];
            completionHandler(nil, error);
            return;
        }
        
    }];
    
    [task resume];
}

+ (void)userForTenant:(NSString *)tenant
           withUserID:(NSString *)userId
        withAccountID:(NSString *)accountID
            withToken:(NSString *)token
    completionHandler:(void (^)(id, NSError *))completionHandler {
    
    NSURL *url = [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@/open/account/%@/user/%@", tenant, accountID, userId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"X-SaaSquatch-User-Token"];
    
    NSURLSessionDataTask *task = [self saasquatchDataTaskStatusOKWithRequest:request withCallback:completionHandler];
    
    [task resume];
}

+ (void)userByReferralCode:(NSString *)referralCode
                 forTenant:(NSString *)tenant
                 withToken:(NSString *)token
         completionHandler:(void (^)(id, NSError *))completionHandler {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/open/user?referralCode=%@", baseURL, tenant, referralCode];
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : @"A URL cannot be formed from the parameters provided" };
        NSError *error = [NSError errorWithDomain:@"Malformed URL" code:123456 userInfo:userInfo];
        completionHandler(nil, error);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (token) {
        [request setValue:token forHTTPHeaderField:@"X-SaaSquatch-User-Token"];
    }
    
    NSURLSessionDataTask *task = [self saasquatchDataTaskStatusOKWithRequest:request withCallback:completionHandler];
    
    [task resume];
}

+ (void)lookupReferralCode:(NSString *)referralCode
                 forTenant:(NSString *)tenant
                 withToken:(NSString *)token
         completionHandler:(void (^)(id, NSError *))completionHandler {
    
    NSURL *url = [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@/open/code/%@", tenant, referralCode]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (token) {
        [request setValue:token forHTTPHeaderField:@"X-SaaSquatch-User-Token"];
    }
    
    NSURLSessionDataTask *task = [self saasquatchDataTaskStatusOKWithRequest:request withCallback:completionHandler];
    
    [task resume];
}

+ (void)applyReferralCode:(NSString *)referralCode
                forTenant:(NSString *)tenant
                 toUserID:(NSString *)userID
              toAccountID:(NSString *)accountID
                withToken:(NSString *)token
        completionHandler:(void (^)(id, NSError *))completionHandler {
    
    NSURL *url = [baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"/%@/open/code/%@/account/%@/user/%@", tenant, referralCode, accountID, userID]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"X-SaaSquatch-User-Token"];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *task = [self saasquatchDataTaskStatusOKWithRequest:request withCallback:completionHandler];
    
    [task resume];
}

+ (void)listReferralsForTenant:(NSString *)tenant
                     withToken:(NSString *)token
         forReferringAccountID:(NSString *)accountID
            forReferringUserID:(NSString *)userID
        beforeDateReferralPaid:(NSString *)datePaid
       beforeDateReferralEnded:(NSString *)dateEnded
  withReferredModerationStatus:(NSString *)referredStatus
  withReferrerModerationStatus:(NSString *)referrerStatus
                     withLimit:(NSString *)limit
                    withOffset:(NSString *)offset
             completionHandler:(void (^)(id, NSError *))completionHandler {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/open/referrals", baseURL, tenant];
    
    NSMutableArray *queryParams = [[NSMutableArray alloc] init];
    if (accountID) {
        NSString *queryParam = [NSString stringWithFormat:@"referringAccountId=%@", accountID];
        [queryParams addObject:queryParam];
    }
    if (userID) {
        NSString *queryParam = [NSString stringWithFormat:@"referringUserId=%@", userID];
        [queryParams addObject:queryParam];
    }
    if (datePaid) {
        NSString *queryParam = [NSString stringWithFormat:@"dateReferralPaid=%@", datePaid];
        [queryParams addObject:queryParam];
    }
    if (dateEnded) {
        NSString *queryParam = [NSString stringWithFormat:@"dateReferralEnded=%@", dateEnded];
        [queryParams addObject:queryParam];
    }
    if (referredStatus) {
        NSString *queryParam = [NSString stringWithFormat:@"referredModerationStatus=%@", referredStatus];
        [queryParams addObject:queryParam];
    }
    if (referrerStatus) {
        NSString *queryParam = [NSString stringWithFormat:@"referrerModerationStatus=%@", referrerStatus];
        [queryParams addObject:queryParam];
    }
    if (limit) {
        NSString *queryParam = [NSString stringWithFormat:@"limit=%@", limit];
        [queryParams addObject:queryParam];
    }
    if (offset) {
        NSString *queryParam = [NSString stringWithFormat:@"offset=%@", offset];
        [queryParams addObject:queryParam];
    }
    
    BOOL first = YES;
    for (NSString *param in queryParams) {
        if (first) {
            urlString = [[urlString stringByAppendingString:@"?"] stringByAppendingString:param];
            first = NO;
        } else {
            urlString = [[urlString stringByAppendingString:@"&"] stringByAppendingString:param];
        }
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url == nil) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"A URL cannot be formed from the parameters" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"Malformed URL" code:0 userInfo:userInfo];
        completionHandler(nil, error);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"X-SaaSquatch-User-Token"];
    
    NSURLSessionDataTask *task = [self saasquatchDataTaskStatusOKWithRequest:request withCallback:completionHandler];
    [task resume];
}

+ (NSURLSessionDataTask *)saasquatchDataTaskStatusOKWithRequest:(NSMutableURLRequest *)request withCallback:(void (^)(id, NSError *))completionHandler {
    
    return [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        
        if (error) {
            completionHandler(nil, error);
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        NSStringEncoding encoding = NSUTF8StringEncoding;
        NSString *textEncodingName = response.textEncodingName;
        CFStringRef cfTestEncodingName = (__bridge CFStringRef) textEncodingName;
        if (textEncodingName) {
            CFStringEncoding cfStringEncoding = CFStringConvertIANACharSetNameToEncoding(cfTestEncodingName);
            encoding = CFStringConvertEncodingToNSStringEncoding(cfStringEncoding);
        }
        
        if ([httpResponse statusCode] == 200) {
            id userInfo;
            NSError *error;
            
            userInfo = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                completionHandler(nil, error);
                return;
            }
            
            completionHandler(userInfo, nil);
            
        } else {
            NSString *errorString = [[NSString alloc] initWithData:data encoding:encoding];
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : errorString };
            NSError *error = [NSError errorWithDomain:@"HTTP error" code:[httpResponse statusCode] userInfo:userInfo];
            completionHandler(nil, error);
            return;
        }
    }];
}

@end
