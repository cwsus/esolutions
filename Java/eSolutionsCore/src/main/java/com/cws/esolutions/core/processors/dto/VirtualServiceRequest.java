/*
 * Copyright (c) 2009 - 2014 CaspersBox Web Services
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
package com.cws.esolutions.core.processors.dto;
/*
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.core.processors.dto
 * File: VirtualServiceResponse.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import org.slf4j.Logger;
import java.io.Serializable;
import java.lang.reflect.Field;
import org.slf4j.LoggerFactory;

import com.cws.esolutions.security.dto.UserAccount;
import com.cws.esolutions.core.CoreServiceConstants;
import com.cws.esolutions.core.processors.dto.Server;
import com.cws.esolutions.security.processors.dto.RequestHostInfo;
import com.cws.esolutions.security.processors.dto.AuthenticationData;
/**
 * @author khuntly
 * @version 1.0
 * @see java.io.Serializable
 */
public class VirtualServiceRequest implements Serializable
{
    private Server server = null;
    private UserAccount userAccount = null;
    private UserAccount virtualOwner = null;
    private RequestHostInfo requestInfo = null;
    private VirtualServer virtualServer = null;
    private AuthenticationData userSecurity = null;

    private static final long serialVersionUID = -2457741523065460449L;
    private static final String CNAME = VirtualServiceRequest.class.getName();

    private static final Logger DEBUGGER = LoggerFactory.getLogger(CoreServiceConstants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(CoreServiceConstants.ERROR_LOGGER);

    public final void setUserAccount(final UserAccount value)
    {
        final String methodName = VirtualServiceRequest.CNAME + "#setUserAccount(final UserAccount value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.userAccount = value;
    }

    public final void setRequestInfo(final RequestHostInfo value)
    {
        final String methodName = VirtualServiceRequest.CNAME + "#setRequestInfo(final RequestHostInfo value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.requestInfo = value;
    }

    public final void setServer(final Server value)
    {
        final String methodName = VirtualServiceRequest.CNAME + "#setServer(final Server value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.server = value;
    }

    public final void setVirtualServer(final VirtualServer value)
    {
        final String methodName = VirtualServiceRequest.CNAME + "#setVirtualServer(final VirtualServer value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.virtualServer = value;
    }

    public final void setVirtualOwner(final UserAccount value)
    {
        final String methodName = VirtualServiceRequest.CNAME + "#setVirtualOwner(final UserAccount value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.virtualOwner = value;
    }

    public final void setUserSecurity(final AuthenticationData value)
    {
        final String methodName = VirtualServiceRequest.CNAME + "#setUserSecurity(final AuthenticationData value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.userSecurity = value;
    }

    public final UserAccount getUserAccount()
    {
        final String methodName = VirtualServiceRequest.CNAME + "#getUserAccount()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.userAccount);
        }

        return this.userAccount;
    }

    public final RequestHostInfo getRequestInfo()
    {
        final String methodName = VirtualServiceRequest.CNAME + "#getRequestInfo()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.requestInfo);
        }

        return this.requestInfo;
    }

    public final Server getServer()
    {
        final String methodName = VirtualServiceRequest.CNAME + "#getServer()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.server);
        }

        return this.server;
    }

    public final VirtualServer getVirtualServer()
    {
        final String methodName = VirtualServiceRequest.CNAME + "#getVirtualServer()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.virtualServer);
        }

        return this.virtualServer;
    }

    public final UserAccount getVirtualOwner()
    {
        final String methodName = VirtualServiceRequest.CNAME + "#getVirtualOwner()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.virtualOwner);
        }

        return this.virtualOwner;
    }

    public final AuthenticationData getUserSecurity()
    {
        final String methodName = VirtualServiceRequest.CNAME + "#getUserSecurity()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.userSecurity);
        }

        return this.userSecurity;
    }

    @Override
    public final String toString()
    {
        final String methodName = VirtualServiceRequest.CNAME + "#toString()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        StringBuilder sBuilder = new StringBuilder()
            .append("[" + this.getClass().getName() + "]" + CoreServiceConstants.LINE_BREAK + "{" + CoreServiceConstants.LINE_BREAK);

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
                    (!(field.getName().equals("serialVersionUID"))))
            {
                try
                {
                    if (field.get(this) != null)
                    {
                        sBuilder.append("\t" + field.getName() + " --> " + field.get(this) + CoreServiceConstants.LINE_BREAK);
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