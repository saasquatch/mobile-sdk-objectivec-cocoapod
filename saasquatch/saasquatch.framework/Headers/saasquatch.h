//
//  saasquatch.h
//  saasquatch
//
//  Created by Brendan Crawford on 2016-04-14.
//  Copyright © 2016 Brendan Crawford. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for saasquatch.
FOUNDATION_EXPORT double saasquatchVersionNumber;

//! Project version string for saasquatch.
FOUNDATION_EXPORT const unsigned char saasquatchVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <saasquatch/PublicHeader.h>

/*!
 * `Saasquatch` is the Referral Saasquatch iOS SDK which provides a set of methods for interfacing with Referral SaaSquatch. It can register user with Referral SaaSquatch, retrieve information about users and referral codes, validate referral codes, and apply referral codes to a user's account.
 */
@interface Saasquatch : NSObject

/*!
 *  Registers a user with Referral SaaSquatch.
 *
 *  @param tenant            Identifies which tenant to connect to. For your app, you will get two tenant aliases -- one for test mode and one for live mode. Test mode alias are prefixed with <b>test_</b> , for example `test_abhoihnqwet`.
 *  @param userID            A user ID from your system (must be unique for every user). We use this to uniquely track users, and lets us handle accounts that are shared between users.
 *  @param accountID         We use this ID to link a group of users together. <a href="http://docs.referralsaasquatch.com/shared-vs-solo-accounts/"> See Shared vs Solo Accounts</a> to see what you should use here.
 *  @param token             The JWT to sign the request.
 *  @param userInfo          A Foundation object from which to generate JSON for the request.
 *  @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: **userInfo** the Foundation object containing the returned user information constructed from the JSON response, and **error** containing an NSError descibing the error if the request failed.
 *
 *
 *  @note The top level object in **userInfo** will be an NSDictionary containing the JSON data to be passed to the Referral SaaSquatch server. This requires the `id` and `accountId` values and can include several others. For a complete description see the Referral SaaSquatch REST API docs. Here is an example:
 *
 *  <pre>
 *  NSDictionary *userInfo = @{
 *      @"id" : @"10001110101",
 *      @"accountId" : @"10001110101",
 *      @"email" : @"claire@lallybroch.com",
 *      @"firstName" : @"Claire",
 *      @"lastName" : @"Fraser",
 *      @"locale" : @"en_US",
 *      @"referralCode" : @"CLAIREFRASER"
 *  };
 *  </pre>
 *
 *
 *  <b>See:</b> <a href="http://docs.referralsaasquatch.com/api/methods/#open_create_user"> Referral SaaSquatch REST API reference</a> for a list of available fields.
 *
 */
+ (void)registerUserForTenant:(NSString *)tenant
                   withUserID:(NSString *)userID
                withAccountID:(NSString *)accountID
                    withToken:(NSString *)token
                 withUserInfo:(id)userInfo
            completionHandler:(void (^)(id userInfo,
                                        NSError *error))completionHandler;

/*!
 *  Gets a user's information from Referral Saasquatch.
 *
 *  @param tenant            Identifies which tenant to connect to. For your app, you will get two tenant aliases -- one for test mode and one for live mode. Test mode alias are prefixed with <b>test_</b> , for example `test_abhoihnqwet`.
 *  @param userId            A user ID from your system (must be unique for every user). We use this to uniquely track users, and lets us handle accounts that are shared between users.
 *  @param accountID         We use this ID to link a group of users together. [See Shared vs Solo Accounts]("http://docs.referralsaasquatch.com/shared-vs-solo-accounts/" See Shared vs Solo Accounts) to see what you should use here.
 *  @param token             The JWT to sign the request.
 *  @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: **userInfo** the Foundation object containing the returned user information constructed from the JSON response, and **error** containing an NSError descibing the error if the request failed.
 *
 *
 *  <b>See:</b>  <a href="http://docs.referralsaasquatch.com/api/methods/#open_get_user"> Referral SaaSquatch REST API reference</a> for a list of available fields.
 *
 */
+ (void)userForTenant:(NSString *)tenant
           withUserID:(NSString *)userId
        withAccountID:(NSString *)accountID
           withToken:(NSString *)token
    completionHandler:(void (^)(id userInfo,
                                NSError *error))completionHandler;

/*!
 *  Gets a user's information by their referral code.
 *
 *  @param referralCode      The referral code of the user being looked up.
 *  @param tenant            Identifies which tenant to connect to. For your app, you will get two tenant aliases -- one for test mode and one for live mode. Test mode alias are prefixed with <b>test_</b> , for example `test_abhoihnqwet`.
 *  @param token             The JWT to sign the request.
 *  @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: **userInfo** the Foundation object containing the returned user information constructed from the JSON response, and **error** containing an NSError descibing the error if the request failed.
 *
 *
 *  <b>See:</b>  <a href="http://docs.referralsaasquatch.com/api/methods/#open_get_user_by_code"> Referral SaaSquatch REST API reference</a> for a list of available fields.
 *
 */
