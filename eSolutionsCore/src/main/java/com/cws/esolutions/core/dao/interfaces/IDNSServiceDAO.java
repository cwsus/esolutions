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
package com.cws.esolutions.core.dao.interfaces;
/*
 * Project: eSolutionsCore
 * Package: com.cws.esolutions.core.dao.processors.interfaces
 * File: IDNSServiceDAO.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.util.List;
import java.util.Vector;
import org.slf4j.Logger;
import javax.sql.DataSource;
import java.sql.SQLException;
import org.slf4j.LoggerFactory;

import com.cws.esolutions.core.CoreServiceConstants;
import com.cws.esolutions.core.CoreServiceBean;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author khuntly
 * @version 1.0
 */
public interface IDNSServiceDAO
{
    static final CoreServiceBean appBean = CoreServiceBean.getInstance();
    static final DataSource dataSource = appBean.getDataSources().get("ApplicationDataSource");

    static final String CNAME = IDNSServiceDAO.class.getName();

    static final Logger ERROR_RECORDER = LoggerFactory.getLogger(CoreServiceConstants.ERROR_LOGGER + CNAME);
    static final Logger DEBUGGER = LoggerFactory.getLogger(CoreServiceConstants.DEBUGGER);
    static final boolean DEBUG = DEBUGGER.isDebugEnabled();

    List<Vector<String>> getServiceData(final String serviceName) throws SQLException;

    boolean addNewService(final List<String> serviceData, final boolean isApex) throws SQLException;

    boolean removeService(final String serviceName) throws SQLException;
}