/*
 * Copyright (c) 2009 - 2013 By: CWS, Inc.
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
package com.cws.esolutions.security.services.impl;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.services.impl
 * File: AccessControlServiceImpl.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.sql.SQLException;

import com.cws.esolutions.security.dto.UserAccount;
import com.cws.esolutions.security.services.interfaces.IAccessControlService;
import com.cws.esolutions.security.services.exception.AccessControlServiceException;
/**
 * @see com.cws.esolutions.security.services.interfaces.IAccessControlService
 */
public class AccessControlServiceImpl implements IAccessControlService
{
    /**
     * @see com.cws.esolutions.security.services.interfaces.IAccessControlService#isUserAuthorized(com.cws.esolutions.security.dto.UserAccount, java.lang.String)
     */
    @Override
    public boolean isUserAuthorized(final UserAccount userAccount, final String serviceGuid) throws AccessControlServiceException
    {
        final String methodName = IAccessControlService.CNAME + "#isUserAuthorized(final UserAccount userAccount, final String serviceGuid) throws AccessControlServiceException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("UserAccount: {}", userAccount);
            DEBUGGER.debug("serviceGuid: {}", serviceGuid);
        }

        boolean isUserAuthorized = false;

        try
        {
            isUserAuthorized = sqlServiceDAO.verifyServiceForUser(userAccount.getGuid(), serviceGuid);

            if (DEBUG)
            {
                DEBUGGER.debug("isUserAuthorized: {}", isUserAuthorized);
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new AccessControlServiceException(sqx.getMessage(), sqx);
        }

        return isUserAuthorized;
    }
}