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
package com.cws.esolutions.core.dao.processors.impl;
/*
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.core.dao.interfaces
 * File: IPackageDataDAO.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.List;
import java.util.Arrays;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.CallableStatement;
import org.apache.commons.lang.StringUtils;

import com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO;
/**
 * @see com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO
 */
public class PlatformDataDAOImpl implements IPlatformDataDAO
{
    /**
     * @see com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO#addNewPlatform(java.util.List)
     */
    @Override
    public synchronized boolean addNewPlatform(final List<String> platformData) throws SQLException
    {
        final String methodName = IPlatformDataDAO.CNAME + "#addNewPlatform(final List<String> platformData) throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);

            for (String str : platformData)
            {
                DEBUGGER.debug(str);
            }
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{ CALL addNewPlatform(?, ?, ?, ?, ?, ?, ?) }");
            stmt.setString(1, platformData.get(0)); // platform guid
            stmt.setString(2, platformData.get(1)); // platform name
            stmt.setString(3, platformData.get(2)); // platform region
            stmt.setString(4, platformData.get(3)); // partition
            stmt.setString(5, platformData.get(4)); // status
            stmt.setString(6, platformData.get(5)); // platform servers (list, could be null)
            stmt.setString(7, platformData.get(6)); // platform description

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

            if ((sqlConn != null) && (!(sqlConn.isClosed())))
            {
                sqlConn.close();
            }
        }

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO#deletePlatform(java.lang.String)
     */
    @Override
    public synchronized boolean deletePlatform(final String platformGuid) throws SQLException
    {
        final String methodName = IPlatformDataDAO.CNAME + "#deletePlatform(final String platformGuid) throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug(platformGuid);
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{CALL removePlatformData(?)}");
            stmt.setString(1, platformGuid);

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

            if ((sqlConn != null) && (!(sqlConn.isClosed())))
            {
                sqlConn.close();
            }
        }

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO#updatePlatformData(java.util.List)
     */
    @Override
    public synchronized boolean updatePlatformData(final List<String> platformData) throws SQLException
    {
        final String methodName = IPlatformDataDAO.CNAME + "#updatePlatformData(final List<String> platformData) throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);

            for (String str : platformData)
            {
                DEBUGGER.debug(str);
            }
        }

        Connection sqlConn = null;
        boolean isComplete = false;
        CallableStatement stmt = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{CALL updatePlatformDetail(?, ?, ?, ?, ?, ?, ?)}");
            stmt.setString(1, platformData.get(0)); // platform guid
            stmt.setString(2, platformData.get(1)); // platform name
            stmt.setString(3, platformData.get(2)); // platform region
            stmt.setString(4, platformData.get(3)); // partition
            stmt.setString(5, platformData.get(4)); // status
            stmt.setString(6, platformData.get(5)); // platform servers (list, could be null)
            stmt.setString(7, platformData.get(6)); // platform description

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

