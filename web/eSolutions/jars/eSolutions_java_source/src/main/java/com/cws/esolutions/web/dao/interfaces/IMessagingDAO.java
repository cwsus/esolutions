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
package com.cws.esolutions.web.dao.interfaces;
/*
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.core.dao.processors.interfaces
 * File: IMessagingDAO.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.List;
import org.slf4j.Logger;
import java.sql.SQLException;
import org.slf4j.LoggerFactory;

import com.cws.esolutions.web.Constants;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author khuntly
 * @version 1.0
 */
public interface IMessagingDAO
{
    static final String CNAME = IMessagingDAO.class.getName();

    static final Logger ERROR_RECORDER = LoggerFactory.getLogger(Constants.ERROR_LOGGER + CNAME);
    static final Logger DEBUGGER = LoggerFactory.getLogger(Constants.DEBUGGER);
    static final boolean DEBUG = DEBUGGER.isDebugEnabled();

    /**
     * 
     * Adds a new service message into the datastore. Service messages are notification
     * messages from site or system administrators to notify of planned or unplanned
     * outages, planned events, etc.
     *
     * @param messageList - The list of data to insert that comprises the message. This
     *     will be different for an email message vs a service message.
     *     A service message must be in the following format:
     *          0: (String) Message ID
     *          1: (String) Message title (aka subject)
     *          2: (String) Message text
     *          3: (String) Message author
     *          4: (String) Author email address
     *          5: (Long) Expiration date (optional, if not necessary specify null)
     *              This should be the result of cal.getTime(). For example, to expire a message after
     *              30 days, the following is appropriate:
     *
     *              final Calendar cal = Calendar.getInstance();
     *              cal.add(Calendar.DATE, 30);
     *              final Long expiryDate expiryDate = cal.getTime(); // this value would then be used
     *     An email message must be in the following format:
     *         0: (String) Message ID
     *         1: (String) Message Subject
     *         2: (List<String>) Message BCC (blind carbon-copy)
     *         3: (List<String>) Message CC (carbon-copy)
     *         4: (List<String>) Message To
     *         5: (List<String>) Message From
     *         6: (String[]) Message origination servers
     *         7: (String) Message body
     *         8: (Object) Message attachments
     *         9: (Long) Message date
     *         10: (String) Author first name (used on web requests)
     *         11: (String) Author last name (used on web requests)
     *      
     * @return <code>true</code> if the operation was successful, <code>false</code> otherwise
     * @throws SQLException if an error occurs during the data operation
     */
    boolean insertMessage(final List<Object> messageList) throws SQLException;

    List<Object> retrieveMessage(final String messageId) throws SQLException;

    List<Object[]> retrieveMessages() throws SQLException;

    List<Object[]> retrieveAlertMessages() throws SQLException;

    List<Object[]> getMessagesByAttribute(final String value) throws SQLException;

    boolean updateMessage(final String messageId, final List<Object> messageList) throws SQLException;

    boolean deleteMessage(final String messageId) throws SQLException;
}