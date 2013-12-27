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
package com.cws.esolutions.security.dao.userauth.impl;
/*
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.security.dao.userauth.impl
 * File: LDAPAuthenticator.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.List;
import java.util.Arrays;
import java.util.ArrayList;
import java.net.ConnectException;
import com.unboundid.ldap.sdk.Filter;
import com.unboundid.ldap.sdk.ResultCode;
import com.unboundid.ldap.sdk.LDAPResult;
import com.unboundid.ldap.sdk.BindResult;
import com.unboundid.ldap.sdk.BindRequest;
import com.unboundid.ldap.sdk.SearchScope;
import com.unboundid.ldap.sdk.SearchResult;
import com.unboundid.ldap.sdk.Modification;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.ModifyRequest;
import com.unboundid.ldap.sdk.SearchRequest;
import com.unboundid.ldap.sdk.LDAPConnection;
import com.unboundid.ldap.sdk.ModificationType;
import com.unboundid.ldap.sdk.SearchResultEntry;
import com.unboundid.ldap.sdk.SimpleBindRequest;
import com.unboundid.ldap.sdk.LDAPConnectionPool;

import com.cws.esolutions.security.dao.userauth.interfaces.Authenticator;
import com.cws.esolutions.security.dao.userauth.exception.AuthenticatorException;
/**
 * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator
 */
public class LDAPAuthenticator implements Authenticator
{
    private static final String CNAME = LDAPAuthenticator.class.getName();

    /**
     * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator#performLogon(java.lang.String, java.lang.String, java.lang.String)
     */
    @Override
    public synchronized List<Object> performLogon(final String guid, final String username, final String password) throws AuthenticatorException
    {
        final String methodName = LDAPAuthenticator.CNAME + "#performLogon(final String guid, final String username, final String password) throws AuthenticatorException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("String: {}", guid);
            DEBUGGER.debug("String: {}", username);
        }

        LDAPConnection ldapConn = null;
        List<Object> userAccount = null;
        LDAPConnectionPool ldapPool = null;

        try
        {
            ldapPool = (LDAPConnectionPool) resBean.getAuthDataSource();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnectionPool: {}", ldapPool);
            }

