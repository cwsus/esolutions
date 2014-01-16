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
 * Project: eSolutionsSecurity
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
import java.util.ArrayList;
import java.net.ConnectException;
import com.unboundid.ldap.sdk.Filter;
import com.unboundid.ldap.sdk.ResultCode;
import com.unboundid.ldap.sdk.BindResult;
import com.unboundid.ldap.sdk.BindRequest;
import com.unboundid.ldap.sdk.SearchScope;
import com.unboundid.ldap.sdk.SearchResult;
import com.unboundid.ldap.sdk.LDAPException;
import com.unboundid.ldap.sdk.SearchRequest;
import com.unboundid.ldap.sdk.LDAPConnection;
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
    public synchronized List<Object> performLogon(final String username, final String password) throws AuthenticatorException
    {
        final String methodName = LDAPAuthenticator.CNAME + "#performLogon(final String username, final String password) throws AuthenticatorException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("String: {}", username);
        }

        LDAPConnection ldapConn = null;
        LDAPConnectionPool ldapPool = null;
        List<Object> userAccount = new ArrayList<Object>();

        try
        {
            ldapPool = (LDAPConnectionPool) svcBean.getAuthDataSource();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnectionPool: {}", ldapPool);
            }

            if (ldapPool.isClosed())
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }

            ldapConn = ldapPool.getConnection();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnection: {}", ldapConn);
            }

            if (!(ldapConn.isConnected()))
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }

            Filter searchFilter = Filter.create("(&(objectClass=" + authData.getObjectClass() + ")" +
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
                authData.getLockCount(),
                authData.getLastLogin(),
                authData.getExpiryDate(),
                authData.getIsSuspended(),
                authData.getOlrSetupReq(),
                authData.getOlrLocked());

            if (DEBUG)
            {
                DEBUGGER.debug("SearchRequest: {}", searchRequest);
            }

            SearchResult searchResult = ldapConn.search(searchRequest);

            if (DEBUG)
            {
                DEBUGGER.debug("searchResult: {}", searchResult);
            }

            if ((searchResult.getResultCode() != ResultCode.SUCCESS) || (searchResult.getEntryCount() != 1))
            {
                throw new AuthenticatorException("No user was found for the provided user information");
            }

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

            userAccount.add(entry.getDN());
            userAccount.add(entry.getAttributeValue(authData.getCommonName()));
            userAccount.add(entry.getAttributeValue(authData.getUserId()));
            userAccount.add(entry.getAttributeValue(authData.getGivenName()));
            userAccount.add(entry.getAttributeValue(authData.getSurname()));
            userAccount.add(entry.getAttributeValue(authData.getDisplayName()));
            userAccount.add(entry.getAttributeValue(authData.getEmailAddr()));
            userAccount.add(entry.getAttributeValue(authData.getPagerNumber()));
            userAccount.add(entry.getAttributeValue(authData.getTelephoneNumber()));
            userAccount.add(entry.getAttributeValueAsInteger(authData.getLockCount()));
            userAccount.add(entry.getAttributeValueAsLong(authData.getLastLogin()));
            userAccount.add(entry.getAttributeValueAsLong(authData.getExpiryDate()));
            userAccount.add(entry.getAttributeValueAsBoolean(authData.getIsSuspended()));
            userAccount.add(entry.getAttributeValueAsBoolean(authData.getOlrSetupReq()));
            userAccount.add(entry.getAttributeValueAsBoolean(authData.getOlrLocked()));

            Filter roleFilter = Filter.create("(&(objectClass=groupOfUniqueNames)" +
                    "(&(uniqueMember=" + entry.getDN() + ")))");

            if (DEBUG)
            {
                DEBUGGER.debug("SearchFilter: {}", roleFilter);
            }

            SearchRequest roleSearch = new SearchRequest(
                authRepo.getRepositoryRoleBase(),
                SearchScope.SUB,
                roleFilter,
                "cn");

            if (DEBUG)
            {
                DEBUGGER.debug("SearchRequest: {}", roleSearch);
            }

            SearchResult roleResult = ldapConn.search(roleSearch);

            if (DEBUG)
            {
                DEBUGGER.debug("searchResult: {}", roleResult);
            }

            if ((roleResult.getResultCode() == ResultCode.SUCCESS) && (roleResult.getEntryCount() != 0))
            {
                List<String> roles = new ArrayList<>();

                for (SearchResultEntry role : roleResult.getSearchEntries())
                {
                    if (DEBUG)
                    {
                        DEBUGGER.debug("SearchResultEntry: {}", role);
                    }

                    roles.add(role.getAttributeValue("cn"));
                }

                userAccount.add(roles);
            }

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", userAccount);
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
            ldapPool = (LDAPConnectionPool) svcBean.getAuthDataSource();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnectionPool: {}", ldapPool);
            }

            if (ldapPool.isClosed())
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }

            ldapConn = ldapPool.getConnection();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnection: {}", ldapConn);
            }

            if (!(ldapConn.isConnected()))
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }

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

            if ((searchResult.getResultCode() != ResultCode.SUCCESS) || (searchResult.getSearchEntries().size() != 1))
            {
                throw new AuthenticatorException("No user was found for the provided user information");
            }

            SearchResultEntry entry = searchResult.getSearchEntries().get(0);

            userSecurity = new ArrayList<>();
            userSecurity.add(entry.getAttributeValue(authData.getSecQuestionOne()));
            userSecurity.add(entry.getAttributeValue(authData.getSecQuestionTwo()));
            userSecurity.add(entry.getAttributeValue(authData.getSecAnswerOne()));
            userSecurity.add(entry.getAttributeValue(authData.getSecAnswerTwo()));
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
            ldapPool = (LDAPConnectionPool) svcBean.getAuthDataSource();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnectionPool: {}", ldapPool);
            }

            if (ldapPool.isClosed())
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }

            ldapConn = ldapPool.getConnection();

            if (DEBUG)
            {
                DEBUGGER.debug("LDAPConnection: {}", ldapConn);
            }

            if (!(ldapConn.isConnected()))
            {
                throw new ConnectException("Failed to create LDAP connection using the specified information");
            }

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