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
package com.cws.esolutions.security.dao.usermgmt.impl;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.dao.usermgmt.impl
 * File: SQLUserManager.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.List;
import java.sql.ResultSet;
import java.sql.Connection;
import java.util.ArrayList;

import javax.sql.DataSource;

import java.sql.SQLException;
import java.sql.CallableStatement;

import com.cws.esolutions.security.SecurityServiceConstants;
import com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager;
import com.cws.esolutions.security.dao.usermgmt.exception.UserManagementException;
/**
 * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager
 */
public class SQLUserManager implements UserManager
{
    private static final String CNAME = SQLUserManager.class.getName();
    private static final DataSource dataSource = svcBean.getDataSources().get(SecurityServiceConstants.INIT_SECURITYDS_MANAGER);

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#validateUserAccount(java.lang.String, java.lang.String)
     */
    @Override
    public synchronized boolean validateUserAccount(final String userId, final String userGuid) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#validateUserAccount(final String userId, final String userGuid) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userId);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        boolean isValid = false;
        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{ CALL getUserByAttribute(?, ?) }");
            stmt.setString(1, userId);
            stmt.setInt(2, 0);

            if (DEBUG)
            {
                DEBUGGER.debug("stmt: {}", stmt);
            }

            if (stmt.execute())
            {
                resultSet = stmt.executeQuery();

                if (DEBUG)
                {
                    DEBUGGER.debug("ResultSet: {}", resultSet);
                }

                if (resultSet.next())
                {
                    throw new UserManagementException("A user currently exists with the provided UUID");
                }

                resultSet.close();
                resultSet = null;

                stmt.close();
                stmt = null;

                stmt = sqlConn.prepareCall("{ CALL getUserByAttribute(?) }");
                stmt.setString(1, userId);

                if (DEBUG)
                {
                    DEBUGGER.debug("stmt: {}", stmt);
                }

                if (stmt.execute())
                {
                    resultSet = stmt.executeQuery();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("ResultSet: {}", resultSet);
                    }

                    if (resultSet.next())
                    {
                        throw new UserManagementException("A user currently exists with the provided username");
                    }
                }
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isValid;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#addUserAccount(java.util.Map, java.util.List)
     */
    @Override
    public synchronized boolean addUserAccount(final List<String> userAccount, final List<String> roles) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#addUserAccount(final List<String> userAccount, final List<String> roles) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userAccount);
            DEBUGGER.debug("Value: {}", roles);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{ CALL addUserAccount(?, ?, ?, ?, ?, ?, ?, ?) }");

