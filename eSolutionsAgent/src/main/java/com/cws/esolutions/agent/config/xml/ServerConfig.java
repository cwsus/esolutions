/*
 * Copyright (c) 2009 - 2017 CaspersBox Web Services
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
package com.cws.esolutions.agent.config.xml;
/*
 * Project: eSolutionsAgent
 * Package: com.cws.esolutions.agent.config.xml
 * File: ServerConfig.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly   11/23/2008 22:39:20             Created.
 */
import org.slf4j.Logger;
import java.io.Serializable;
import java.lang.reflect.Field;
import org.slf4j.LoggerFactory;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlAccessorType;

import com.cws.esolutions.agent.AgentConstants;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author cws-khuntly
 * @version 1.0
 */
@XmlRootElement(name = "server-config")
@XmlAccessorType(XmlAccessType.NONE)
public final class ServerConfig implements Serializable
{
	private int keyBits = 256;
    private String salt = null;
    private int iterations = 65535; // default to 65535
    private String clientId = null;
    private int connectTimeout = 0;
    private String username = null;
    private String password = null;
    private String encoding = "UTF-8";
    private String requestQueue = null;
    private String responseQueue = null;
    private String connectionName = null;
    private String encryptionAlgorithm = "AES";
    private String secretAlgorithm = "PBKDF2WithHmacSHA512";
    private String encryptionInstance = "AES/CBC/PKCS5Padding";

    private static final String CNAME = ServerConfig.class.getName();
    private static final long serialVersionUID = 9144720470986353417L;

    private static final Logger DEBUGGER = LoggerFactory.getLogger(AgentConstants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(AgentConstants.ERROR_LOGGER);

    public final void setConnectionName(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setConnectionName(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }
        
        this.connectionName = value;
    }

    public final void setClientId(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setClientId(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }
        
        this.clientId = value;
    }

    public final void setConnectTimeout(final int value)
    {
        final String methodName = ServerConfig.CNAME + "#setConnectTimeout(final int value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.connectTimeout = value;
    }

    public final void setRequestQueue(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setRequestQueue(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }
        
        this.requestQueue = value;
    }

    public final void setResponseQueue(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setResponseQueue(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }
        
        this.responseQueue = value;
    }

    public final void setUsername(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setUsername(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.username = value;
    }

    public final void setPassword(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setPassword(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.password = value;
    }

    public final void setSalt(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setSalt(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.salt = value;
    }

    public final void setEncoding(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setEncoding(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.encoding = value;
    }

    public final void setEncryptionInstance(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setEncryptionInstance(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.encryptionInstance = value;
    }

    public final void setEncryptionAlgorithm(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setEncryptionAlgorithm(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.encryptionAlgorithm = value;
    }

    public final void setKeyBits(final int value)
    {
        final String methodName = ServerConfig.CNAME + "#setKeyBits(final int value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.keyBits = value;
    }

    public final void setIteratons(final int value)
    {
        final String methodName = ServerConfig.CNAME + "#setIterations(final int value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.iterations = value;
    }

    public final void setSecretAlgorithm(final String value)
    {
        final String methodName = ServerConfig.CNAME + "#setSecretAlgorithm(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.secretAlgorithm = value;
    }

    @XmlElement(name = "connectionName")
    public final String getConnectionName()
    {
        final String methodName = ServerConfig.CNAME + "#getConnectionName()";

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
        final String methodName = ServerConfig.CNAME + "#getClientId()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.clientId);
        }

        return this.clientId;
    }

    @XmlElement(name = "connectTimeout")
    public final int getConnectTimeout()
    {
        final String methodName = ServerConfig.CNAME + "#getConnectTimeout()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.connectTimeout);
        }

        return this.connectTimeout;
    }

    @XmlElement(name = "requestQueue")
    public final String getRequestQueue()
    {
        final String methodName = ServerConfig.CNAME + "#getRequestQueue()";

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
        final String methodName = ServerConfig.CNAME + "#getResponseQueue()";

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
        final String methodName = ServerConfig.CNAME + "#getUsername()";

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
        final String methodName = ServerConfig.CNAME + "#getPassword()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.password);
        }

        return this.password;
    }

    @XmlElement(name = "salt")
    public final String getSalt()
    {
        final String methodName = ServerConfig.CNAME + "#getSalt()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.salt);
        }

        return this.salt;
    }

    @XmlElement(name = "encoding")
    public final String getEncoding()
    {
        final String methodName = ServerConfig.CNAME + "#getEncoding()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.encoding);
        }

        return this.encoding;
    }

    @XmlElement(name = "encryptionAlgorithm")
    public final String getEncryptionAlgorithm()
    {
        final String methodName = ServerConfig.CNAME + "#getEncryptionAlgorithm()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.encryptionAlgorithm);
        }

        return this.encryptionAlgorithm;
    }

    @XmlElement(name = "encryptionInstance")
    public final String getEncryptionInstance()
    {
        final String methodName = ServerConfig.CNAME + "#getEncryptionInstance()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.encryptionInstance);
        }

        return this.encryptionInstance;
    }

    @XmlElement(name = "keyBits")
    public final int getKeyBits()
    {
        final String methodName = ServerConfig.CNAME + "#etKeyBits()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.keyBits);
        }

        return this.keyBits;
    }

    @XmlElement(name = "iterations")
    public final int getIterations()
    {
        final String methodName = ServerConfig.CNAME + "#getIterations()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.iterations);
        }

        return this.iterations;
    }

    @XmlElement(name = "secretAlgorithm")
    public final String getSecretAlgorithm()
    {
        final String methodName = ServerConfig.CNAME + "#getSecretAlgorithm()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.secretAlgorithm);
        }

        return this.secretAlgorithm;
    }

    @Override
    public final String toString()
    {
        final String methodName = ServerConfig.CNAME + "#toString()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        StringBuilder sBuilder = new StringBuilder()
            .append("[" + this.getClass().getName() + "]" + AgentConstants.LINE_BREAK + "{" + AgentConstants.LINE_BREAK);

        for (Field field : this.getClass().getDeclaredFields())
        {
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
                        sBuilder.append("\t" + field.getName() + " --> " + field.get(this) + AgentConstants.LINE_BREAK);
                    }
                }
                catch (IllegalAccessException iax)
                {
                    ERROR_RECORDER.error(iax.getMessage(), iax);
                }
            }
        }

        sBuilder.append('}');

        return sBuilder.toString();
    }
}