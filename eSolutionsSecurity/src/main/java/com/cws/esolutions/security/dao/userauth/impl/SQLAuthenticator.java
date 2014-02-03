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
package com.cws.esolutions.security.dao.userauth.impl;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.dao.userauth.impl
 * File: SQLAuthenticator.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.List;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.sql.Connection;
import javax.sql.DataSource;
import java.sql.SQLException;
import java.sql.CallableStatement;

import com.cws.esolutions.security.dao.userauth.interfaces.Authenticator;
import com.cws.esolutions.security.dao.userauth.exception.AuthenticatorException;
/**
 * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator
 */
public class SQLAuthenticator implements Authenticator
{
    private static final String CNAME = SQLAuthenticator.class.getName();
    private static final DataSource dataSource = (DataSource) svcBean.getAuthDataSource();

    /**
     * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator#performLogon(java.lang.String, java.lang.String, java.util.List)
     */
    @Override
    public synchronized List<Object> performLogon(final String username, final String password) throws AuthenticatorException
    {
        final String methodName = SQLAuthenticator.CNAME + "#performLogon(final String user, final String password) throws AuthenticatorException";
        
        if(DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("String: {}", username);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<Object> userAccount = null;

        try
        {
            sqlConn = SQLAuthenticator.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{CALL performAuthentication(?, ?)}");
            stmt.setString(1, username); // username
            stmt.setString(2, password); // password

            if (DEBUG)
            {
                DEBUGGER.debug("CallableStatement: {}", stmt);
            }

            if (!(stmt.execute()))
            {
                throw new AuthenticatorException("No user was found for the provided user information");
            }

            resultSet = stmt.getResultSet();

            if (DEBUG)
            {
                DEBUGGER.debug("ResultSet: {}", resultSet);
            }

            if (resultSet.next())
            {
                resultSet.first();
                userAccount = new ArrayList<Object>();

                for (String attribute : authData.getEntries())
                {
                    if (DEBUG)
                    {
                        DEBUGGER.debug("Attribute: {}", attribute);
                    }

                    userAccount.add(resultSet.getString(attribute));
                }

                if (DEBUG)
                {
                    DEBUGGER.debug("UserAccount: {}", userAccount);
                }
            }
        }
        catch (SQLException sqx)
        {
            throw new AuthenticatorException(sqx.getMessage(), sqx);
        }
        finally
        {
            try
            {
                if (resultSet != null)
                {
                    resultSet.close();
                }
            
                if (stmt != null)
                {
                    stmt.close();
                }

                if (!(sqlConn == null) && (!(sqlConn.isClosed())))
                {
                    sqlConn.close();
                }
            }
            catch (SQLException sqx)
            {
                ERROR_RECORDER.error(sqx.getMessage(), sqx);
            }
        }

        return userAccount;
    }

    /**
     * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator#obtainSecurityData(java.lang.String, java.lang.String, java.util.List)
     */
    @Override
    public synchronized List<String> obtainSecurityData(final String userName, final String userGuid) throws AuthenticatorException
    {
        final String methodName = SQLAuthenticator.CNAME + "#obtainSecurityData(final String userName, final String userGuid) throws AuthenticatorException";
        
        if(DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<String> userSecurity = null;

        try
        {
            sqlConn = SQLAuthenticator.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{CALL getUserByAttribute(?)}");
            stmt.setString(1, userGuid); // guid

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.execute())
            {
                resultSet = stmt.getResultSet();

                if (DEBUG)
                {
                    DEBUGGER.debug("ResultSet: {}", resultSet);
                }

                if (resultSet.next())
                {
                    resultSet.first();
                    userSecurity = new ArrayList<>();

                    for (String attribute : authData.getEntries())
                    {
                        if (DEBUG)
                        {
                            DEBUGGER.debug("Attribute: {}", attribute);
                        }

                        userSecurity.add(resultSet.getString(attribute));
                    }

                    if (DEBUG)
                    {
                        DEBUGGER.debug("userSecurity: {}", userSecurity);
                    }
                }
            }
        }
        catch (SQLException sqx)
        {
            throw new AuthenticatorException(sqx.getMessage(), sqx);
        }
        finally
        {
            try
            {
                if (resultSet != null)
                {
                    resultSet.close();
                }
            
                if (stmt != null)
                {
                    stmt.close();
                }

                if (!(sqlConn == null) && (!(sqlConn.isClosed())))
                {
                    sqlConn.close();
                }
            }
            catch (SQLException sqx)
            {
                ERROR_RECORDER.error(sqx.getMessage(), sqx);
            }
        }

        return userSecurity;
    }
    
    /**
     * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator#obtainOtpSecret(java.lang.String, java.lang.String, java.lang.String)
     */
    @Override
    public synchronized String obtainOtpSecret(final String userName, final String userGuid) throws AuthenticatorException
    {
        final String methodName = SQLAuthenticator.CNAME + "#obtainOtpSecret(final String userName, final String userGuid) throws AuthenticatorException";
        
        if(DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        String otpSecret = null;
        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLAuthenticator.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{CALL getOtpSecret(?, ?)}");
            stmt.setString(1, userGuid); // guid
            stmt.setString(2, userName);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.execute())
            {
                resultSet = stmt.getResultSet();

                if (DEBUG)
                {
                    DEBUGGER.debug("ResultSet: {}", resultSet);
                }

                if (resultSet.next())
                {
                    resultSet.first();

                    otpSecret = resultSet.getString(1);
                }
            }
        }
        catch (SQLException sqx)
        {
            throw new AuthenticatorException(sqx.getMessage(), sqx);
        }
        finally
        {
            try
            {
                if (resultSet != null)
                {
                    resultSet.close();
                }
            
                if (stmt != null)
                {
                    stmt.close();
                }

                if (!(sqlConn == null) && (!(sqlConn.isClosed())))
                {
                    sqlConn.close();
                }
            }
            catch (SQLException sqx)
            {
                ERROR_RECORDER.error(sqx.getMessage(), sqx);
            }
        }

        return otpSecret;
    }

    /**
     * @see com.cws.esolutions.security.dao.userauth.interfaces.Authenticator#verifySecurityData(java.lang.String, java.lang.String, java.util.Map)
     */
    @Override
    public synchronized boolean verifySecurityData(final String userId, final String userGuid, final List<String> attributes) throws AuthenticatorException
    {
        final String methodName = SQLAuthenticator.CNAME + "#verifySecurityData(final String userId, final String userGuid, final List<String> attributes) throws AuthenticatorException";

        if(DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userId);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        Connection sqlConn = null;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLAuthenticator.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{CALL verifySecurityQuestions(?, ?, ?)}");
            stmt.setString(1, userId); // guid
            stmt.setString(2, attributes.get(0)); // username
            stmt.setString(3, attributes.get(1)); // username

            if (DEBUG)
            {
                DEBUGGER.debug("Statement: {}", stmt.toString());
            }

            return stmt.execute();
        }
        catch (SQLException sqx)
        {
            throw new AuthenticatorException(sqx.getMessage(), sqx);
        }
        finally
        {
            try
            {
                if (stmt != null)
                {
                    stmt.close();
                }

                if (!(sqlConn == null) && (!(sqlConn.isClosed())))
                {
                    sqlConn.close();
                }
            }
            catch (SQLException sqx)
            {
                ERROR_RECORDER.error(sqx.getMessage(), sqx);
            }
        }
    }
}
