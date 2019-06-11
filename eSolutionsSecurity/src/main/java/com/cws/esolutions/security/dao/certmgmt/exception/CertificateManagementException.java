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
package com.cws.esolutions.security.dao.certmgmt.exception;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.keymgmt.exception
 * File: KeyManagementException.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly   11/23/2008 22:39:20             Created.
 */
import com.cws.esolutions.security.exception.SecurityServiceException;
/**
 * @see com.cws.esolutions.security.exception.SecurityServiceException
 */
public class CertificateManagementException extends SecurityServiceException
{
    private static final long serialVersionUID = -6006500480862957327L;

    /**
     * @param message - The thrown exception message
     * @see com.cws.esolutions.security.exception.SecurityServiceException#SecurityServiceException(java.lang.String)
     */
    public CertificateManagementException(final String message)
    {
        super(message);
    }

    /**
     * @param throwable - The thrown exception
     * @see com.cws.esolutions.security.exception.SecurityServiceException#SecurityServiceException(java.lang.Throwable)
     */
    public CertificateManagementException(final Throwable throwable)
    {
        super(throwable);
    }

    /**
     * @param message - The thrown exception message
     * @param throwable - The thrown exception
     * @see com.cws.esolutions.security.exception.SecurityServiceException#SecurityServiceException(java.lang.String, java.lang.Throwable)
     */
    public CertificateManagementException(final String message, final Throwable throwable)
    {
        super(message, throwable);
    }
}