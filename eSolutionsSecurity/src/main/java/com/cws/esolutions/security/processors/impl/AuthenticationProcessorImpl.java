/*
 * Copyright (c) 2009 - 2020 CaspersBox Web Services
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.cws.esolutions.security.processors.impl;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.processors.impl
 * File: AuthenticationProcessorImpl.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly          11/23/2008 22:39:20             Created.
 */
import java.util.Date;
import java.util.List;
import java.util.Objects;
import java.sql.SQLException;
import org.apache.commons.codec.binary.StringUtils;

import com.cws.esolutions.security.dto.UserAccount;
import com.cws.esolutions.security.utils.PasswordUtils;
import com.cws.esolutions.security.enums.SecurityUserRole;
import com.cws.esolutions.security.processors.enums.SaltType;
import com.cws.esolutions.security.processors.dto.AuditEntry;
import com.cws.esolutions.security.processors.enums.AuditType;
import com.cws.esolutions.security.processors.dto.AuditRequest;
import com.cws.esolutions.security.enums.SecurityRequestStatus;
import com.cws.esolutions.security.processors.enums.LoginStatus;
import com.cws.esolutions.security.processors.dto.RequestHostInfo;
import com.cws.esolutions.security.processors.dto.AuthenticationData;
import com.cws.esolutions.security.exception.SecurityServiceException;
import com.cws.esolutions.security.processors.dto.AuthenticationRequest;
import com.cws.esolutions.security.processors.dto.AuthenticationResponse;
import com.cws.esolutions.security.processors.exception.AuditServiceException;
import com.cws.esolutions.security.processors.exception.AuthenticationException;
import com.cws.esolutions.security.processors.interfaces.IAuthenticationProcessor;
/**
 * @see com.cws.esolutions.security.processors.interfaces.IAuthenticationProcessor
 */
public class AuthenticationProcessorImpl implements IAuthenticationProcessor
{
    private static final String CNAME = AuthenticationProcessorImpl.class.getName();

    /**
     * @see com.cws.esolutions.security.processors.interfaces.IAuthenticationProcessor#processAgentLogon(com.cws.esolutions.security.processors.dto.AuthenticationRequest)
     */
    public AuthenticationResponse processAgentLogon(final AuthenticationRequest request) throws AuthenticationException
    {
        final String methodName = AuthenticationProcessorImpl.CNAME + "#processAgentLogon(final AuthenticationRequest request) throws AuthenticationException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("AuthenticationRequest: {}", request);
        }

        boolean isValid = false;
        UserAccount userAccount = null;
        AuthenticationResponse response = new AuthenticationResponse();

        final RequestHostInfo reqInfo = request.getHostInfo();
        final UserAccount authUser = request.getUserAccount();
        final AuthenticationData authSec = request.getUserSecurity();

        if (DEBUG)
        {
            DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            DEBUGGER.debug("UserAccount: {}", authUser);
        }

