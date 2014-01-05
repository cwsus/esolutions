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
package com.cws.esolutions.security.dao.keymgmt.exception;
/*
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.security.keymgmt.exception
 * File: KeyManagementException.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import com.cws.esolutions.security.exception.SecurityServiceException;
/**
 * @see com.cws.esolutions.security.exception.SecurityServiceException
 */
public class KeyManagementException extends SecurityServiceException
{
    private static final long serialVersionUID = -6006500480862957327L;

    public KeyManagementException(final String message)
    {
        super(message);
    }

    public KeyManagementException(final Throwable throwable)
    {
        super(throwable);
    }

    public KeyManagementException(final String message, final Throwable throwable)
    {
        super(message, throwable);
    }
}