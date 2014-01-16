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
package com.cws.esolutions.security.dao.reference.impl;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.dao.reference.impl
 * File: UserServiceInformationDAOImpl.java
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
import java.sql.SQLException;
import java.sql.CallableStatement;

import org.apache.commons.lang.StringUtils;

import com.cws.esolutions.security.dao.reference.interfaces.IUserServiceInformationDAO;
/**
 * @see com.cws.esolutions.security.dao.reference.interfaces.ISecurityReferenceDAO
 */
public class UserServiceInformationDAOImpl implements IUserServiceInformationDAO
{
    /**
     * @see com.cws.esolutions.security.dao.reference.interfaces.IUserServiceInformationDAO#addServiceToUser(java.lang.String, java.lang.String)
     */
    @Override
    public synchronized boolean addServiceToUser(final String commonName, final String serviceGuid) throws SQLException
    {
        final String methodName = IUserServiceInformationDAO.CNAME + "#addServiceToUser(final String commonName, final String serviceGuid) throws SQLException";
        
        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("commonName: {}", commonName);
            DEBUGGER.debug("serviceGuid: {}", serviceGuid);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (DEBUG)
            {
                DEBUGGER.debug("Connection: {}", sqlConn);
            }

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);
            stmt = sqlConn.prepareCall("{CALL addServiceToUser(?, ?)}");
            stmt.setString(1, commonName);
            stmt.setString(2, serviceGuid);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            isComplete = (!(stmt.execute()));

            if (DEBUG)
            {
                DEBUGGER.debug("isComplete: {}", isComplete);
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new SQLException(sqx.getMessage(), sqx);
        }
        finally
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.reference.interfaces.IUserServiceInformationDAO#removeServiceFromUser(java.lang.String, java.lang.String)
     */
    @Override
    public synchronized boolean removeServiceFromUser(final String commonName, final String serviceGuid) throws SQLException
    {
        final String methodName = IUserServiceInformationDAO.CNAME + "#removeServiceFromUser(final String commonName, final String serviceGuid) throws SQLException";
        
        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("commonName: {}", commonName);
            DEBUGGER.debug("serviceGuid: {}", serviceGuid);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (DEBUG)
            {
                DEBUGGER.debug("Connection: {}", sqlConn);
            }

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);
            stmt = sqlConn.prepareCall("{CALL removeServiceFromUser(?, ?)}");
            stmt.setString(1, commonName);
            stmt.setString(2, serviceGuid);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            isComplete = (!(stmt.execute()));

            if (DEBUG)
            {
                DEBUGGER.debug("isComplete: {}", isComplete);
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new SQLException(sqx.getMessage(), sqx);
        }
        finally
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.reference.interfaces.IUserServiceInformationDAO#verifyServiceForUser(java.lang.String, java.lang.String)
     */
    @Override
    public synchronized boolean verifyServiceForUser(final String commonName, final String serviceGuid) throws SQLException
    {
        final String methodName = IUserServiceInformationDAO.CNAME + "#verifyServiceForUser(final String commonName, final String serviceGuid) throws SQLException";
        
        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("commonName: {}", commonName);
            DEBUGGER.debug("serviceGuid: {}", serviceGuid);
        }
        
        Connection sqlConn = null;
        boolean isComplete = false;
        ResultSet resultSet = null;
        CallableStatement stmt = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (DEBUG)
            {
                DEBUGGER.debug("Connection: {}", sqlConn);
            }

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);
            stmt = sqlConn.prepareCall("{CALL verifySvcForUser(?, ?)}");
            stmt.setString(1, commonName);
            stmt.setString(2, serviceGuid);

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

                    isComplete = resultSet.getBoolean(1);

                    if (DEBUG)
                    {
                        DEBUGGER.debug("isComplete: {}", isComplete);
                    }
                }
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new SQLException(sqx.getMessage(), sqx);
        }
        finally
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

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.security.dao.reference.interfaces.IUserServiceInformationDAO#listServicesForUser(java.lang.String)
     */
    @Override
    public synchronized List<String> listServicesForUser(final String commonName) throws SQLException
    {
        final String methodName = IUserServiceInformationDAO.CNAME + "#listServicesForUser(final String commonName) throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug(commonName);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<String> serviceList = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (DEBUG)
            {
                DEBUGGER.debug("Connection: {}", sqlConn);
            }

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);
            stmt = sqlConn.prepareCall("{CALL listServicesForUser(?)}");
            stmt.setString(1, commonName);

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
                    resultSet.beforeFirst();
                    serviceList = new ArrayList<>();

                    while (resultSet.next())
                    {
                        serviceList.add(resultSet.getString(1));
                    }

                    if (DEBUG)
                    {
                        DEBUGGER.debug("List<String>: {}", serviceList);
                    }
                }
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new SQLException(sqx.getMessage(), sqx);
        }
        finally
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

        return serviceList;
    }

    /**
     * @see com.cws.esolutions.security.dao.reference.interfaces.IUserServiceInformationDAO#listServicesForGroup(java.lang.String)
     */
    @Override
    public synchronized List<String> listServicesForGroup(final String groupName) throws SQLException
    {
        final String methodName = IUserServiceInformationDAO.CNAME + "#listServicesForGroup(final String groupName) throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", groupName);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<String> serviceList = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (DEBUG)
            {
                DEBUGGER.debug("Connection: {}", sqlConn);
            }

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);
            stmt = sqlConn.prepareCall("{CALL listServicesForGroup(?)}");
            stmt.setString(1, groupName);

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
                    serviceList = new ArrayList<>();

                    for (String service : StringUtils.split(resultSet.getString(1), ",")) // single row response
                    {
                        if (DEBUG)
                        {
                            DEBUGGER.debug("Service: {}", service);
                        }

                        serviceList.add(service);
                    }

                    if (DEBUG)
                    {
                        DEBUGGER.debug("List<String>: {}", serviceList);
                    }
                }
            }
        }
        catch (SQLException sqx)
        {
            ERROR_RECORDER.error(sqx.getMessage(), sqx);

            throw new SQLException(sqx.getMessage(), sqx);
        }
        finally
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

        return serviceList;
    }
}