/**
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
package com.cws.esolutions.core.processors.dto;

import java.util.List;
import org.slf4j.Logger;
import java.io.Serializable;
import org.slf4j.LoggerFactory;
import java.lang.reflect.Field;

import com.cws.esolutions.core.Constants;
import com.cws.esolutions.core.processors.enums.CoreServicesStatus;
/**
 * eSolutionsCore
 * com.cws.esolutions.core.processors.dto
 * DatacenterManagementResponse.java
 *
 * $Id: $
 * $Author: $
 * $Date: $
 * $Revision: $
 * @author kmhuntly@gmail.com
 * @version 1.0
 *
 * History
 * ----------------------------------------------------------------------------
 * kh05451 @ Oct 29, 2012 9:44:46 AM
 *     Created.
 */
public class DatacenterManagementResponse implements Serializable
{
    private String response = null;
    private DataCenter dataCenter = null;
    private List<DataCenter> datacenterList = null;
    private CoreServicesStatus requestStatus = null;

    private static final long serialVersionUID = -9183689118275739366L;
    private static final String CNAME = DatacenterManagementResponse.class.getName();

    private static final Logger DEBUGGER = LoggerFactory.getLogger(Constants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();

    public final void setRequestStatus(final CoreServicesStatus value)
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#setRequestStatus(final CoreServicesStatus value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.requestStatus = value;
    }

    public final void setResponse(final String value)
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#setResponse(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.response = value;
    }

    public final void setDataCenter(final DataCenter value)
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#setDataCenter(final DataCenter value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.dataCenter = value;
    }

    public final void setDatacenterList(final List<DataCenter> value)
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#setDatacenterList(final List<DataCenter> value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.datacenterList = value;
    }

    public final CoreServicesStatus getRequestStatus()
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#getRequestStatus()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.requestStatus);
        }

        return this.requestStatus;
    }

    public final String getResponse()
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#getResponse()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.response);
        }

        return this.response;
    }

    public final DataCenter getDataCenter()
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#getDataCenter()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.dataCenter);
        }

        return this.dataCenter;
    }

    public final List<DataCenter> getDatacenterList()
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#getDatacenterList()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.datacenterList);
        }

        return this.datacenterList;
    }

    @Override
    public final String toString()
    {
        final String methodName = DatacenterManagementResponse.CNAME + "#toString()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        StringBuilder sBuilder = new StringBuilder()
            .append("[" + this.getClass().getName() + "]" + Constants.LINE_BREAK + "{" + Constants.LINE_BREAK);

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
                    (!(field.getName().equals("serialVersionUID"))))
            {
                try
                {
                    if (field.get(this) != null)
                    {
                        sBuilder.append("\t" + field.getName() + " --> " + field.get(this) + Constants.LINE_BREAK);
                    }
                }
                catch (IllegalAccessException iax)
                {
                    // don't do anything with it
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