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
package com.cws.esolutions.security.quartz;
/*
 * Project: eSolutionsSecurity
 * Package: com.cws.esolutions.security.quartz
 * File: PasswordExpirationNotifier.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.Map;
import java.util.List;
import org.quartz.Job;
import org.slf4j.Logger;
import java.util.Calendar;
import org.slf4j.LoggerFactory;
import javax.mail.MessagingException;
import org.quartz.JobExecutionContext;

import com.cws.esolutions.security.SecurityServiceBean;
import com.cws.esolutions.security.SecurityServiceConstants;
import com.cws.esolutions.security.dao.usermgmt.interfaces.UserManager;
import com.cws.esolutions.security.dao.usermgmt.factory.UserManagerFactory;
import com.cws.esolutions.security.dao.usermgmt.exception.UserManagementException;
/**
 * @see org.quartz.Job
 */
public class PasswordExpirationNotifier implements Job
{
    private static final String CNAME = PasswordExpirationNotifier.class.getName();
    private static final SecurityServiceBean bean = SecurityServiceBean.getInstance();

    private static final Logger DEBUGGER = LoggerFactory.getLogger(SecurityServiceConstants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(SecurityServiceConstants.ERROR_LOGGER + PasswordExpirationNotifier.CNAME);

    public PasswordExpirationNotifier()
    {
        final String methodName = PasswordExpirationNotifier.CNAME + "#PasswordExpirationNotifier()#Constructor";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }
    }

    @Override
    public void execute(final JobExecutionContext context)
    {
        final String methodName = PasswordExpirationNotifier.CNAME + "#execute(final JobExecutionContext jobContext)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("JobExecutionContext: {}", context);
        }

        final Map<String, Object> jobData = context.getJobDetail().getJobDataMap();

        if (DEBUG)
        {
            DEBUGGER.debug("jobData: {}", jobData);
        }

        try
        {
            UserManager manager = UserManagerFactory.getUserManager(bean.getConfigData().getSecurityConfig().getUserManager());

            if (DEBUG)
            {
                DEBUGGER.debug("UserManager: {}", manager);
            }

            List<String[]> accounts = manager.listUserAccounts();

            if (DEBUG)
            {
                DEBUGGER.debug("accounts: {}", accounts);
            }

            if ((accounts != null) && (accounts.size() != 0))
            {
                Calendar cal = Calendar.getInstance();
                cal.add(Calendar.DATE, 30);
                Long expiryTime = cal.getTimeInMillis();

                if (DEBUG)
                {
                    DEBUGGER.debug("Calendar: {}", cal);
                    DEBUGGER.debug("expiryTime: {}", expiryTime);
                }

                for (String[] account : accounts)
                {
                    if (DEBUG)
                    {
                        DEBUGGER.debug("Account: {}", account);
                    }
                    // TODO
                }
            }
        }
        catch (UserManagementException umx)
        {
            ERROR_RECORDER.error(umx.getMessage(), umx);
        }
    }
}