            if (!(ldapPool.isClosed()))
            {
                ldapConn = ldapPool.getConnection();

                if (DEBUG)
                {
                    DEBUGGER.debug("LDAPConnection: {}", ldapConn);
                }

                if (ldapConn.isConnected())
                {
                    Filter searchFilter = Filter.create("(&(objectClass=" + authData.getObjectClass() + ")" +
                            "(&(" + authData.getCommonName() + "=" + guid + "))" +
                            "(&(" + authData.getUserId() + "=" + username+ ")))");

                    if (DEBUG)
                    {
                        DEBUGGER.debug("SearchFilter: {}", searchFilter);
                    }

                    SearchRequest searchRequest = new SearchRequest(
                            authRepo.getRepositoryUserBase(),
                            SearchScope.SUB,
                            searchFilter,
                            authData.getCommonName(),
                            authData.getUserId(),
                            authData.getGivenName(),
                            authData.getSurname(),
                            authData.getDisplayName(),
                            authData.getEmailAddr(),
                            authData.getPagerNumber(),
                            authData.getTelephoneNumber(),
                            authData.getUserRole(),
                            authData.getLockCount(),
                            authData.getLastLogin(),
                            authData.getExpiryDate(),
                            authData.getIsSuspended(),
                            authData.getOlrSetupReq(),
                            authData.getOlrLocked(),
                            authData.getTcAccepted(),
                            authData.getUserType());

                    if (DEBUG)
                    {
                        DEBUGGER.debug("SearchRequest: {}", searchRequest);
                    }

                    SearchResult searchResult = ldapConn.search(searchRequest);

                    if (DEBUG)
                    {
                        DEBUGGER.debug("searchResult: {}", searchResult);
                    }

                    if ((searchResult.getResultCode() == ResultCode.SUCCESS) && (searchResult.getEntryCount() == 1))
                    {
                        SearchResultEntry entry = searchResult.getSearchEntries().get(0);

                        if (DEBUG)
                        {
                            DEBUGGER.debug("SearchResultEntry: {}", entry);
                        }

                        BindRequest bindRequest = new SimpleBindRequest(entry.getDN(), password);

                        if (DEBUG)
                        {
                            DEBUGGER.debug("BindRequest: {}", bindRequest);
                        }

                        BindResult bindResult = ldapConn.bind(bindRequest);

                        if (DEBUG)
                        {
                            DEBUGGER.debug("BindResult: {}", bindResult);
                        }

                        userAccount = new ArrayList<>();
                        userAccount.add(entry.getAttributeValue(authData.getCommonName()));
                        userAccount.add(entry.getAttributeValue(authData.getUserId()));
                        userAccount.add(entry.getAttributeValue(authData.getGivenName()));
                        userAccount.add(entry.getAttributeValue(authData.getSurname()));
                        userAccount.add(entry.getAttributeValue(authData.getDisplayName()));
                        userAccount.add(entry.getAttributeValue(authData.getEmailAddr()));
                        userAccount.add(entry.getAttributeValue(authData.getPagerNumber()));
                        userAccount.add(entry.getAttributeValue(authData.getTelephoneNumber()));
                        userAccount.add(entry.getAttributeValue(authData.getUserRole()).toUpperCase());
                        userAccount.add(entry.getAttributeValueAsInteger(authData.getLockCount()));
                        userAccount.add(entry.getAttributeValueAsLong(authData.getLastLogin()));
                        userAccount.add(entry.getAttributeValueAsLong(authData.getExpiryDate()));
                        userAccount.add(entry.getAttributeValueAsBoolean(authData.getIsSuspended()));
                        userAccount.add(entry.getAttributeValueAsBoolean(authData.getOlrSetupReq()));
                        userAccount.add(entry.getAttributeValueAsBoolean(authData.getOlrLocked()));
                        userAccount.add(entry.getAttributeValueAsBoolean(authData.getTcAccepted()));
                        userAccount.add(entry.getAttributeValue(authData.getUserType()).toUpperCase());

                        if (DEBUG)
                        {
                            DEBUGGER.debug("UserAccount: {}", userAccount);
                        }
                    }
                    else
                    {
                        throw new AuthenticatorException("No user was found for the provided user information");
                    }
                }
                else
                {
                    throw new ConnectException("Failed to create LDAP connection using the specified information");
                }
            }
            else
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }
        }
        catch (LDAPException lx)
        {
            ERROR_RECORDER.error(lx.getMessage(), lx);

            throw new AuthenticatorException(lx.getResultCode(), lx.getMessage(), lx);
        }
        catch (ConnectException cx)
        {
            ERROR_RECORDER.error(cx.getMessage(), cx);

            throw new AuthenticatorException(cx.getMessage(), cx);
        }
        finally
        {
            if ((ldapPool != null) && ((ldapConn != null) && (ldapConn.isConnected())))
            {
                ldapPool.releaseConnection(ldapConn);
            }
        }

        return userAccount;
    }

    /**
     * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator#lockUserAccount(java.lang.String, int)
     */
    @Override
    public synchronized void lockUserAccount(final String userGuid, final int currentCount) throws AuthenticatorException
    {
        final String methodName = LDAPAuthenticator.CNAME + "#lockUserAccount(final String userGuid, final int currentCount) throws AuthenticatorException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("userId: {}", userGuid);
            DEBUGGER.debug("currentCount: {}", currentCount);
        }

        LDAPConnection ldapConn = null;
        LDAPConnectionPool ldapPool = null;

        try
        {
            ldapPool = (LDAPConnectionPool) resBean.getAuthDataSource();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnectionPool: {}", ldapPool);
            }

            if (!(ldapPool.isClosed()))
            {
                ldapConn = ldapPool.getConnection();

                if (DEBUG)
                {
                    DEBUGGER.debug("LDAPConnection: {}", ldapConn);
                }

                if (ldapConn.isConnected())
                {
                    Filter searchFilter = Filter.create("(&(objectClass=" + authData.getObjectClass() + ")" +
                            "(&(" + authData.getCommonName() + "=" + userGuid + ")))");

                    if (DEBUG)
                    {
                        DEBUGGER.debug("SearchFilter: {}", searchFilter);
                    }

                    SearchRequest searchRequest = new SearchRequest(
                            authRepo.getRepositoryUserBase(),
                            SearchScope.SUB,
                            searchFilter,
                            authData.getLockCount());

                    if (DEBUG)
                    {
                        DEBUGGER.debug("SearchRequest: {}", searchRequest);
                    }

                    SearchResult searchResult = ldapConn.search(searchRequest);

                    if (DEBUG)
                    {
                        DEBUGGER.debug("searchResult: {}", searchResult);
                    }

                    if ((searchResult.getResultCode() == ResultCode.SUCCESS) && (searchResult.getEntryCount() == 1))
                    {
                        SearchResultEntry entry = searchResult.getSearchEntries().get(0);

                        if (DEBUG)
                        {
                            DEBUGGER.debug("SearchResultEntry: {}", entry);
                        }

                        List<Modification> modifyList = new ArrayList<>(
                                Arrays.asList(
                                        new Modification(ModificationType.REPLACE, authData.getLockCount(), String.valueOf(currentCount + 1))));

                        if (DEBUG)
                        {
                            DEBUGGER.debug("modifyList: {}", modifyList);
                        }

                        LDAPResult ldapResult = ldapConn.modify(new ModifyRequest(entry.getDN(), modifyList));

                        if (DEBUG)
                        {
                            DEBUGGER.debug("LDAPResult: {}", ldapResult);
                        }

                        if (ldapResult.getResultCode() != ResultCode.SUCCESS)
                        {
                            ERROR_RECORDER.error("Failed to increment user lock count.");
                        }
                    }
                }
                else
                {
                    throw new ConnectException("Failed to create LDAP connection using the specified information");
                }
            }
            else
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }
        }
        catch (LDAPException lx)
        {
            ERROR_RECORDER.error(lx.getMessage(), lx);

            throw new AuthenticatorException(lx.getMessage(), lx);
        }
        catch (ConnectException cx)
        {
            ERROR_RECORDER.error(cx.getMessage(), cx);

            throw new AuthenticatorException(cx.getMessage(), cx);
        }
        finally
        {
            if ((ldapPool != null) && (!(ldapPool.isClosed())))
            {
                ldapPool.releaseConnection(ldapConn);
            }
        }
    }

    /**
     * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator#obtainSecurityData(java.lang.String, java.lang.String)
     */
    @Override
    public synchronized List<String> obtainSecurityData(final String userId, final String userGuid) throws AuthenticatorException
    {
        final String methodName = LDAPAuthenticator.CNAME + "#obtainSecurityData(final String userId, final String userGuid) throws AuthenticatorException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("User ID: {}", userId);
            DEBUGGER.debug("User GUID: {}", userGuid);
        }

        LDAPConnection ldapConn = null;
        List<String> userSecurity = null;
        LDAPConnectionPool ldapPool = null;

        try
        {
            ldapPool = (LDAPConnectionPool) resBean.getAuthDataSource();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnectionPool: {}", ldapPool);
            }

            if (!(ldapPool.isClosed()))
            {
                ldapConn = ldapPool.getConnection();

                if (DEBUG)
                {
                    DEBUGGER.debug("LDAPConnection: {}", ldapConn);
                }

                if (ldapConn.isConnected())
                {
                    Filter searchFilter = Filter.create("(&(objectClass=inetOrgPerson)" +
                            "(&(" + authData.getUserId() + "=" + userId + "))" +
                            "(&(" + authData.getCommonName() + "=" + userGuid + ")))");

                    if (DEBUG)
                    {
                        DEBUGGER.debug("searchFilter: {}", searchFilter);
                    }

                    SearchRequest searchRequest = new SearchRequest(
						    authRepo.getRepositoryUserBase(),
                            SearchScope.SUB,
                            searchFilter,
                            authData.getUserId(),
                            authData.getCommonName(),
                            authData.getSecQuestionOne(),
                            authData.getSecQuestionTwo(),
                            authData.getSecAnswerOne(),
                            authData.getSecAnswerTwo());

                    if (DEBUG)
                    {
                        DEBUGGER.debug("searchRequest: {}", searchRequest);
                    }

                    SearchResult searchResult = ldapConn.search(searchRequest);

                    if (searchResult.getResultCode() == ResultCode.SUCCESS)
                    {
                        if (searchResult.getSearchEntries().size() == 1)
                        {
                            SearchResultEntry entry = searchResult.getSearchEntries().get(0);

                            // ensure the user exists in the requested application
                            // i think we shouldnt necessarily require it but whatever
                            userSecurity = new ArrayList<>();
                            userSecurity.add(entry.getAttributeValue(authData.getSecQuestionOne()));
                            userSecurity.add(entry.getAttributeValue(authData.getSecQuestionTwo()));
                            userSecurity.add(entry.getAttributeValue(authData.getSecAnswerOne()));
                            userSecurity.add(entry.getAttributeValue(authData.getSecAnswerTwo()));
                        }
                        else
                        {
                            throw new AuthenticatorException("No user was found for the provided user information");
                        }
                    }
                    else
                    {
                        throw new LDAPException(searchResult.getResultCode(), "Result code from search request was NOT successful: " + searchResult.getResultCode());
                    }
                }
                else
                {
                    throw new ConnectException("Failed to create LDAP connection using the specified information");
                }
            }
            else
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }
        }
        catch (LDAPException lx)
        {
            ERROR_RECORDER.error(lx.getMessage(), lx);

            throw new AuthenticatorException(lx.getMessage(), lx);
        }
        catch (ConnectException cx)
        {
            ERROR_RECORDER.error(cx.getMessage(), cx);

            throw new AuthenticatorException(cx.getMessage(), cx);
        }
        finally
        {
            if ((ldapPool != null) && ((ldapConn != null) && (ldapConn.isConnected())))
            {
                ldapPool.releaseConnection(ldapConn);
            }
        }

        return userSecurity;
    }

    /**
     * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator#verifySecurityData(java.util.List)
     */
    @Override
    public synchronized boolean verifySecurityData(final List<String> request) throws AuthenticatorException
    {
        final String methodName = LDAPAuthenticator.CNAME + "#verifySecurityData(final List<String> request) throws AuthenticatorException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        boolean isAuthorized = false;
        LDAPConnection ldapConn = null;
        LDAPConnectionPool ldapPool = null;

        try
        {
            ldapPool = (LDAPConnectionPool) resBean.getAuthDataSource();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnectionPool: {}", ldapPool);
            }

            if (!(ldapPool.isClosed()))
            {
                ldapConn = ldapPool.getConnection();

                if (DEBUG)
                {
                    DEBUGGER.debug("LDAPConnection: {}", ldapConn);
                }

                if (ldapConn.isConnected())
                {
                    // validate the question
                    Filter searchFilter = Filter.create("(&(objectClass=inetOrgPerson)" +
                            "(&(" + authData.getCommonName() + "=" + request.get(0) + "))" +
                            "(&(" + authData.getUserId() + "=" + request.get(1) + "))" +
                            "(&(" + authData.getSecAnswerOne() + "=" + request.get(2) + "))" +
                            "(&(" + authData.getSecAnswerTwo() + "=" + request.get(3) + ")))");

                    SearchRequest searchReq = new SearchRequest(
						    authRepo.getRepositoryUserBase(),
                            SearchScope.SUB,
                            searchFilter,
                            authData.getCommonName());

                    if (DEBUG)
                    {
                        DEBUGGER.debug("SearchRequest: {}", searchReq);
                    }

                    SearchResult searchResult = ldapConn.search(searchReq);

                    if (DEBUG)
                    {
                        DEBUGGER.debug("searchResult: {}", searchResult);
                    }

                    isAuthorized = ((searchResult.getResultCode() == ResultCode.SUCCESS) && (searchResult.getSearchEntries().size() == 1));

                    if (DEBUG)
                    {
                        DEBUGGER.debug("isAuthorized: {}", isAuthorized);
                    }
                }
                else
                {
                    throw new ConnectException("Failed to create LDAP connection using the specified information");
                }
            }
            else
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }
        }
        catch (LDAPException lx)
        {
            ERROR_RECORDER.error(lx.getMessage(), lx);

            throw new AuthenticatorException(lx.getMessage(), lx);
        }
        catch (ConnectException cx)
        {
            ERROR_RECORDER.error(cx.getMessage(), cx);

            throw new AuthenticatorException(cx.getMessage(), cx);
        }
        finally
        {
            if ((ldapPool != null) && (!(ldapPool.isClosed())))
            {
                ldapPool.releaseConnection(ldapConn);
            }
        }

        return isAuthorized;
    }
}
