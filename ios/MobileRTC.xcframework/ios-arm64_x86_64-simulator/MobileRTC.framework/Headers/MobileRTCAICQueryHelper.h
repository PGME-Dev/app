//
//  MobileRTCAIQueryHelper.h
//  MobileRTC
//
//  Created by Zoom on 2024/5/7.
//  Copyright © Zoom Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MobileRTCAICompanionQueryFeedbackType) {
    MobileRTCAICompanionQueryFeedbackType_None = 0, //Initialization.
    MobileRTCAICompanionQueryFeedbackType_Good,     //Good.
    MobileRTCAICompanionQueryFeedbackType_Bad       //Bad.
};

typedef NS_ENUM(NSUInteger, MobileRTCAICompanionQueryRequestError) {
    MobileRTCAICompanionQueryRequestError_OK = 0,                //OK.
    MobileRTCAICompanionQueryRequestError_InvalidParam,          //Invalid param.
    MobileRTCAICompanionQueryRequestError_SendFailed,            //Send failed.
    MobileRTCAICompanionQueryRequestError_WebUnAvailable,        //Web unavailable.
    MobileRTCAICompanionQueryRequestError_PermissionVerifyFailed,//Permission verify failed.
    MobileRTCAICompanionQueryRequestError_QueryRateLimitError,   //Query rate limit error.
    MobileRTCAICompanionQueryRequestError_Timeout,               //Timeout.
    MobileRTCAICompanionQueryRequestError_Unknown = 100          //Unknown.
};

typedef NS_ENUM(NSUInteger, MobileRTCAICompanionQuerySettingOptions) {
    MobileRTCAICompanionQuerySettingOptions_None = 0,              ///<Initialization.
    MobileRTCAICompanionQuerySettingOptions_WhenQueryStarted,      ///<WhenQueryStarted. All participants can ask question, and answers are based on the meeting's start until now.
    MobileRTCAICompanionQuerySettingOptions_WhenParticipantsJoin,  ///<WhenParticipantsJoin. All participants can ask question, and answers are based on the current user's joining
    MobileRTCAICompanionQuerySettingOptions_OnlyHost,               ///<OnlyHost. Only hosts and users with host privileges assigned before the meeting starts can ask question.
    MobileRTCAICompanionQuerySettingOptions_ParticipantsAndInviteesInOurOrganization, ///<//All participants in our organization can ask question, and answers are based on the meeting's start until now.
    MobileRTCAICompanionQuerySettingOptions_WhenParticipantsAndOrganizationJoin, ///All participants in our organization can ask question, and answers are based on the current user's joining time until now.
};

@interface MobileRTCAICompanionQueryItem : NSObject
/**
 @brief Get the query question content.
 */
@property(nonatomic, copy, readonly, nullable) NSString* qustionContent;
/**
 @brief Get the query question ID.
 */
@property(nonatomic, copy, readonly, nullable) NSString* queryID;

/**
 @brief Get the query answer content.
 */
@property(nonatomic, copy, readonly, nullable) NSString* answerContent;

/**
 @brief Get the error code.
 */
@property(nonatomic, assign, readonly) MobileRTCAICompanionQueryRequestError errorCode;

/**
 @brief Get the error message.
 */
@property(nonatomic, copy, readonly, nullable) NSString* errorMsg;

/**
 @brief Get the timestamp.
 */
@property(nonatomic, strong, readonly, nullable) NSDate *timestamp;

/**
 @brief Send feedback of query answer.
 @param feedbackType The feedback type.
 @return If the function succeeds, it will return MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)feedback:(MobileRTCAICompanionQueryFeedbackType)feedbackType;
@end

@interface MobileRTCEnableQueryHandler : NSObject
/**
 @brief Enable meeting query.
 @return If the function succeeds, it will return MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)enableQuery;

/**
 @brief Determine if this handler for request enable query.
 @return YES means this handler is for request enable query. Otherwise it returns NO means this handler is for enable query directly.
 */
- (BOOL)isForRequest;

@end

@interface MobileRTCStartQueryHandler : NSObject
/**
 @brief Start meeting query.
 @return If the function succeeds, it will return MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)startMeetingQuery;

/**
 @brief Determine if this handler for request enable query.
 @return YES means this handler is for request enable query. Otherwise it returns NO and is not available.
 */
- (BOOL)isForRequest;

@end

@interface MobileRTCApproveEnableQueryHandler : NSObject
/**
 @brief Get the requester's user ID.
 */
@property (nonatomic, assign) NSUInteger senderUserID;

/**
 @brief Continue approve action.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)continueApprove;
@end

@interface MobileRTCApproveStartQueryHandler : NSObject
/**
 @brief Get the requester's user ID.
 */
@property (nonatomic, assign, readonly) NSUInteger senderUserID;
/**
 @brief Approve the request.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)approve;

/**
 @brief Decline the request.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)decline;

@end

@interface MobileRTCSendQueryHandler : NSObject

/**
 @brief Get  default query questions.
 @return If the function succeeds, it returns the array of questions. Otherwise the function fails and returns nothing.
 */