        try
        {
        	List<String> userInfo = userManager.getUserByUsername(authUser.getUsername());

            if (DEBUG)
            {
                DEBUGGER.debug("userInfo: {}", userInfo);
            }

            if (Objects.isNull(userInfo))
            {
            	throw new AuthenticationException("Unable to locate an account for the given information. Cannot continue");
            }

            String userId = userInfo.get(1);
            String userGuid = userInfo.get(0);

            if (DEBUG)
            {
            	DEBUGGER.debug("userId: {}", userId);
            	DEBUGGER.debug("userGuid: {}", userGuid);
            }

            String userSalt = userSec.getUserSalt(userGuid, SaltType.LOGON.name());
            String userPassword = userSec.getUserPassword(userGuid, userId);

            if (DEBUG)
            {
            	DEBUGGER.debug("userSalt: {}", userSalt);
            	DEBUGGER.debug("userPassword: {}", userPassword);
            }

            if (Objects.isNull(userSalt))
            {
                throw new AuthenticationException("Unable to obtain configured user security information. Cannot continue");
            }

            String returnedPassword = PasswordUtils.encryptText(authSec.getPassword(), userSalt,
                    secConfig.getSecretKeyAlgorithm(),
                    secConfig.getIterations(), secConfig.getKeyLength(),
                    //secConfig.getEncryptionAlgorithm(), secConfig.getEncryptionInstance(),
                    sysConfig.getEncoding());

            if (DEBUG)
            {
            	DEBUGGER.debug("returnedPassword: {}", returnedPassword);
            }

            if (!(StringUtils.equals(returnedPassword, userPassword)))
            {
            	throw new AuthenticationException("The user account was not validated.");
            }

            // load the user account here
            List<Object> authObject = userManager.loadUserAccount(userGuid);

            if (DEBUG)
            {
            	DEBUGGER.debug("authObject: {}", authObject);
            }

            if (Objects.isNull(authObject))
            {
            	// no data was returned
            	response.setRequestStatus(SecurityRequestStatus.FAILURE);

            	return response;
            }
            else
            {
            	userAccount = new UserAccount();

            	if ((Integer) authObject.get(3) >= secConfig.getMaxAttempts())
            	{
            		userAccount.setStatus(LoginStatus.LOCKOUT);

            		if (DEBUG)
            		{
            			DEBUGGER.debug("userAccount: {}", userAccount);
            		}

            		response.setUserAccount(userAccount);
            		response.setRequestStatus(SecurityRequestStatus.FAILURE);
	            }
	            else if ((Boolean) authObject.get(8))
	            {
            		userAccount.setStatus(LoginStatus.SUSPENDED);

            		if (DEBUG)
            		{
            			DEBUGGER.debug("userAccount: {}", userAccount);
            		}

            		response.setUserAccount(userAccount);
	            	response.setRequestStatus(SecurityRequestStatus.FAILURE);
	            }
	            else
	            {
	            	userAccount.setGuid((String) authObject.get(1)); // UID
		            userAccount.setUsername((String) authObject.get(0)); // CN
		            userAccount.setUserRole(SecurityUserRole.valueOf((String) authObject.get(2))); // USER_ROLE
		            userAccount.setFailedCount((Integer) authObject.get(3)); // FAILEDCOUNT
		            userAccount.setLastLogin((Date) authObject.get(4)); // LAST LOGON
		            userAccount.setSurname((String) authObject.get(5)); // SURNAME
		            userAccount.setGivenName((String) authObject.get(6)); // GIVEN NAME
		            userAccount.setExpiryDate((Date) authObject.get(7)); // EXPIRY_DATE
		            userAccount.setSuspended((Boolean) authObject.get(8));  // SUSPENDED
		            userAccount.setDisplayName((String) authObject.get(11)); // DISPLAYNAME
		            userAccount.setEmailAddr((String) authObject.get(13)); // EMAIL
		
		            if (DEBUG)
		            {
		                DEBUGGER.debug("UserAccount: {}", userAccount);
		            }
		
		            // have a user account, run with it
		            if ((userAccount.getExpiryDate().before(new Date(System.currentTimeMillis())) || (userAccount.getExpiryDate().equals(new Date(System.currentTimeMillis())))))
		            {
		                userAccount.setStatus(LoginStatus.EXPIRED);
		
		                response.setRequestStatus(SecurityRequestStatus.SUCCESS);
		                response.setUserAccount(userAccount);
		            }
		            else
		            {
		                authenticator.performSuccessfulLogin(userAccount.getUsername(), userAccount.getGuid(), userAccount.getFailedCount(), System.currentTimeMillis());
		
		                userAccount.setLastLogin(new Date(System.currentTimeMillis()));
		                userAccount.setStatus(LoginStatus.SUCCESS);
		
		                response.setRequestStatus(SecurityRequestStatus.SUCCESS);
		                response.setUserAccount(userAccount);
		            }

		            if (DEBUG)
		            {
		                DEBUGGER.debug("UserAccount: {}", userAccount);
		                DEBUGGER.debug("AuthenticationResponse: {}", response);
		            }
	            }
            }
        }
        catch (final SecurityServiceException ssx)
        {
            ERROR_RECORDER.error(ssx.getMessage(), ssx);

            throw new AuthenticationException(ssx.getMessage(), ssx);
        }
        catch (final SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new AuthenticationException(sqx.getMessage(), sqx);
        }
        finally
        {
        	if ((secConfig.getPerformAudit()) && (isValid))
        	{
	            // audit if a valid account. if not valid we cant audit much,
        		// but we should try anyway. not sure how thats going to work
	            try
	            {
	                AuditEntry auditEntry = new AuditEntry();
	                auditEntry.setHostInfo(reqInfo);
	                auditEntry.setAuditType(AuditType.LOGON);
	                auditEntry.setUserAccount(userAccount);
	                auditEntry.setAuthorized(Boolean.TRUE);
	                auditEntry.setApplicationId(request.getApplicationId());
	                auditEntry.setApplicationName(request.getApplicationName());
	
	                if (DEBUG)
	                {
	                    DEBUGGER.debug("AuditEntry: {}", auditEntry);
	                }
	
	                AuditRequest auditRequest = new AuditRequest();
	                auditRequest.setAuditEntry(auditEntry);
	
	                if (DEBUG)
	                {
	                    DEBUGGER.debug("AuditRequest: {}", auditRequest);
	                }

	                auditor.auditRequest(auditRequest);
	            }
	            catch (final AuditServiceException asx)
	            {
	                ERROR_RECORDER.error(asx.getMessage(), asx);
	            }
        	}
        }

        return response;
    }
}
