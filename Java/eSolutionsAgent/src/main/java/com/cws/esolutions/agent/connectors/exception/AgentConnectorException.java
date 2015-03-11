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
package com.cws.esolutions.agent.connectors.exception;
/*
 * Project: eSolutionsAgent
 * Package: com.cws.esolutions.agent.connectors.exception
 * File: AgentConnectorException.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import com.cws.esolutions.agent.exception.AgentException;
/**
 * @see com.cws.esolutions.agent.exception.AgentException
 */
public class AgentConnectorException extends AgentException
{
    private static final long serialVersionUID = -6855732173388405517L;

    /**
     * @see com.cws.esolutions.agent.exception.AgentException#CoreServiceException(java.lang.String)
     */
    public AgentConnectorException(final String message)
    {
        super(message);
    }

    /**
     * @see com.cws.esolutions.agent.exception.AgentException#CoreServiceException(java.lang.Throwable)
     */
    public AgentConnectorException(final Throwable throwable)
    {
        super(throwable);
    }

    /**
     * @see com.cws.esolutions.agent.exception.AgentException#CoreServiceException(java.lang.String, java.lang.Throwable)
     */
    public AgentConnectorException(final String message, final Throwable throwable)
    {
        super(message, throwable);
    }
}