- (NSArray<NSString *> *_Nullable)getDefaultQueryQuestions;

/**
 @brief Send query question.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)sendQueryQuestion:(NSString * _Nullable)question;

/**
 @brief Stop meeting query.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)stopMeetingQuery;

/**
 @brief Deterine if can send query.
 @return YES means can, otherwise not.
 */
- (BOOL)canSendQuery;

/**
 @brief Request send query privilege.
 @return If the function succeeds, it returns MobileRTCSDKError_Success Otherwise the function fails.
 */
- (MobileRTCSDKError)requestSendQueryPrivilege;

@end

@interface MobileRTCApproveSendQueryHandler : NSObject
/**
 @brief Get the requester's user ID.
 */
@property (nonatomic, assign) NSUInteger senderUserID;

/**
 @brief Approve the request.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)approve;

/**
 @brief Decline the request.
 @param declineAll YES means decline all request.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)decline:(BOOL)declineAll;
@end

@interface MobileRTCEnableQueryActionHandler : NSObject
/**
 @brief Get the title of the tip.
 */
- (NSString *_Nullable)tipTitle;

/**
 @brief Get the tip string.
 */
- (NSString *_Nullable)tipString;

/**
 @brief Confirm enable query.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)confirm;

/**
 @brief Cancel enable query.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise the function fails.
 */
- (MobileRTCSDKError)cancel;
@end


@protocol MobileRTCAICompanionQueryHelperDelegate <NSObject>
@optional
/**
 @brief Notification that meeting does not support meeting query.
 */
- (void)onQueryStateNotSupported;

/**
 @brief Notification that the meeting supports query but query feature is disabled.
 @param handler The handler to enable the query.
 */
- (void)onQueryStateEnabledButNotStarted:(MobileRTCStartQueryHandler *_Nullable)handler;

/**
 @brief Notification that the meting supports query but query feature is disabled.
 @param handler The handler to enable the query.
 */
- (void)onQueryStateSupportedButDisabled:(MobileRTCEnableQueryHandler *_Nullable)handler;

/**
 @brief Notification that the query is started.
 @param handler The handler to send the query.
 */
- (void)onQueryStateStarted:(MobileRTCSendQueryHandler *_Nullable)handler;

/**
 @brief Notification that the query setting is changed.
 @param setting The selected query setting.
 */
- (void)onQuerySettingChanged:(MobileRTCAICompanionQuerySettingOptions)setting;

/**
 @brief Notification that the request send query failed.
 @param bTimeout YES means that the request timeout. No means the user declines the request.
 */
- (void)onFailedToStartQuery:(BOOL)bTimeout;

/**
 @brief Notification of receiving request to enable query.
 @param handler The handler to handle the request.
 */
- (void)onReceiveRequestToEnableQuery:(MobileRTCApproveEnableQueryHandler *_Nullable)handler;

/**
 @brief Notification of receiving request to start query.
 @param handler The handler to handle the request.
 */
- (void)onReceiveRequestToStartQuery:(MobileRTCApproveStartQueryHandler *_Nullable)handler;

/**
 @brief Notification of receiving query answer.
 @param queryItem The obect of MobileRTCAICompanionQueryItem.
 */
- (void)onReceiveQueryAnswer:(MobileRTCAICompanionQueryItem *_Nullable)queryItem;

/**
 @brief Notification of receiving query enable action callback.
 @param handler The handler to enable the query.
 */
- (void)onQueryEnableActionCallback:(MobileRTCEnableQueryActionHandler *_Nullable)handler;

/**
 @brief Notification of got or loss send query question privilege.
 @param canSendQuery YES means can send. Otherwise not.
 */
- (void)onSendQueryPrivilegeChanged:(BOOL)canSendQuery;

/**
 @brief Notification that failed to request send query.
 @param bTimeout YES means is timeout. No measn the user declines the request.
 */
- (void)onFailedToRequestSendQuery:(BOOL)bTimeout;

/**
 @brief Notification of receiving request to send query.
 @param handler The handler to handle the request.
 */
- (void)onReceiveRequestToSendQuery:(MobileRTCApproveSendQueryHandler *_Nullable)handler;

@end

@interface MobileRTCAICompanionQueryHelper : NSObject

@property(nonatomic, weak) id<MobileRTCAICompanionQueryHelperDelegate> delegate;

/**
 @brief Get the selected query setting.
 @return If the function succeeds, it returns the selected query setting. Otherwise the function fails.
 */
- (MobileRTCAICompanionQuerySettingOptions)getSelectedQuerySetting;

/**
 @brief Determine whether the current user can change the query setting.
 @return YES means that it can change the setting. Otherwise it can't change the setting.
 */
- (BOOL)canChangeQuerySetting;

/**
 @brief Change query setting.
 @return If the function succeeds, it returns MobileRTCSDKError_Success. Otherwise nthe function fails.
 */
- (MobileRTCSDKError)changeQuerySettings:(MobileRTCAICompanionQuerySettingOptions)setting;

@end
