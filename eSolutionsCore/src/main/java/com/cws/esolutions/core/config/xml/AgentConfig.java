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
package com.cws.esolutions.core.config.xml;
/*
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.core.config.xml
 * File: AgentConfig.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly          11/23/2008 22:39:20             Created.
 */
import org.slf4j.Logger;
import java.io.Serializable;
import java.lang.reflect.Field;
import org.slf4j.LoggerFactory;
import javax.xml.bind.annotation.XmlType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;

import com.cws.esolutions.core.CoreServicesConstants;
/**
 * @author cws-khuntly
 * @version 1.0
 * @see java.io.Serializable
 */
@XmlType(name = "agent-config")
@XmlAccessorType(XmlAccessType.NONE)
public final class AgentConfig implements Serializable
{
    private long timeout = 0;
    private String salt = null;
    private String username = null;
    private String password = null;
    private String clientId = null;
    private String requestQueue = null;
    private String responseQueue = null;
    private String connectionName = null;

    private static final String CNAME = AgentConfig.class.getName();
    private static final long serialVersionUID = 9144720470986353417L;

    private static final Logger DEBUGGER = LoggerFactory.getLogger(CoreServicesConstants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(CoreServicesConstants.ERROR_LOGGER);

    public final void setConnectionName(final String value)
    {
        final String methodName = AgentConfig.CNAME + "#setConnectionName(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }
        
        this.connectionName = value;
    }

    public final void setClientId(final String value)
    {
        final String methodName = AgentConfig.CNAME + "#setClientId(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }
        
        this.clientId = value;
    }

    public final void setRequestQueue(final String value)
    {
        final String methodName = AgentConfig.CNAME + "#setRequestQueue(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }
        
        this.requestQueue = value;
    }

    public final void setResponseQueue(final String value)
    {
        final String methodName = AgentConfig.CNAME + "#setResponseQueue(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }
        
        this.responseQueue = value;
    }

    public final void setUsername(final String value)
    {
        final String methodName = AgentConfig.CNAME + "#setUsername(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.username = value;
    }

    public final void setPassword(final String value)
    {
        final String methodName = AgentConfig.CNAME + "#setPassword(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        this.password = value;
    }

    public final void setSalt(final String value)
    {
        final String methodName = AgentConfig.CNAME + "#setSalt(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        this.salt = value;
    }

    public final void setTimeout(final long value)
    {
        final String methodName = AgentConfig.CNAME + "#setSalt(final long value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.timeout = value;
    }

    @XmlElement(name = "connectionName")
    public final String getConnectionName()
    {
        final String methodName = AgentConfig.CNAME + "#getConnectionName()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.connectionName);
        }

        return this.connectionName;
    }

    @XmlElement(name = "clientId")
    public final String getClientId()
    {
        final String methodName = AgentConfig.CNAME + "#getClientId()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.clientId);
        }

        return this.clientId;
    }

    @XmlElement(name = "requestQueue")
    public final String getRequestQueue()
    {
        final String methodName = AgentConfig.CNAME + "#getRequestQueue()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.requestQueue);
        }
        
        return this.requestQueue;
    }

    @XmlElement(name = "responseQueue")
    public final String getResponseQueue()
    {
        final String methodName = AgentConfig.CNAME + "#getResponseQueue()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.responseQueue);
        }
        
        return this.responseQueue;
    }

    @XmlElement(name = "username")
    public final String getUsername()
    {
        final String methodName = AgentConfig.CNAME + "#getUsername()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.username);
        }

        return this.username;
    }

    @XmlElement(name = "password")
    public final String getPassword()
    {
        final String methodName = AgentConfig.CNAME + "#getPassword()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        return this.password;
    }

    @XmlElement(name = "salt")
    public final String getSalt()
    {
        final String methodName = AgentConfig.CNAME + "#getSalt()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        return this.salt;
    }

    @XmlElement(name = "timeout")
    public final long getTimeout()
    {
        final String methodName = AgentConfig.CNAME + "#getTimeout()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.timeout);
        }

        return this.timeout;
    }

    @Override
    public final String toString()
    {
        final String methodName = AgentConfig.CNAME + "#toString()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        StringBuilder sBuilder = new StringBuilder()
            .append("[" + this.getClass().getName() + "]" + CoreServicesConstants.LINE_BREAK + "{" + CoreServicesConstants.LINE_BREAK);

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
                        sBuilder.append("\t" + field.getName() + " --> " + field.get(this) + CoreServicesConstants.LINE_BREAK);
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
