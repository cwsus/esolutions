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
package com.cws.esolutions.security.dao.userauth.interfaces;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.dao.userauth.interfaces
 * File: Authenticator.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.cws.esolutions.security.config.xml.AuthData;
import com.cws.esolutions.security.SecurityServiceBean;
import com.cws.esolutions.security.SecurityServiceConstants;
import com.cws.esolutions.security.config.xml.SecurityConfig;
import com.cws.esolutions.security.dao.userauth.exception.AuthenticatorException;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author khuntly
 * @version 1.0
 */
public interface Authenticator
{
    static final SecurityServiceBean svcBean = SecurityServiceBean.getInstance();
    static final AuthData authData = svcBean.getConfigData().getAuthData();
    static final SecurityConfig secConfig = svcBean.getConfigData().getSecurityConfig();

    static final Logger DEBUGGER = LoggerFactory.getLogger(SecurityServiceConstants.DEBUGGER);
    static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    static final Logger ERROR_RECORDER = LoggerFactory.getLogger(SecurityServiceConstants.ERROR_LOGGER + Authenticator.class.getName());

    /**
     * Processes an agent logon request via an LDAP user datastore. If the
     * information provided matches an existing record, the user is
     * considered authenticated successfully and further processing
     * is performed to determine if that user is required to modify
     * their password or setup online reset questions. If yes, the
     * necessary flags are sent back to the frontend for further
     * handling.
     *
     * @param username
     * @param password
     * @return List<Object>
     * @throws AuthenticatorException
     */
    List<Object> performLogon(final String username, final String password) throws AuthenticatorException;

    List<String> obtainSecurityData(final String username, final String guid) throws AuthenticatorException;

    String obtainOtpSecret(final String userId, final String userGuid) throws AuthenticatorException;

    /**
     * Processes authentication for the selected security question and user. If successful,
     * a true response is returned back to the frontend signalling that further
     * authentication processing, if required, can take place.
     *
     * @param request
     * @return boolean
     * @throws AuthenticatorException
     */
    boolean verifySecurityData(final String uid, final String guid, final List<String> attributes) throws AuthenticatorException;
}