            for (int x = 1; x < userAccount.size(); x++)
            {
                if (DEBUG)
                {
                    DEBUGGER.debug("Value: {}", userAccount.get(x));
                }

                stmt.setString(x, userAccount.get(x));
            }

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (!(stmt.execute()))
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#removeUserAccount(java.lang.String)
     */
    @Override
    public synchronized boolean removeUserAccount(final String userId) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#removeUserAccount(final String userId) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("userId: {}", userId);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{ CALL removeUserAccount(?) }");
            stmt.setString(1, userId);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (!(stmt.execute()))
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#searchUsers(java.lang.String)
     */
    @Override
    public synchronized List<String[]> searchUsers(final String searchData) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#searchUsers(final String searchData) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", searchData);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<String[]> results = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{ CALL getUserByAttribute(?, ?) }");
            stmt.setString(1, searchData);
            stmt.setInt(2, 0);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.execute())
            {
                resultSet = stmt.getResultSet();

                if (resultSet.next())
                {
                    resultSet.beforeFirst();
                    results = new ArrayList<>();

                    while (resultSet.next())
                    {
                        String[] userData = new String[]
                        {
                            resultSet.getString("cn"),
                            resultSet.getString("uid")
                        };

                        if (DEBUG)
                        {
                            DEBUGGER.debug("Data: {}", (Object) userData);
                        }

                        results.add(userData);
                    }

                    if (DEBUG)
                    {
                        DEBUGGER.debug("List: {}", results);
                    }
                }
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return results;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#loadUserAccount(java.lang.String, java.util.List)
     */
    @Override
    public synchronized List<Object> loadUserAccount(final String userGuid) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#loadUserAccount(final String guid) throws UserManagementException";
        
        if(DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<Object> userAccount = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{ CALL loadUserAccount(?) }");
            stmt.setString(1, userGuid); // common name

            if (DEBUG)
            {
                DEBUGGER.debug("CallableStatement: {}", stmt);
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
                    resultSet.last();
                    int x = resultSet.getRow();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("x: {}", x);
                    }

                    if ((x == 0) || (x > 1))
                    {
                        throw new UserManagementException("No user account was located for the provided data.");
                    }

                    resultSet.first();
                    userAccount = new ArrayList<>();

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
            else
            {
                throw new UserManagementException("No users were located with the provided information");
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#listUserAccounts()
     */
    @Override
    public synchronized List<String[]> listUserAccounts() throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#listUserAccounts() throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<String[]> results = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{ CALL listUserAccounts() }");

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.execute())
            {
                resultSet = stmt.getResultSet();

                if (resultSet.next())
                {
                    resultSet.beforeFirst();
                    results = new ArrayList<>();

                    while (resultSet.next())
                    {
                        String[] userData = new String[]
                        {
                            resultSet.getString("cn"),
                            resultSet.getString("uid")
                        };

                        if (DEBUG)
                        {
                            for (String str : userData)
                            {
                                DEBUGGER.debug(str);
                            }
                        }

                        results.add(userData);
                    }

                    if (DEBUG)
                    {
                        DEBUGGER.debug("List: {}", results);
                    }
                }
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return results;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#modifyUserEmail(java.lang.String, java.lang.String)
     */
    @Override
    public synchronized boolean modifyUserEmail(final String userId, final String value) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyUserEmail(final String userId, final String value) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userId);
            DEBUGGER.debug("Value: {}", value);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            // first make sure the existing password is proper
            // then make sure the new password doesnt match the existing password
            stmt = sqlConn.prepareCall("{ CALL updateUserEmail(?, ?}");
            stmt.setString(1, userId);
            stmt.setString(2, value);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.executeUpdate() == 1)
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#modifyUserContact(java.lang.String, java.util.String, java.lang.String)
     */
    @Override
    public synchronized boolean modifyUserContact(final String userId, final List<String> values) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyUserContact(final String userId, final List<String> values) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userId);
            DEBUGGER.debug("Values: {}", values);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            // first make sure the existing password is proper
            // then make sure the new password doesnt match the existing password
            stmt = sqlConn.prepareCall("{ CALL updateUserContact(?, ?, ?}");
            stmt.setString(1, userId);
            stmt.setString(2, values.get(0));
            stmt.setString(2, values.get(1));

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.executeUpdate() == 1)
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }
    
    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#modifyUserSuspension(java.lang.String, boolean, java.lang.String)
     */
    @Override
    public synchronized boolean modifyUserSuspension(final String userId, final boolean isSuspended) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyUserSuspension(final String userId, final boolean isSuspended) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userId);
            DEBUGGER.debug("Value: {}", isSuspended);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{ CALL modifyUserSuspension(?, ?) }");
            stmt.setString(1, userId);
            stmt.setBoolean(2, isSuspended);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            int x = stmt.executeUpdate();

            if (DEBUG)
            {
                DEBUGGER.debug("Update: {}", x);
            }

            if (x == 1)
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#modifyUserGroups(java.lang.String, java.util.List)
     */
    @Override
    public synchronized boolean modifyUserGroups(final String userId, final Object[] values) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyUserGroups(final String userId, final Object[] values) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userId);
            DEBUGGER.debug("Value: {}", values);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            // first make sure the existing password is proper
            // then make sure the new password doesnt match the existing password
            stmt = sqlConn.prepareCall("{ CALL updateUserGroups(?, ?,}");
            stmt.setString(1, userId);
            stmt.setString(2, values.toString());

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.executeUpdate() == 1)
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#lockOnlineReset(java.lang.String, java.lang.String)
     */
    @Override
    public synchronized boolean modifyOlrLock(final String userId, final boolean isLocked) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyOlrLock(final String userId, final boolean value) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userId);
            DEBUGGER.debug("Value: {}", isLocked);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            // first make sure the existing password is proper
            // then make sure the new password doesnt match the existing password
            stmt = sqlConn.prepareCall("{ CALL updateOlrLock(?, ?,}");
            stmt.setString(1, userId);
            stmt.setBoolean(2, isLocked);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.executeUpdate() == 1)
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#clearLockCount(java.lang.String, java.lang.int)
     */
    @Override
    public synchronized boolean modifyUserLock(final String userId, final boolean isLocked, final int increment) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyUserLock(final String userId, final boolean int, final boolean increment) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userId);
            DEBUGGER.debug("Value: {}", isLocked);
            DEBUGGER.debug("Value: {}", increment);
        }

        Connection sqlConn = null;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            if (isLocked)
            {
                stmt = sqlConn.prepareCall("{ CALL lockUserAccount(?) }");
                stmt.setString(1, userId);
            }
            else
            {
                stmt = sqlConn.prepareCall("{ CALL incrementLockCount(?) }");
                stmt.setString(1, userId);
            }

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            return (stmt.executeUpdate() == 0);
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#modifyUserPassword(java.lang.String, java.lang.String, java.lang.String)
     */
    @Override
    public synchronized boolean modifyUserPassword(final String userId, final String newPass) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyUserPassword(final String userId, final String newPass) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("userId: {}", userId);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            // first make sure the existing password is proper
            // then make sure the new password doesnt match the existing password
            stmt = sqlConn.prepareCall("{ CALL updateUserPassword(?, ?) }");
            stmt.setString(1, userId);
            stmt.setString(3, newPass);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.executeUpdate() == 1)
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#modifyOtpSecret(java.lang.String, java.lang.String)
     */
    @Override
    public synchronized boolean modifyOtpSecret(final String userId, final boolean addSecret, final String secret) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyOtpSecret(final String userId, final boolean addSecret, final String secret) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("userId: {}", userId);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            if (addSecret)
            {
                stmt = sqlConn.prepareCall("{ CALL addUserSecret(?, ?) }");
                stmt.setString(1, userId);
                stmt.setString(2, secret);
            }
            else
            {
                stmt = sqlConn.prepareCall("{ CALL removeUserSecret(?) }");
                stmt.setString(1, userId);
            }

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.executeUpdate() == 1)
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager#modifyUserSecurity(java.lang.String, java.util.List)
     */
    @Override
    public synchronized boolean modifyUserSecurity(final String userId, final List<String> values) throws UserManagementException
    {
        final String methodName = SQLUserManager.CNAME + "#modifyUserSecurity(final String userId, final List<String> values) throws UserManagementException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("userId: {}", userId);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = SQLUserManager.dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            // first make sure the existing password is proper
            // then make sure the new password doesnt match the existing password
            stmt = sqlConn.prepareCall("{ CALL updateUserSecurity(?, ?, ?, ?, ?) }");
            stmt.setString(1, userId);
            stmt.setString(2, values.get(0));
            stmt.setString(3, values.get(1));
            stmt.setString(4, values.get(2));
            stmt.setString(5, values.get(3));

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.executeUpdate() == 1)
            {
                isComplete = true;
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new UserManagementException(sqx.getMessage(), sqx);
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

        return isComplete;
    }
}
