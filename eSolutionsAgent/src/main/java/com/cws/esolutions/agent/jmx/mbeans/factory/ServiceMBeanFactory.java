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
package com.cws.esolutions.agent.jmx.mbeans.factory;
/*
 * Project: eSolutionsAgent
 * Package: com.cws.esolutions.agent.jmx.mbeans.factory
 * File: ServiceMBeanFactory.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.cws.esolutions.agent.Constants;
import com.cws.esolutions.agent.jmx.mbeans.interfaces.ServiceMBean;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author khuntly
 * @version 1.0
 */
public class ServiceMBeanFactory
{
    private static final Logger DEBUGGER = LoggerFactory.getLogger(Constants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(Constants.ERROR_LOGGER);

    private static final String CNAME = ServiceMBeanFactory.class.getName();

    public static final ServiceMBean createServiceMBean(final String className)
    {
        final String methodName = ServiceMBeanFactory.CNAME + "#createConnector()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        ServiceMBean service = null;

        try
        {
            service = (ServiceMBean) Class.forName(className).newInstance();
        }
        catch (InstantiationException ix)
        {
            ERROR_RECORDER.error(ix.getMessage(), ix);
        }
        catch (IllegalAccessException iax)
        {
            ERROR_RECORDER.error(iax.getMessage(), iax);
        }
        catch (ClassNotFoundException cnx)
        {
            ERROR_RECORDER.error(cnx.getMessage(), cnx);
        }

        return service;
    }
}
