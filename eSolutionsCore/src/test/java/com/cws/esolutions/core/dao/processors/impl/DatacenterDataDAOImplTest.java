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
package com.cws.esolutions.core.dao.processors.impl;

import java.util.List;
import java.util.UUID;
import org.junit.Test;
import java.util.Arrays;
import org.junit.Assert;
import org.junit.Before;
import java.util.ArrayList;
import java.sql.SQLException;

import com.cws.esolutions.core.listeners.CoreServiceInitializer;
import com.cws.esolutions.core.dao.processors.interfaces.IDatacenterDataDAO;
/**
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.core.dao.processors.impl
 * File: DatacenterDataDAOImplTest.java
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
 * 35033355 @ Oct 22, 2013 12:41:42 PM
 *     Created.
 */
public class DatacenterDataDAOImplTest
{
    private static final IDatacenterDataDAO dao = new DatacenterDataDAOImpl();

    @Before
    public final void setUp() throws Exception
    {
        try
        {
            CoreServiceInitializer.initializeService("eSolutionsCore/config/ServiceConfig.xml", "logging/logging.xml");
        }
        catch (Exception ex)
        {
            Assert.fail(ex.getMessage());

            System.exit(-1);
        }
    }

    @Test
    public final void testAddNewDatacenter()
    {
        List<String> data = new ArrayList<String>(
                Arrays.asList(
                        UUID.randomUUID().toString(),
                        "Test Datacenter",
                        "ACTIVE",
                        "Test Datacenter"));

        try
        {
            Assert.assertTrue(dao.addNewDatacenter(data));
        }
        catch (SQLException sqx)
        {
            Assert.fail(sqx.getMessage());
        }
    }

    @Test
    public final void testRemoveExistingDatacenter()
    {
        try
        {
            Assert.assertTrue(dao.removeExistingDatacenter("guid"));
        }
        catch (SQLException sqx)
        {
            Assert.fail(sqx.getMessage());
        }
    }

    @Test
    public final void testGetAvailableDataCenters()
    {
        try
        {
            Assert.assertNotNull(dao.getAvailableDataCenters());
        }
        catch (SQLException sqx)
        {
            Assert.fail(sqx.getMessage());
        }
    }

    @Test
    public final void testGetDataCenterByAttribute()
    {
        try
        {
            Assert.assertNotNull(dao.getDataCenterByAttribute("attribute"));
        }
        catch (SQLException sqx)
        {
            Assert.fail(sqx.getMessage());
        }
    }

    @Test
    public final void testGetDatacenter()
    {
        try
        {
            Assert.assertNotNull(dao.getDatacenter("attribute"));
        }
        catch (SQLException sqx)
        {
            Assert.fail(sqx.getMessage());
        }
    }
}