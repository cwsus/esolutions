/*
 * Copyright (c) 2009 - 2020 CaspersBox Web Services
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
package com.cws.esolutions.security.processors.impl;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.processors.impl
 * File: AccountResetProcessorImplTest.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly          11/23/2008 22:39:20             Created.
 */
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.assertj.core.api.Assertions;
import org.junit.jupiter.api.TestInstance;

import com.cws.esolutions.security.dto.UserAccount;
import com.cws.esolutions.security.enums.SecurityRequestStatus;
import com.cws.esolutions.security.processors.dto.RequestHostInfo;
import com.cws.esolutions.security.processors.dto.AuthenticationData;
import com.cws.esolutions.security.processors.dto.AccountResetRequest;
import com.cws.esolutions.security.processors.dto.AccountResetResponse;
import com.cws.esolutions.security.listeners.SecurityServiceInitializer;
import com.cws.esolutions.security.processors.exception.AccountResetException;
import com.cws.esolutions.security.processors.interfaces.IAccountResetProcessor;

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class AccountResetProcessorImplTest
{
    private static RequestHostInfo hostInfo = null;

    private static final IAccountResetProcessor processor = (IAccountResetProcessor) new AccountResetProcessorImpl();

    @BeforeAll public void setUp()
    {
        try
        {
            SecurityServiceInitializer.initializeService("SecurityService/config/ServiceConfig.xml", "SecurityService/logging/logging.xml", true);

            hostInfo = new RequestHostInfo();
            hostInfo.setHostAddress("junit");
            hostInfo.setHostName("junit");
        }
        catch (final Exception e)
        {
            Assertions.fail(e.getMessage());
            System.exit(1);
        }
    }

    @Test public void isOnlineResetAvailable()
    {
        UserAccount account = new UserAccount();
        account.setUsername("khuntly");
        account.setGuid("8c6fac90-6c15-4d69-bf08-2f48ec51e8d4");

        AccountResetRequest request = new AccountResetRequest();
        request.setApplicationId("f42fb0ba-4d1e-1126-986f-800cd2650000");
        request.setApplicationName("eSolutions");
        request.setHostInfo(hostInfo);
        request.setUserAccount(account);

        try
        {
            AccountResetResponse response = processor.isOnlineResetAvailable(request);

            Assertions.assertThat(response.getRequestStatus()).isEqualTo(SecurityRequestStatus.SUCCESS);
        }
        catch (final AccountResetException ax)
        {
        	ax.printStackTrace();
            Assertions.fail(ax.getMessage());
        }
    }

    @Test public void obtainUserSecurityConfig()
    {
	    UserAccount account = new UserAccount();
	    account.setUsername("khuntly");
	    account.setGuid("8c6fac90-6c15-4d69-bf08-2f48ec51e8d4");
	
	    AccountResetRequest request = new AccountResetRequest();
	    request.setApplicationId("f42fb0ba-4d1e-1126-986f-800cd2650000");
	    request.setApplicationName("eSolutions");
	    request.setHostInfo(hostInfo);
	    request.setUserAccount(account);
	
	    try
	    {
	        AccountResetResponse response = processor.obtainUserSecurityConfig(request);
	
	        Assertions.assertThat(response.getRequestStatus()).isEqualTo(SecurityRequestStatus.SUCCESS);
	    }
	    catch (final AccountResetException ax)
	    {
	        Assertions.fail(ax.getMessage());
	    }
    }

    @Test public void verifyUserSecurityConfig()
    {
        UserAccount account = new UserAccount();
        account.setUsername("khuntly");
        account.setGuid("8c6fac90-6c15-4d69-bf08-2f48ec51e8d4");

        AuthenticationData userSecurity = new AuthenticationData();
        userSecurity.setSecAnswerOne("8OHoNs3jd1upwg12NsBRX511F7z83zW1".toCharArray());
        userSecurity.setSecAnswerTwo("gmnL01azdw3baYviPq70ZnZaNjJFWT7U".toCharArray());

        AccountResetRequest request = new AccountResetRequest();
        request.setApplicationId("f42fb0ba-4d1e-1126-986f-800cd2650000");
        request.setApplicationName("eSolutions");
        request.setHostInfo(hostInfo);
        request.setUserAccount(account);
        request.setUserSecurity(userSecurity);

        try
        {
            AccountResetResponse response = processor.verifyUserSecurityConfig(request);

            Assertions.assertThat(response.getRequestStatus()).isEqualTo(SecurityRequestStatus.SUCCESS);
        }
        catch (final AccountResetException ax)
        {
        	ax.printStackTrace();
            Assertions.fail(ax.getMessage());
        }
    }

    @Test public void resetUserPassword()
    {
        UserAccount account = new UserAccount();
        account.setGuid("f42fb0ba-4d1e-1126-986f-800cd2650000");
        account.setUsername("junit");
        account.setEmailAddr("cws-khuntly");

        AccountResetRequest request = new AccountResetRequest();
        request.setApplicationName("esolutions");
        request.setHostInfo(hostInfo);
        request.setUserAccount(account);

        try
        {
            AccountResetResponse response = processor.insertResetRequest(request);

            Assertions.assertThat(response.getRequestStatus()).isEqualTo(SecurityRequestStatus.SUCCESS);
        }
        catch (final AccountResetException arx)
        {
            arx.printStackTrace();
            Assertions.fail(arx.getMessage());
        }
    }

    @Test public void verifyResetRequest()
    {
        AccountResetRequest request = new AccountResetRequest();
        request.setApplicationName("esolutions");
        request.setHostInfo(hostInfo);
        request.setResetRequestId("hJRr61LbqEx9NngsgGbwNDdqVgB8eDy9HTsJoWPY4vTEj7QYPZK9hCbrlg9PyIYv");

        try
        {
            AccountResetResponse response = processor.verifyResetRequest(request);

            Assertions.assertThat(response.getRequestStatus()).isEqualTo(SecurityRequestStatus.SUCCESS);
        }
        catch (final AccountResetException arx)
        {
            Assertions.fail(arx.getMessage());
        }
    }

    @AfterAll public void tearDown()
    {
        SecurityServiceInitializer.shutdown();
    }
}
