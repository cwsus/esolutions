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
package com.cws.esolutions.core.processors.exception;

import com.cws.esolutions.core.exception.CoreServiceException;
/**
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.core.processors.exception
 * File: DatacenterManagementException.java
 *
 * $Id: $
 * $Author: $
 * $Date: $
 * $Revision: $
 * @author 35033355
 * @version 1.0
 *
 * History
 * ----------------------------------------------------------------------------
 * 35033355 @ Oct 22, 2013 12:24:26 PM
 *     Created.
 */
public class DatacenterManagementException extends CoreServiceException
{
    private static final long serialVersionUID = 4198039358441208613L;

    public DatacenterManagementException(final String message)
    {
        super(message);
    }

    public DatacenterManagementException(final Throwable throwable)
    {
        super(throwable);
    }

    public DatacenterManagementException(final String message, final Throwable throwable)
    {
        super(message, throwable);
    }
}