+ (void)userByReferralCode:(NSString *)referralCode
                 forTenant:(NSString *)tenant
                withToken:(NSString *)token
         completionHandler:(void (^)(id userInfo,
                                     NSError *error))completionHandler;

/*!
 *  Checks if a referral code exists and retrieves information about the code and it's reward.
 *
 *  @param referralCode      The referral code being validated.
 *  @param tenant            Identifies which tenant to connect to. For your app, you will get two tenant aliases -- one for test mode and one for live mode. Test mode alias are prefixed with <b>test_</b> , for example `test_abhoihnqwet`.
 *  @param token             The JWT to sign the request.
 *  @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: **userInfo** the Foundation object containing the returned referral code context constructed from the JSON response, and **error** containing an NSError descibing the error if the request failed.
 *
 *
 *  <b>See:</b>  <a href="http://docs.referralsaasquatch.com/api/methods/#open_validate_code"> Referral SaaSquatch REST API reference</a> for a list of available fields.
 *
 */
+ (void)lookupReferralCode:(NSString *)referralCode
                   forTenant:(NSString *)tenant
                  withToken:(NSString *)token
           completionHandler:(void (^)(id userInfo,
                                       NSError *error))completionHandler;

/*!
 *  Applies a referral code to a user's account.
 *
 *  @param referralCode The referral code to be applied.
 *  @param tenant       Identifies which tenant to connect to. For your app, you will get two tenant aliases -- one for test mode and one for live mode. Test mode alias are prefixed with <b>test_</b> , for example `test_abhoihnqwet`.
 *  @param userID       A user ID from your system (must be unique for every user). We use this to uniquely track users, and lets us handle accounts that are shared between users.
 *  @param accountID    We use this ID to link a group of users together. [See Shared vs Solo Accounts]("http://docs.referralsaasquatch.com/shared-vs-solo-accounts/" See Shared vs Solo Accounts) to see what you should use here.
 *  @param token        The JWT to sign the request.
 *  @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: **userInfo** the Foundation object containing the returned referral code information constructed from the JSON response, and **error** containing an NSError descibing the error if the request failed.
 *
 *
 *  <b>See:</b>  <a href="http://docs.referralsaasquatch.com/api/methods/#open_apply_code"> Referral SaaSquatch REST API reference</a> for a list of available fields.
 *
 */
+ (void)applyReferralCode:(NSString *)referralCode
                forTenant:(NSString *)tenant
                 toUserID:(NSString *)userID
              toAccountID:(NSString *)accountID
               withToken:(NSString *)token
        completionHandler:(void (^)(id userInfo,
                                    NSError *error))completionHandler;

/*!
 *  Returns the list of referrals for the tenant with options for filtering.
 *
 *  @param tenant            Identifies which tenant to connect to. For your app, you will get two tenant aliases -- one for test mode and one for live mode. Test mode alias are prefixed with <b>test_</b> , for example `test_abhoihnqwet`.
 *  @param token             The JWT to sign the request.
 *  @param accountID         When included, filters the results to only referrals that were referred by users with this account id.
 *  @param userID            When included, filters the results to only referrals that were referred by users with this user id.
 *  @param datePaid          When included, filters the results either to the exact timestamp if only one value is given, or a range if devided by a comma. I.E. 0,123412451 gives all referrals that converted between 0 and 123412451.
 *  @param dateEnded         When included, filters the results either to the exact timestamp if only one value is given, or a range if devided by a comma. I.E. 0,123412451 gives all referrals that ended between 0 and 123412451.
 *  @param referredStatus    When included, filters the result to only include referred users with that status. Statuses that are accepted: PENDING, APPROVED or DENIED.
 *  @param referrerStatus    When included, filters the result to only include referrers with that status. Statuses that are accepted: PENDING, APPROVED or DENIED.
 *  @param limit             A limit on the number of results returned. Defaults to 10.
 *  @param offset            When included offsets the first result returns in the list. Use this to paginate through a long list of results. Defaults to 0.
 *  @param completionHandler A block object to be executed when the task finishes. This block has no return value and takes two arguments: **userInfo** the Foundation object containing the returned referrals information constructed from the JSON response, and **error** containing an NSError descibing the error if the request failed.
 *
 *  <b>See:</b>  <a href="http://docs.referralsaasquatch.com/api/methods/#open_list_referrals"> Referral SaaSquatch REST API reference</a> for a list of available fields.
 *
 */
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
             completionHandler:(void (^)(id userInfo,
                                         NSError *error))completionHandler;
@end