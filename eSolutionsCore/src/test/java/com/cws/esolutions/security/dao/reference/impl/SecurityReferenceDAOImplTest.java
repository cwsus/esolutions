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
package com.cws.esolutions.security.dao.reference.impl;

import java.util.List;
import org.junit.Test;
import org.junit.After;
import org.junit.Before;
import org.junit.Assert;
import java.sql.SQLException;

import com.cws.esolutions.security.listeners.SecurityServiceInitializer;
import com.cws.esolutions.security.dao.reference.interfaces.ISecurityReferenceDAO;
/**
 * eSolutionsCore
 * com.cws.esolutions.security.dao.reference.impl
 * SecurityReferenceDAOImplTest.java
 *
 * $Id: $
 * $Author: $
 * $Date: $
 * $Revision: $
 * @author kmhuntly@gmail.com
 * @version 1.0
 *
 * History
 * ----------------------------------------------------------------------------
 * 35033355 @ Apr 5, 2013 1:13:49 PM
 *     Created.
 */
public class SecurityReferenceDAOImplTest
{
    private static final ISecurityReferenceDAO secRef = new SecurityReferenceDAOImpl();

    @Before
    public void setUp()
    {
        try
        {
            SecurityServiceInitializer.initializeService("SecurityService/config/ServiceConfig.xml", "SecurityService/config/SecurityLogging.xml");
        }
        catch (Exception e)
        {
            Assert.fail(e.getMessage());
            System.exit(1);
        }
    }

    @Test
    public void testObtainApprovedServers()
    {
        try
        {
            List<String> responseList = secRef.obtainApprovedServers();

            if (responseList.size() == 0)
            {
                Assert.fail("No data was returned");
            }
        }
        catch (SQLException sqx)
        {
            Assert.fail(sqx.getMessage());
        }
    }

    @Test
    public void testObtainSecurityQuestionList()
    {
        try
        {
            List<String> responseList = secRef.obtainSecurityQuestionList();

            if (responseList.size() == 0)
            {
                Assert.fail("No data was returned");
            }
        }
        catch (SQLException sqx)
        {
            Assert.fail(sqx.getMessage());
        }
    }

    @After
    public void tearDown()
    {
        SecurityServiceInitializer.shutdown();
    }
}
