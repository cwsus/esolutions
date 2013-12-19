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
package com.cws.esolutions.agent.processors.interfaces;
/*
 * Project: eSolutionsAgent
 * Package: com.cws.esolutions.agent.processors.interfaces
 * File: IApplicationManagerProcessor.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
import java.io.File;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.cws.esolutions.agent.AgentBean;
import com.cws.esolutions.agent.Constants;
import com.cws.esolutions.agent.config.xml.JMXConfig;
import com.cws.esolutions.agent.config.xml.ScriptConfig;
import com.cws.esolutions.agent.config.xml.ApplicationConfig;
import com.cws.esolutions.agent.processors.dto.ApplicationManagerRequest;
import com.cws.esolutions.agent.processors.dto.ApplicationManagerResponse;
import com.cws.esolutions.agent.processors.exception.ApplicationManagerException;
/**
 * Interface for the Application Data DAO layer. Allows access
 * into the asset management database to obtain, modify and remove
 * application information.
 *
 * @author khuntly
 * @version 1.0
 */
public interface IApplicationManagerProcessor
{
    static final AgentBean appBean = AgentBean.getInstance();

    static final JMXConfig jmxConfig = appBean.getConfigData().getJmxConfig();
    static final ApplicationConfig appConfig = appBean.getConfigData().getAppConfig();
    static final ScriptConfig scriptConfig = appBean.getConfigData().getScriptConfig();

    static final byte buffer[] = new byte[1024];
    static final String CNAME = IApplicationManagerProcessor.class.getName();
    static final int CONNECT_TIMEOUT = appConfig.getConnectTimeout();
    static final int SCRIPT_TIMEOUT = scriptConfig.getScriptTimeout();
    static final File SCRIPT_SRC_DIR = appConfig.getServiceRootDirectory();

    static final Logger DEBUGGER = LoggerFactory.getLogger(Constants.DEBUGGER);
    static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    static final Logger ERROR_RECORDER = LoggerFactory.getLogger(Constants.ERROR_LOGGER + CNAME);
    static final Logger WARN_RECORDER = LoggerFactory.getLogger(Constants.WARN_LOGGER + CNAME);

    /* appserver work **/
    ApplicationManagerResponse manageServerState(final ApplicationManagerRequest request) throws ApplicationManagerException;

    /* application work **/
    // deploy/undeploy application(s)
    ApplicationManagerResponse manageApplicationDeployment(final ApplicationManagerRequest request) throws ApplicationManagerException;

    // start/stop (application ONLY)
    ApplicationManagerResponse manageApplicationState(final ApplicationManagerRequest request) throws ApplicationManagerException;
}
