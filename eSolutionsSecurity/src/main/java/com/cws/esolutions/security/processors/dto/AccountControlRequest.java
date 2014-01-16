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
package com.cws.esolutions.security.processors.dto;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.processors.dto
 * File: AccountControlRequest.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.List;
import org.slf4j.Logger;
import java.io.Serializable;
import org.slf4j.LoggerFactory;
import java.lang.reflect.Field;

import com.cws.esolutions.security.dto.UserAccount;
import com.cws.esolutions.security.SecurityServiceConstants;
import com.cws.esolutions.security.processors.enums.ControlType;
import com.cws.esolutions.security.processors.dto.RequestHostInfo;
import com.cws.esolutions.security.processors.enums.ModificationType;
import com.cws.esolutions.security.processors.dto.AuthenticationData;
import com.cws.esolutions.security.dao.usermgmt.enums.SearchRequestType;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author khuntly
 * @version 1.0
 */
public class AccountControlRequest implements Serializable
{
    private int startPage = 0;
    private boolean isReset = false;
    private String projectId = null;
    private String serviceId = null;
    private String applicationId = null;
    private UserAccount requestor = null;
    private String applicationName = null;
    private ControlType controlType = null;
    private boolean isLoginRequest = false;
    private UserAccount userAccount = null;
    private RequestHostInfo hostInfo = null;
    private ModificationType modType = null;
    private AuthenticationData userSecurity = null;
    private List<String> servicesList = null;
    private SearchRequestType searchType = null;

    private static final long serialVersionUID = -6754484691575800762L;
    private static final String CNAME = AccountControlRequest.class.getName();

    private static final Logger DEBUGGER = LoggerFactory.getLogger(SecurityServiceConstants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(SecurityServiceConstants.ERROR_LOGGER);

    public final void setHostInfo(final RequestHostInfo value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setBaseDN(final RequestHostInfo value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.hostInfo = value;
    }

    public final void setUserAccount(final UserAccount value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setLoginType(final UserAccount value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.userAccount = value;
    }

    public final void setUserSecurity(final AuthenticationData value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setLoginType(final AuthenticationData value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        this.userSecurity = value;
    }

    public final void setApplicationName(final String value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setApplicationName(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.applicationName = value;
    }

    public final void setApplicationId(final String value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setApplicationId(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.applicationId = value;
    }

    public final void setControlType(final ControlType value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setControlType(final ControlType value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.controlType = value;
    }

    public final void setModType(final ModificationType value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setControlType(final ModificationType value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.modType = value;
    }

    public final void setSearchType(final SearchRequestType value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setSearchType(final SearchRequestType value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.searchType = value;
    }

    public final void setRequestor(final UserAccount value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setRequestor(final UserAccount value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.requestor = value;
    }

    public final void setIsReset(final boolean value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setIsReset(final boolean value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.isReset = value;
    }

    public final void setIsLogonRequest(final boolean value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setIsLogonRequest(final boolean value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.isLoginRequest = value;
    }

    public final void setServiceId(final String value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setServiceId(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.serviceId = value;
    }

    public final void setServicesList(final List<String> value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setServicesList(final List<String> value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.servicesList = value;
    }

    public final void setProjectId(final String value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setProjectId(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.projectId = value;
    }

    public final void setStartPage(final int value)
    {
        final String methodName = AccountControlRequest.CNAME + "#setStartPage(final int value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.startPage = value;
    }

    public final RequestHostInfo getHostInfo()
    {
        final String methodName = AccountControlRequest.CNAME + "#getHostInfo()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.hostInfo);
        }

        return this.hostInfo;
    }

    public final UserAccount getUserAccount()
    {
        final String methodName = AccountControlRequest.CNAME + "#getLoginType()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.userAccount);
        }

        return this.userAccount;
    }

    public final AuthenticationData getUserSecurity()
    {
        final String methodName = AccountControlRequest.CNAME + "#getUserSecurity()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        return this.userSecurity;
    }

    public final String getApplicationName()
    {
        final String methodName = AccountControlRequest.CNAME + "#getApplicationName()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.applicationName);
        }

        return this.applicationName;
    }

    public final String getApplicationId()
    {
        final String methodName = AccountControlRequest.CNAME + "#getApplicationId()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.applicationId);
        }

        return this.applicationId;
    }

    public final ControlType getControlType()
    {
        final String methodName = AccountControlRequest.CNAME + "#getControlType()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.controlType);
        }

        return this.controlType;
    }

    public final ModificationType getModType()
    {
        final String methodName = AccountControlRequest.CNAME + "#getControlType()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.modType);
        }

        return this.modType;
    }

    public final SearchRequestType getSearchType()
    {
        final String methodName = AccountControlRequest.CNAME + "#getSearchType()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.searchType);
        }

        return this.searchType;
    }

    public final UserAccount getRequestor()
    {
        final String methodName = AccountControlRequest.CNAME + "#getRequestor()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.requestor);
        }

        return this.requestor;
    }

    public final boolean isReset()
    {
        final String methodName = AccountControlRequest.CNAME + "#isReset()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.isReset);
        }

        return this.isReset;
    }

    public final boolean isLoginRequest()
    {
        final String methodName = AccountControlRequest.CNAME + "#isLoginRequest()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.isLoginRequest);
        }

        return this.isLoginRequest;
    }

    public final String getServiceId()
    {
        final String methodName = AccountControlRequest.CNAME + "#getServiceId()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.serviceId);
        }

        return this.serviceId;
    }

    public final List<String> getServicesList()
    {
        final String methodName = AccountControlRequest.CNAME + "#getServicesList()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.servicesList);
        }

        return this.servicesList;
    }

    public final String getProjectId()
    {
        final String methodName = AccountControlRequest.CNAME + "#getProjectId()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.projectId);
        }

        return this.projectId;
    }

    public final int getStartPage()
    {
        final String methodName = AccountControlRequest.CNAME + "#getStartPage()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.startPage);
        }

        return this.startPage;
    }

    @Override
    public final String toString()
    {
        final String methodName = AccountControlRequest.CNAME + "#toString()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        StringBuilder sBuilder = new StringBuilder()
            .append("[" + this.getClass().getName() + "]" + SecurityServiceConstants.LINE_BREAK + "{" + SecurityServiceConstants.LINE_BREAK);

        for (Field field : this.getClass().getDeclaredFields())
        {
            if (DEBUG)
            {
                DEBUGGER.debug("field: {}", field);
            }

            if (!(field.getName().equals("methodName")) &&
                    (!(field.getName().equals("CNAME"))) &&
                    (!(field.getName().equals("DEBUGGER"))) &&
                    (!(field.getName().equals("DEBUG"))) &&
                    (!(field.getName().equals("ERROR_RECORDER"))) &&
                    (!(field.getName().equals("userSecurity"))) &&
                    (!(field.getName().equals("serialVersionUID"))))
            {
                try
                {
                    if (field.get(this) != null)
                    {
                        sBuilder.append("\t" + field.getName() + " --> " + field.get(this) + SecurityServiceConstants.LINE_BREAK);
                    }
                }
                catch (IllegalAccessException iax)
                {
                    ERROR_RECORDER.error(iax.getMessage(), iax);
                }
            }
        }

        sBuilder.append('}');

        if (DEBUG)
        {
            DEBUGGER.debug("sBuilder: {}", sBuilder);
        }

        return sBuilder.toString();
    }
}