            if ((sqlConn != null) && (!(sqlConn.isClosed())))
            {
                sqlConn.close();
            }
        }

        return isComplete;
    }

    /**
     * @see com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO#getPlatformData(java.lang.String)
     */
    @Override
    public synchronized List<Object> getPlatformData(final String platformGuid) throws SQLException
    {
        final String methodName = IPlatformDataDAO.CNAME + "#getPlatformData(final String platformGuid) throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug(platformGuid);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<Object> responseData = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("SQL Connection is not an instance of Connection or is null");
            }

            sqlConn.setAutoCommit(true);
            stmt = sqlConn.prepareCall("{CALL getPlatformData(?)}");
            stmt.setString(1, platformGuid);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.execute())
            {
                resultSet = stmt.getResultSet();

                if (DEBUG)
                {
                    DEBUGGER.debug("resultSet: {}", resultSet);
                }

                if (resultSet.next())
                {
                    responseData = new ArrayList<Object>(
                            Arrays.asList(
                                    resultSet.getString(1), // PLATFORM_GUID
                                    resultSet.getString(2), // PLATFORM_NAME
                                    resultSet.getString(3), // PLATFORM_REGION
                                    resultSet.getString(4), // PARTITION
                                    resultSet.getString(5), // STATUS
                                    resultSet.getString(6), // PLATFORM_SERVERS
                                    resultSet.getString(7))); // PLATFORM_DESC

                    if (DEBUG)
                    {
                        for (Object obj : responseData)
                        {
                            DEBUGGER.debug("Value: {}", obj);
                        }
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

            if ((!(sqlConn == null) && (!(sqlConn.isClosed()))))
            {
                sqlConn.close();
            }
        }

        return responseData;
    }

    /**
     * @see com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO#getPlatformCount()
     */
    @Override
    public synchronized int getPlatformCount() throws SQLException
    {
        final String methodName = IPlatformDataDAO.CNAME + "#getPlatformCount() throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        int count = 0;
        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);
            stmt = sqlConn.prepareCall("{ CALL getPlatformCount() }");

            if (DEBUG)
            {
                DEBUGGER.debug("stmt: {}", stmt);
            }

            if (stmt.execute())
            {
                resultSet = stmt.getResultSet();

                if (DEBUG)
                {
                    DEBUGGER.debug("resultSet: {}", resultSet);
                }

                if (resultSet.next())
                {
                    resultSet.first();

                    count = resultSet.getInt(1);

                    if (DEBUG)
                    {
                        DEBUGGER.debug("count: {}", count);
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

        return count;
    }

    /**
     * @see com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO#listAvailablePlatforms(int)
     */
    @Override
    public synchronized List<String[]> listAvailablePlatforms(final int startRow) throws SQLException
    {
        final String methodName = IPlatformDataDAO.CNAME + "#listAvailablePlatforms(final int startRow) throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", startRow);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<String[]> platformList = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);

            stmt = sqlConn.prepareCall("{CALL listPlatforms(?)}");
            stmt.setInt(1, startRow);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.execute())
            {
                resultSet = stmt.getResultSet();

                if (DEBUG)
                {
                    DEBUGGER.debug("resultSet: {}", resultSet);
                }

                if (resultSet.next())
                {
                    resultSet.beforeFirst();
                    platformList = new ArrayList<>();

                    while (resultSet.next())
                    {
                        String[] data = new String[]
                        {
                            resultSet.getString(1), // PLATFORM_GUID
                            resultSet.getString(2) // PLATFORM_NAME
                        };

                        if (DEBUG)
                        {
                            for (String str : data)
                            {
                                DEBUGGER.debug("data: {}", str);
                            }
                        }

                        platformList.add(data);
                    }

                    if (DEBUG)
                    {
                        DEBUGGER.debug("platformList: {}", platformList);
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

            if ((sqlConn != null) && (!(sqlConn.isClosed())))
            {
                sqlConn.close();
            }
        }

        return platformList;
    }

    /**
     * @see com.cws.esolutions.core.dao.processors.interfaces.IPlatformDataDAO#listPlatformsByAttribute(java.lang.String, int)
     */
    @Override
    public synchronized List<String[]> listPlatformsByAttribute(final String value, final int startRow) throws SQLException
    {
        final String methodName = IPlatformDataDAO.CNAME + "#listPlatformsByAttribute(final String value, final int startRow) throws SQLException";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
            DEBUGGER.debug("Value: {}", startRow);
        }

        Connection sqlConn = null;
        ResultSet resultSet = null;
        CallableStatement stmt = null;
        List<String[]> platformList = null;

        try
        {
            sqlConn = dataSource.getConnection();

            if (sqlConn.isClosed())
            {
                throw new SQLException("Unable to obtain application datasource connection");
            }

            sqlConn.setAutoCommit(true);
            StringBuilder sBuilder = new StringBuilder();

            if (StringUtils.split(value, " ").length >= 2)
            {
                for (String str : StringUtils.split(value, " "))
                {
                    if (DEBUG)
                    {
                        DEBUGGER.debug("Value: {}", str);
                    }

                    sBuilder.append("+" + str);
                    sBuilder.append(" ");
                }

                if (DEBUG)
                {
                    DEBUGGER.debug("StringBuilder: {}", sBuilder);
                }
            }
            else
            {
                sBuilder.append("+" + value);
            }

            stmt = sqlConn.prepareCall("{CALL getPlatformByAttribute(?, ?)}");
            stmt.setString(1, sBuilder.toString().trim());
            stmt.setInt(2, startRow);

            if (DEBUG)
            {
                DEBUGGER.debug(stmt.toString());
            }

            if (stmt.execute())
            {
                resultSet = stmt.getResultSet();

                if (DEBUG)
                {
                    DEBUGGER.debug("resultSet: {}", resultSet);
                }

                if (resultSet.next())
                {
                    resultSet.beforeFirst();
                    platformList = new ArrayList<>();

                    while (resultSet.next())
                    {
                        String[] data = new String[]
                        {
                            resultSet.getString(1), // PLATFORM_GUID
                            resultSet.getString(2) // PLATFORM_NAME
                        };

                        if (DEBUG)
                        {
                            for (String str : data)
                            {
                                DEBUGGER.debug("data: {}", str);
                            }
                        }

                        platformList.add(data);
                    }

                    if (DEBUG)
                    {
                        DEBUGGER.debug("platformList: {}", platformList);
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

            if ((sqlConn != null) && (!(sqlConn.isClosed())))
            {
                sqlConn.close();
            }
        }

        return platformList;
    }
}
