/*
 * Copyright (c) 2009 - 2013 By: CWS, Inc.
 * 
 * All rights reserved. These materials are confidential and
 * proprietary to CaspersBox Web Services N.A and no part of
 * these materials should be reproduced, published in any form
 * by any means, electronic or mechanical, including photocopy
 * or any information storage or retrieval system not should
 * the materials be disclosed to third parties without the
 * express written authorization of CaspersBox Web Services, N.A.
 */
package com.cws.esolutions.web.controllers;

import java.io.File;
import java.util.Map;
import java.util.List;
import java.util.UUID;
import java.util.Arrays;
import org.slf4j.Logger;
import java.util.HashMap;
import java.util.ArrayList;
import java.io.IOException;
import java.util.Enumeration;
import org.slf4j.LoggerFactory;
import org.apache.commons.io.IOUtils;
import javax.servlet.http.HttpSession;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.StringUtils;
import javax.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.validation.BindingResult;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.view.RedirectView;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.cws.esolutions.web.Constants;
import com.cws.esolutions.security.dto.UserAccount;
import com.cws.esolutions.web.ApplicationServiceBean;
import com.cws.esolutions.web.dto.ApplicationRequest;
import com.cws.esolutions.core.processors.dto.Server;
import com.cws.esolutions.core.processors.dto.Service;
import com.cws.esolutions.core.processors.dto.Application;
import com.cws.esolutions.web.validators.DeploymentValidator;
import com.cws.esolutions.web.validators.ApplicationValidator;
import com.cws.esolutions.security.processors.dto.RequestHostInfo;
import com.cws.esolutions.core.processors.enums.CoreServicesStatus;
import com.cws.esolutions.core.processors.dto.ServiceManagementRequest;
import com.cws.esolutions.core.processors.dto.ServiceManagementResponse;
import com.cws.esolutions.core.processors.dto.ApplicationManagementRequest;
import com.cws.esolutions.core.processors.dto.ApplicationManagementResponse;
import com.cws.esolutions.core.processors.impl.PlatformManagementProcessorImpl;
import com.cws.esolutions.core.processors.exception.ServiceManagementException;
import com.cws.esolutions.core.processors.impl.ApplicationManagementProcessorImpl;
import com.cws.esolutions.core.processors.interfaces.IPlatformManagementProcessor;
import com.cws.esolutions.core.processors.exception.ApplicationManagementException;
import com.cws.esolutions.core.processors.interfaces.IApplicationManagementProcessor;
/*
 * Project: eSolutions_java_source
 * Package: com.cws.esolutions.web.controllers
 * File: ApplicationManagementController.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
@Controller
@RequestMapping("/application-management")
public class ApplicationManagementController
{
    private String applMgmt = null;
    private int recordsPerPage = 20; // default to 20
    private String addAppPage = null;
    private String serviceName = null;
    private String defaultPage = null;
    private String viewAppPage = null;
    private String viewFilePage = null;
    private String platformMgmt = null;
    private String deployAppPage = null;
    private String messageNoFileData = null;
    private String retrieveFilesPage = null;
    private String addPlatformRedirect = null;
    private String messageFileUploaded = null;
    private String viewApplicationsPage = null;
    private String addApplicationRedirect = null;
    private String messageNoBinaryProvided = null;
    private String messageApplicationAdded = null;
    private ApplicationServiceBean appConfig = null;
    private String messageNoPlatformAssigned = null;
    private String messageApplicationRetired = null;
    private String messageNoApplicationsFound = null;
    private String messageNoAppVersionProvided = null;
    private DeploymentValidator deploymentValidator = null;
    private ApplicationValidator applicationValidator = null;

    private static final String CNAME = ApplicationManagementController.class.getName();

    private static final Logger DEBUGGER = LoggerFactory.getLogger(Constants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(Constants.ERROR_LOGGER + CNAME);

    public final void setApplicationValidator(final ApplicationValidator value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setValidator(final ApplicationValidator value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.applicationValidator = value;
    }

    public final void setDeploymentValidator(final DeploymentValidator value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setValidator(final DeploymentValidator value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.deploymentValidator = value;
    }

    public final void setAppConfig(final ApplicationServiceBean value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setAppConfig(final ApplicationServiceBean value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.appConfig = value;
    }

    public final void setAddAppPage(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setAddAppPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.addAppPage = value;
    }

    public final void setRecordsPerPage(final int value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setRecordsPerPage(final int value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.recordsPerPage = value;
    }

    public final void setServiceName(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setServiceName(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.serviceName = value;
    }

    public final void setDefaultPage(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setDefaultPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.defaultPage = value;
    }

    public final void setViewAppPage(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setViewAppPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.viewAppPage = value;
    }

    public final void setViewFilePage(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setViewFilePage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.viewFilePage = value;
    }

    public final void setDeployAppPage(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setDeployAppPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.deployAppPage = value;
    }

    public final void setRetrieveFilesPage(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setRetrieveFilesPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.retrieveFilesPage = value;
    }

    public final void setApplMgmt(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setApplMgmt(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.applMgmt = value;
    }

    public final void setPlatformMgmt(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setPlatformMgmt(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.platformMgmt = value;
    }

    public final void setAddPlatformRedirect(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setAddPlatformRedirect(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.addPlatformRedirect = value;
    }

    public final void setViewApplicationsPage(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setViewApplicationsPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.viewApplicationsPage = value;
    }

    public final void setMessageNoApplicationsFound(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setMessageNoApplicationsFound(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageNoApplicationsFound = value;
    }

    public final void setMessageNoFileData(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setMessageNoFileData(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageNoFileData = value;
    }

    public final void setMessageNoPlatformAssigned(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setMessageNoPlatformAssigned(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageNoPlatformAssigned = value;
    }

    public final void setMessageApplicationAdded(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setMessageApplicationAdded(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageApplicationAdded = value;
    }

    public final void setMessageFileUploaded(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setMessageFileUploaded(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageFileUploaded = value;
    }

    public final void setMessageNoBinaryProvided(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setMessageNoBinaryProvided(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageNoBinaryProvided = value;
    }

    public final void setMessageNoAppVersionProvided(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setMessageNoAppVersionProvided(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageNoAppVersionProvided = value;
    }

    public final void setMessageApplicationRetired(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setMessageApplicationRetired(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageApplicationRetired = value;
    }

    public final void setAddApplicationRedirect(final String value)
    {
        final String methodName = ApplicationManagementController.CNAME + "#setAddApplicationRedirect(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.addApplicationRedirect = value;
    }

    @RequestMapping(value = "/default", method = RequestMethod.GET)
    public final ModelAndView showDefaultPage()
    {
        final String methodName = ApplicationManagementController.CNAME + "#showDefaultPage()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            mView.addObject("command", new Application());
            mView.setViewName(this.defaultPage);
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/search/terms/{terms}/page/{page}", method = RequestMethod.GET)
    public final ModelAndView showSearchPage(@PathVariable("terms") final String terms, @PathVariable("page") final int page)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showSearchPage(@PathVariable(\"terms\") final String terms, @PathVariable(\"page\") final int page)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", terms);
            DEBUGGER.debug("Value: {}", page);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor processor = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Application application = new Application();
                application.setName(terms);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", application);
                }

                ApplicationManagementRequest request = new ApplicationManagementRequest();
                request.setApplication(application);
                request.setApplicationId(this.appConfig.getApplicationId());
                request.setApplicationName(this.appConfig.getApplicationName());
                request.setRequestInfo(reqInfo);
                request.setServiceId(this.applMgmt);
                request.setUserAccount(userAccount);

                if (DEBUG)
                {
                    DEBUGGER.debug("SearchRequest: {}", request);
                }

                ApplicationManagementResponse response = processor.listApplications(request);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", response);
                }

                if (response.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    mView.addObject("pages", (int) Math.ceil(response.getEntryCount() * 1.0 / this.recordsPerPage));
                    mView.addObject("page", page);
                    mView.addObject("searchTerms", terms);
                    mView.addObject(Constants.SEARCH_RESULTS, response.getApplicationList());
                    mView.addObject("command", new Application());
                    mView.setViewName(this.defaultPage);
                }
                else if (response.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.addObject(Constants.ERROR_RESPONSE, this.appConfig.getMessageNoSearchResults());
                    mView.addObject("command", new Application());
                    mView.setViewName(this.defaultPage);
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/list-applications", method = RequestMethod.GET)
    public final ModelAndView doListApplications()
    {
        final String methodName = ApplicationManagementController.CNAME + "#doListApplications()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                appRequest.setRequestInfo(reqInfo);
                appRequest.setServiceId(this.applMgmt);
                appRequest.setUserAccount(userAccount);
                appRequest.setApplicationId(this.appConfig.getApplicationId());
                appRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", appRequest);
                }

                ApplicationManagementResponse appResponse = appMgr.listApplications(appRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", appResponse);
                }

                if (appResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    List<Application> applicationList = appResponse.getApplicationList();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("List<Application>: {}", applicationList);
                    }

                    if ((applicationList != null) && (applicationList.size() != 0))
                    {
                        mView.addObject("applicationList", applicationList);
                        mView.setViewName(this.viewApplicationsPage);
                    }
                    else
                    {
                        mView.addObject(Constants.ERROR_MESSAGE, this.messageNoApplicationsFound);
                        mView.setViewName(this.defaultPage);
                    }
                }
                else if (appResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView = new ModelAndView(new RedirectView());
                    mView.addObject(Constants.ERROR_RESPONSE, this.appConfig.getMessageNoSearchResults());
                    mView.setViewName(this.addApplicationRedirect);
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/application/{request}", method = RequestMethod.GET)
    public final ModelAndView showApplication(@PathVariable("request") final String request)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showApplication(@PathVariable(\"request\") final String request)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("request: {}", request);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Application reqApplication = new Application();
                reqApplication.setGuid(request);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", reqApplication);
                }

                // get a list of available servers
                ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                appRequest.setRequestInfo(reqInfo);
                appRequest.setUserAccount(userAccount);
                appRequest.setServiceId(this.applMgmt);
                appRequest.setApplication(reqApplication);
                appRequest.setApplicationId(this.appConfig.getApplicationId());
                appRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", appRequest);
                }

                ApplicationManagementResponse appResponse = appMgr.getApplicationData(appRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", appResponse);
                }

                if (appResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    Application resApplication = appResponse.getApplication();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("Application: {}", resApplication);
                    }

                    mView.addObject("application", resApplication);
                    mView.setViewName(this.viewAppPage);
                }
                else if (appResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.addObject(Constants.ERROR_RESPONSE, this.appConfig.getMessageNoSearchResults());
                    mView.setViewName(this.defaultPage);
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/add-application", method = RequestMethod.GET)
    public final ModelAndView showAddApplication()
    {
        final String methodName = ApplicationManagementController.CNAME + "#showAddApplication()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IPlatformManagementProcessor platformMgr = new PlatformManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostName(hRequest.getRemoteHost());
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setSessionId(hSession.getId());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            ServiceManagementRequest platformReq = new ServiceManagementRequest();
            platformReq.setRequestInfo(reqInfo);
            platformReq.setServiceId(this.platformMgmt);
            platformReq.setUserAccount(userAccount);
            platformReq.setApplicationId(this.appConfig.getApplicationId());
            platformReq.setApplicationName(this.appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("ServiceManagementRequest: {}", platformReq);
            }

            try
            {
                ServiceManagementResponse platformResponse = platformMgr.listPlatforms(platformReq);

                if (DEBUG)
                {
                    DEBUGGER.debug("ServiceManagementResponse: {}", platformResponse);
                }

                if (platformResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    List<Service> platformList = platformResponse.getPlatformList();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("platformList: {}", platformList);
                    }

                    if ((platformList != null) && (platformList.size() != 0))
                    {
                        Map<String, String> platformListing = new HashMap<>();

                        for (Service platform : platformList)
                        {
                            if (DEBUG)
                            {
                                DEBUGGER.debug("Service: {}", platform);
                            }

                            platformListing.put(platform.getGuid(), platform.getName());
                        }

                        if (DEBUG)
                        {
                            DEBUGGER.debug("platformListing: {}", platformListing);
                        }

                        mView.addObject("platformListing", platformListing);
                    }
                }
                else if (platformResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());

                    return mView;
                }
                else
                {
                    mView = new ModelAndView(new RedirectView());
                    mView.setViewName(this.addPlatformRedirect);

                    return mView;
                }
            }
            catch (ServiceManagementException pmx)
            {
                mView = new ModelAndView(new RedirectView());
                mView.setViewName(this.addPlatformRedirect);

                return mView;
            }

            mView.addObject("command", new ApplicationRequest());
            mView.setViewName(this.addAppPage);
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/retire-application/application/{application}", method = RequestMethod.GET)
    public final ModelAndView showRetireApplication(@PathVariable("application") final String application)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showRetireApplication(@PathVariable(\"application\") final String application)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", application);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Application reqApplication = new Application();
                reqApplication.setGuid(application);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", reqApplication);
                }

                // get a list of available servers
                ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                appRequest.setRequestInfo(reqInfo);
                appRequest.setUserAccount(userAccount);
                appRequest.setServiceId(this.applMgmt);
                appRequest.setApplication(reqApplication);
                appRequest.setApplicationId(this.appConfig.getApplicationId());
                appRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", appRequest);
                }

                ApplicationManagementResponse appRes = appMgr.deleteApplicationData(appRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", appRes);
                }

                if (appRes.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    mView.addObject(Constants.RESPONSE_MESSAGE, this.messageApplicationRetired);
                    mView.setViewName(this.defaultPage);
                }
                else if (appRes.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/retrieve-files/application/{application}", method = RequestMethod.GET)
    public final ModelAndView showRetrieveFilesPage(@PathVariable("application") final String application)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showRetrieveFilesPage(@PathVariable(\"application\") final String application)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", application);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            // validate the user has access
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Application appl = new Application();
                appl.setGuid(application);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", appl);
                }

                ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                appRequest.setApplication(appl);
                appRequest.setRequestInfo(reqInfo);
                appRequest.setUserAccount(userAccount);
                appRequest.setServiceId(this.applMgmt);
                appRequest.setApplicationId(this.appConfig.getApplicationId());
                appRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", appRequest);
                }

                ApplicationManagementResponse appResponse = appMgr.getApplicationData(appRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", appResponse);
                }

                if (appResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    Application app = appResponse.getApplication();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("Application: {}", app);
                    }

                    if (app != null)
                    {
                        List<Service> platformList = app.getPlatforms();

                        if (DEBUG)
                        {
                            DEBUGGER.debug("platformList: {}", platformList);
                        }

                        if ((platformList != null) && (platformList.size() != 0))
                        {
                            mView.addObject("platformList", platformList);
                            mView.addObject("application", app);
                            mView.setViewName(this.retrieveFilesPage);
                        }
                        else
                        {
                            mView.addObject(Constants.ERROR_MESSAGE, this.messageNoPlatformAssigned);
                            mView.setViewName(this.defaultPage);
                        }
                    }
                    else
                    {
                        mView.addObject(Constants.ERROR_MESSAGE, this.messageNoApplicationsFound);
                        mView.setViewName(this.defaultPage);
                    }
                }
                else if (appResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/retrieve-files/application/{application}/platform/{platform}", method = RequestMethod.GET)
    public final ModelAndView showRetrieveFilesPage(@PathVariable("application") final String application, @PathVariable("platform") final String platform)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showRetrieveFilesPage(@PathVariable(\"application\") final String application, @PathVariable(\"platform\") final String platform)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", platform);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IPlatformManagementProcessor platformMgr = new PlatformManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            // validate the user has access
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Application app = new Application();
                app.setGuid(application);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", app);
                }

                Service reqPlatform = new Service();
                reqPlatform.setGuid(platform);

                if (DEBUG)
                {
                    DEBUGGER.debug("Service: {}", reqPlatform);
                }

                ServiceManagementRequest platformRequest = new ServiceManagementRequest();
                platformRequest.setUserAccount(userAccount);
                platformRequest.setRequestInfo(reqInfo);
                platformRequest.setServiceId(this.platformMgmt);
                platformRequest.setPlatform(reqPlatform);
                platformRequest.setApplicationId(this.appConfig.getApplicationId());
                platformRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ServiceManagementRequest: {}", platformRequest);
                }

                ServiceManagementResponse platformResponse = platformMgr.getPlatformData(platformRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ServiceManagementResponse: {}", platformResponse);
                }

                if (platformResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    Service resPlatform = platformResponse.getPlatformData();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("Service: {}", resPlatform);
                    }

                    if (resPlatform != null)
                    {
                        List<Server> servers = resPlatform.getServers();

                        if (DEBUG)
                        {
                            DEBUGGER.debug("List<Server>: {}", servers);
                        }

                        mView.addObject("platform", resPlatform);
                        mView.addObject("servers", servers);
                        mView.addObject("application", app);
                        mView.setViewName(this.retrieveFilesPage);
                    }
                    else
                    {
                        mView.addObject(Constants.ERROR_MESSAGE, this.messageNoPlatformAssigned);
                        mView.setViewName(this.defaultPage);
                    }
                }
                else if (platformResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ServiceManagementException pmx)
            {
                ERROR_RECORDER.error(pmx.getMessage(), pmx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/retrieve-files/application/{application}/platform/{platform}/server/{server}", method = RequestMethod.GET)
    public final ModelAndView showRetrieveFilesPage(@PathVariable("application") final String application, @PathVariable("platform") final String platform, @PathVariable("server") final String server)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showRetrieveFilesPage(@PathVariable(\"application\") final String application, @PathVariable(\"server\") final String server)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", application);
            DEBUGGER.debug("Value: {}", server);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            // validate the user has access
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Service reqPlatform = new Service();
                reqPlatform.setGuid(platform);

                if (DEBUG)
                {
                    DEBUGGER.debug("Service: {}", reqPlatform);
                }

                Application appl = new Application();
                appl.setGuid(application);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", appl);
                }

                Server targetServer = new Server();
                targetServer.setServerGuid(server);

                if (DEBUG)
                {
                    DEBUGGER.debug("Server: {}", targetServer);
                }

                ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                appRequest.setApplication(appl);
                appRequest.setRequestInfo(reqInfo);
                appRequest.setUserAccount(userAccount);
                appRequest.setServiceId(this.applMgmt);
                appRequest.setServer(targetServer);
                appRequest.setApplicationId(this.appConfig.getApplicationId());
                appRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", appRequest);
                }

                ApplicationManagementResponse appResponse = appMgr.applicationFileRequest(appRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", appResponse);
                }

                if (appResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    List<String> fileList = appResponse.getFileList();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("List<String>: {}", fileList);
                    }

                    if ((fileList != null) && (fileList.size() != 0))
                    {
                        mView.addObject("fileList", fileList);
                        mView.addObject("application", appl);
                        mView.addObject("server", targetServer);
                        mView.addObject("platform", reqPlatform);
                        mView.addObject("currentPath", appResponse.getApplication().getInstallPath());
                        mView.setViewName(this.retrieveFilesPage);
                    }
                }
                else if (appResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/list-files/application/{application}/platform/{platform}/server/{server}", method = RequestMethod.GET)
    public final ModelAndView showListFiles(@PathVariable("application") final String application, @PathVariable("platform") final String platform, @PathVariable("server") final String server, @RequestParam(value = "vpath", required = true) final String vpath)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showListFiles(@PathVariable(\"application\") final String application, @PathVariable(\"platform\") final String platform, @PathVariable(\"server\") final String server, @RequestParam(value = \"vpath\", required = true) final String vpath)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", application);
            DEBUGGER.debug("Value: {}", server);
            DEBUGGER.debug("Value: {}", vpath);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            // validate the user has access
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Service reqPlatform = new Service();
                reqPlatform.setGuid(platform);

                if (DEBUG)
                {
                    DEBUGGER.debug("Service: {}", reqPlatform);
                }

                Server targetServer = new Server();
                targetServer.setServerGuid(server);

                if (DEBUG)
                {
                    DEBUGGER.debug("Server: {}", targetServer);
                }

                Application targetApp = new Application();
                targetApp.setGuid(application);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", targetApp);
                }

                ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                appRequest.setApplication(targetApp);
                appRequest.setRequestInfo(reqInfo);
                appRequest.setUserAccount(userAccount);
                appRequest.setServiceId(this.applMgmt);
                appRequest.setServer(targetServer);
                appRequest.setRequestFile(vpath);
                appRequest.setApplicationId(this.appConfig.getApplicationId());
                appRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", appRequest);
                }

                ApplicationManagementResponse appResponse = appMgr.applicationFileRequest(appRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", appResponse);
                }

                if (appResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    // we're going to go out, get a list of files/directories
                    // in the base of the application, and return that back here
                    // then list them out as links on the display
                    // need a way to ensure the existing selected path is here
                    // as well as the newly selected path too
                    if (appResponse.getFileData() != null)
                    {
                        byte[] fileData = appResponse.getFileData();

                        if (DEBUG)
                        {
                            DEBUGGER.debug("fileData: {}", fileData);
                        }

                        if ((fileData != null) && (fileData.length != 0))
                        {
                            String dataString = IOUtils.toString(fileData, this.appConfig.getFileEncoding());

                            if (DEBUG)
                            {
                                DEBUGGER.debug("dataString: {}", dataString);
                            }

                            if (StringUtils.isNotEmpty(dataString))
                            {
                                dataString = StringUtils.replace(dataString, "<", "&lt;");
                                dataString = StringUtils.replace(dataString, ">", "&gt;");

                                if (DEBUG)
                                {
                                    DEBUGGER.debug("dataString: {}", dataString);
                                }

                                if (StringUtils.isNotEmpty(dataString))
                                {
                                    mView.addObject("server", targetServer);
                                    mView.addObject("platform", reqPlatform);
                                    mView.addObject("fileData", dataString);
                                    mView.addObject("application", appResponse.getApplication());
                                    mView.addObject("currentPath", vpath);
                                    mView.setViewName(this.viewFilePage);
                                }
                                else
                                {
                                    mView.addObject(Constants.ERROR_MESSAGE, this.messageNoFileData);
                                    mView.addObject("platform", reqPlatform);
                                    mView.addObject("server", targetServer);
                                    mView.addObject("application", appResponse.getApplication());
                                    mView.addObject("currentPath", vpath);
                                    mView.setViewName(this.viewFilePage);
                                }
                            }
                            else
                            {
                                mView.addObject(Constants.ERROR_MESSAGE, this.messageNoFileData);
                                mView.addObject("platform", reqPlatform);
                                mView.addObject("server", targetServer);
                                mView.addObject("application", appResponse.getApplication());
                                mView.addObject("currentPath", vpath);
                                mView.setViewName(this.viewFilePage);
                            }
                        }
                        else
                        {
                            mView.addObject(Constants.ERROR_MESSAGE, this.messageNoFileData);
                            mView.addObject("platform", reqPlatform);
                            mView.addObject("server", targetServer);
                            mView.addObject("application", appResponse.getApplication());
                            mView.addObject("currentPath", vpath);
                            mView.setViewName(this.viewFilePage);
                        }
                    }
                    else
                    {
                        List<String> fileList = appResponse.getFileList();

                        if (DEBUG)
                        {
                            DEBUGGER.debug("List<String>: {}", fileList);
                        }

                        mView.addObject("platform", reqPlatform);
                        mView.addObject("application", appResponse.getApplication());
                        mView.addObject("currentPath", vpath);
                        mView.addObject("server", targetServer);
                        mView.addObject("fileList", fileList);
                        mView.setViewName(this.retrieveFilesPage);
                    }
                }
                else if (appResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
            catch (IOException iox)
            {
                ERROR_RECORDER.error(iox.getMessage(), iox);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/deploy-application/application/{application}", method = RequestMethod.GET)
    public final ModelAndView showDeployApplication(@PathVariable("application") final String application)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showDeployApplication(@PathVariable(\"application\") final String application)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", application);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            // validate the user has access
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Application appl = new Application();
                appl.setGuid(application);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", appl);
                }

                ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                appRequest.setApplication(appl);
                appRequest.setRequestInfo(reqInfo);
                appRequest.setUserAccount(userAccount);
                appRequest.setServiceId(this.applMgmt);
                appRequest.setApplicationId(this.appConfig.getApplicationId());
                appRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", appRequest);
                }

                ApplicationManagementResponse appResponse = appMgr.getApplicationData(appRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", appResponse);
                }

                if (appResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    Application app = appResponse.getApplication();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("Application: {}", app);
                    }

                    if (app != null)
                    {
                        List<Service> appPlatforms = app.getPlatforms();

                        if (DEBUG)
                        {
                            DEBUGGER.debug("Service: {}", appPlatforms);
                        }

                        if ((appPlatforms != null) && (appPlatforms.size() != 0))
                        {
                            // add the server listing to the page
                            mView.addObject("application", app);
                            mView.addObject("platformList", appPlatforms);
                            mView.setViewName(this.deployAppPage);
                        }
                        else
                        {
                            mView.addObject(Constants.ERROR_MESSAGE, this.messageNoPlatformAssigned);
                            mView.setViewName(this.defaultPage);
                        }
                    }
                    else
                    {
                        mView.addObject(Constants.ERROR_MESSAGE, this.messageNoApplicationsFound);
                        mView.setViewName(this.defaultPage);
                    }
                }
                else if (appResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/deploy-application/application/{application}/platform/{platform}", method = RequestMethod.GET)
    public final ModelAndView showDeployApplication(@PathVariable("application") final String application, @PathVariable("platform") final String platform)
    {
        final String methodName = ApplicationManagementController.CNAME + "#showDeployApplication(@PathVariable(\"application\") final String application, @PathVariable(\"platform\") final String platform)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", application);
            DEBUGGER.debug("Value: {}", platform);
        }

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", application);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IPlatformManagementProcessor platformMgr = new PlatformManagementProcessorImpl();
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            // validate the user has access
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Application appl = new Application();
                appl.setGuid(application);

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", appl);
                }

                Service reqPlatform = new Service();
                reqPlatform.setGuid(platform);

                if (DEBUG)
                {
                    DEBUGGER.debug("Service: {}", reqPlatform);
                }

                ServiceManagementRequest platformRequest = new ServiceManagementRequest();
                platformRequest.setUserAccount(userAccount);
                platformRequest.setRequestInfo(reqInfo);
                platformRequest.setServiceId(this.platformMgmt);
                platformRequest.setPlatform(reqPlatform);
                platformRequest.setApplicationId(this.appConfig.getApplicationId());
                platformRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ServiceManagementRequest: {}", platformRequest);
                }

                ServiceManagementResponse platformResponse = platformMgr.getPlatformData(platformRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ServiceManagementResponse: {}", platformResponse);
                }

                if (platformResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    Service resPlatform = platformResponse.getPlatformData();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("Service: {}", resPlatform);
                    }

                    if (resPlatform != null)
                    {
                        // get the app info
                        ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                        appRequest.setApplication(appl);
                        appRequest.setRequestInfo(reqInfo);
                        appRequest.setUserAccount(userAccount);
                        appRequest.setServiceId(this.applMgmt);
                        appRequest.setApplicationId(this.appConfig.getApplicationId());
                        appRequest.setApplicationName(this.appConfig.getApplicationName());

                        if (DEBUG)
                        {
                            DEBUGGER.debug("ApplicationManagementRequest: {}", appRequest);
                        }

                        ApplicationManagementResponse appResponse = appMgr.getApplicationData(appRequest);

                        if (DEBUG)
                        {
                            DEBUGGER.debug("ApplicationManagementResponse: {}", appResponse);
                        }

                        if (appResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                        {
                            Application app = appResponse.getApplication();

                            if (DEBUG)
                            {
                                DEBUGGER.debug("Application: {}", app);
                            }

                            if (app != null)
                            {
                                // add the server listing to the page
                                mView.addObject("command", new ApplicationRequest());
                                mView.addObject("application", app);
                                mView.addObject("platform", resPlatform);
                                mView.setViewName(this.deployAppPage);
                            }
                            else
                            {
                                mView.addObject(Constants.ERROR_MESSAGE, this.messageNoApplicationsFound);
                                mView.setViewName(this.defaultPage);
                            }
                        }
                        else if (appResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                        {
                            mView.setViewName(this.appConfig.getUnauthorizedPage());
                        }
                        else
                        {
                            mView.setViewName(this.appConfig.getErrorResponsePage());
                        }
                    }
                    else
                    {
                        mView.addObject(Constants.ERROR_MESSAGE, this.messageNoPlatformAssigned);
                        mView.setViewName(this.defaultPage);
                    }
                }
                else if (platformResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ServiceManagementException pmx)
            {
                ERROR_RECORDER.error(pmx.getMessage(), pmx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/search", method = RequestMethod.POST)
    public final ModelAndView submitApplicationSearch(@ModelAttribute("application") final Application application, final BindingResult bindResult)
    {
        final String methodName = ApplicationManagementController.CNAME + "#submitApplicationSearch(@ModelAttribute(\"application\") final Application application, final BindingResult bindResult)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("SearchRequest: {}", application);
            DEBUGGER.debug("BindingResult: {}", bindResult);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor processor = new ApplicationManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                ApplicationManagementRequest request = new ApplicationManagementRequest();
                request.setApplication(application);
                request.setApplicationId(this.appConfig.getApplicationId());
                request.setApplicationName(this.appConfig.getApplicationName());
                request.setRequestInfo(reqInfo);
                request.setServiceId(this.applMgmt);
                request.setUserAccount(userAccount);

                if (DEBUG)
                {
                    DEBUGGER.debug("SearchRequest: {}", request);
                }

                ApplicationManagementResponse response = processor.listApplications(request);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", response);
                }

                if (response.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    mView.addObject("pages", (int) Math.ceil(response.getEntryCount() * 1.0 / this.recordsPerPage));
                    mView.addObject("page", 1);
                    mView.addObject("searchTerms", application.getName());
                    mView.addObject(Constants.SEARCH_RESULTS, response.getApplicationList());
                    mView.addObject("command", new Application());
                    mView.setViewName(this.defaultPage);
                }
                else if (response.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.addObject(Constants.ERROR_RESPONSE, this.appConfig.getMessageNoSearchResults());
                    mView.addObject("command", new Application());
                    mView.setViewName(this.defaultPage);
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/add-application", method = RequestMethod.POST)
    public final ModelAndView doAddApplication(@ModelAttribute("request") final ApplicationRequest request, final BindingResult bindResult)
    {
        final String methodName = ApplicationManagementController.CNAME + "#doAddApplication(@ModelAttribute(\"request\") final ApplicationRequest request, final BindingResult bindResult)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", request);
            DEBUGGER.debug("Value: {}", bindResult);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor processor = new ApplicationManagementProcessorImpl();
        final IPlatformManagementProcessor platformMgr = new PlatformManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            this.applicationValidator.validate(request, bindResult);

            if (bindResult.hasErrors())
            {
                // validation failed
                ERROR_RECORDER.error("Errors: {}", bindResult.getAllErrors());

                mView.addObject(Constants.ERROR_MESSAGE, this.appConfig.getMessageValidationFailed());
                mView.addObject("command", new ApplicationRequest());
                mView.setViewName(this.addAppPage);

                return mView;
            }

            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Service newPlatform = new Service();
                newPlatform.setGuid(request.getPlatform());

                if (DEBUG)
                {
                    DEBUGGER.debug("Service: {}", newPlatform);
                }

                Application newApp = new Application();
                newApp.setGuid(UUID.randomUUID().toString());
                newApp.setName(request.getApplicationName());
                newApp.setPlatforms(new ArrayList<>(Arrays.asList(newPlatform)));
                newApp.setVersion(request.getVersion());
                newApp.setLogsDirectory(request.getLogsPath());
                newApp.setInstallPath(request.getInstallPath());
                newApp.setPackageLocation(request.getScmPath());

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", newApp);
                }

                ApplicationManagementRequest appRequest = new ApplicationManagementRequest();
                appRequest.setApplication(newApp);
                appRequest.setServiceId(this.applMgmt);
                appRequest.setRequestInfo(reqInfo);
                appRequest.setUserAccount(userAccount);
                appRequest.setApplicationId(this.appConfig.getApplicationId());
                appRequest.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", request);
                }

                ApplicationManagementResponse response = processor.addNewApplication(appRequest);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", response);
                }

                if (response.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    // app added
                    ServiceManagementRequest platformReq = new ServiceManagementRequest();
                    platformReq.setRequestInfo(reqInfo);
                    platformReq.setServiceId(this.platformMgmt);
                    platformReq.setUserAccount(userAccount);
                    platformReq.setApplicationId(this.appConfig.getApplicationId());
                    platformReq.setApplicationName(this.appConfig.getApplicationName());

                    if (DEBUG)
                    {
                        DEBUGGER.debug("ServiceManagementRequest: {}", platformReq);
                    }

                    ServiceManagementResponse platformResponse = platformMgr.listPlatforms(platformReq);

                    if (DEBUG)
                    {
                        DEBUGGER.debug("ServiceManagementResponse: {}", platformResponse);
                    }

                    if (platformResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                    {
                        List<Service> platformList = platformResponse.getPlatformList();

                        if (DEBUG)
                        {
                            DEBUGGER.debug("platformList: {}", platformList);
                        }

                        if ((platformList != null) && (platformList.size() != 0))
                        {
                            Map<String, String> platformListing = new HashMap<>();

                            for (Service platform : platformList)
                            {
                                if (DEBUG)
                                {
                                    DEBUGGER.debug("Service: {}", platform);
                                }

                                platformListing.put(platform.getGuid(), platform.getName());
                            }

                            if (DEBUG)
                            {
                                DEBUGGER.debug("platformListing: {}", platformListing);
                            }

                            mView.addObject("platformListing", platformListing);
                        }
                    }
                    else if (platformResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                    {
                        mView.setViewName(this.appConfig.getUnauthorizedPage());

                        return mView;
                    }

                    mView.addObject(Constants.RESPONSE_MESSAGE, this.messageApplicationAdded);
                    mView.addObject("command", new ApplicationRequest());
                    mView.setViewName(this.addAppPage);
                }
                else if (response.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
            catch (ServiceManagementException pmx)
            {
                ERROR_RECORDER.error(pmx.getMessage(), pmx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/deploy-application", method = RequestMethod.POST)
    public final ModelAndView doDeployApplication(@ModelAttribute("request") final ApplicationRequest request, final BindingResult bindResult)
    {
        final String methodName = ApplicationManagementController.CNAME + "#doDeployApplication(@ModelAttribute(\"request\") final ApplicationRequest request, final BindingResult bindResult)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", request);
            DEBUGGER.debug("Value: {}", bindResult);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IApplicationManagementProcessor appMgr = new ApplicationManagementProcessorImpl();
        final IPlatformManagementProcessor platformMgr = new PlatformManagementProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            @SuppressWarnings("unchecked") Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String sessionElement = sessionEnumeration.nextElement();
                Object sessionValue = hSession.getAttribute(sessionElement);

                DEBUGGER.debug("Attribute: " + sessionElement + "; Value: " + sessionValue);
            }

            DEBUGGER.debug("Dumping request content:");
            @SuppressWarnings("unchecked") Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String requestElement = requestEnumeration.nextElement();
                Object requestValue = hRequest.getAttribute(requestElement);

                DEBUGGER.debug("Attribute: " + requestElement + "; Value: " + requestValue);
            }

            DEBUGGER.debug("Dumping request parameters:");
            @SuppressWarnings("unchecked") Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String requestElement = paramsEnumeration.nextElement();
                Object requestValue = hRequest.getParameter(requestElement);

                DEBUGGER.debug("Parameter: " + requestElement + "; Value: " + requestValue);
            }
        }

        if (this.appConfig.getServices().get(this.serviceName))
        {
            this.deploymentValidator.validate(request, bindResult);

            if (bindResult.hasErrors())
            {
                // validation failed
                mView = new ModelAndView(new RedirectView());
                mView.setViewName(this.viewAppPage + "/application/" + request.getApplicationGuid());

                if (DEBUG)
                {
                    DEBUGGER.debug("ModelAndView: {}", mView);
                }

                return mView;
            }

            // validate the user has access
            try
            {
                RequestHostInfo reqInfo = new RequestHostInfo();
                reqInfo.setHostName(hRequest.getRemoteHost());
                reqInfo.setHostAddress(hRequest.getRemoteAddr());
                reqInfo.setSessionId(hSession.getId());

                if (DEBUG)
                {
                    DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
                }

                Application reqApplication = new Application();
                reqApplication.setGuid(request.getApplicationGuid());

                if (DEBUG)
                {
                    DEBUGGER.debug("Application: {}", reqApplication);
                }

                // get a list of available servers
                ApplicationManagementRequest appReq = new ApplicationManagementRequest();
                appReq.setRequestInfo(reqInfo);
                appReq.setUserAccount(userAccount);
                appReq.setServiceId(this.applMgmt);
                appReq.setApplication(reqApplication);
                appReq.setApplicationId(this.appConfig.getApplicationId());
                appReq.setApplicationName(this.appConfig.getApplicationName());

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementRequest: {}", appReq);
                }

                ApplicationManagementResponse appRes = appMgr.getApplicationData(appReq);

                if (DEBUG)
                {
                    DEBUGGER.debug("ApplicationManagementResponse: {}", appRes);
                }

                if (appRes.getRequestStatus() == CoreServicesStatus.SUCCESS)
                {
                    Application resApplication = appRes.getApplication();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("Application: {}", resApplication);
                    }

                    // have the application, get the platform
                    Service reqPlatform = new Service();
                    reqPlatform.setGuid(request.getPlatform());

                    if (DEBUG)
                    {
                        DEBUGGER.debug("Service: {}", reqPlatform);
                    }

                    ServiceManagementRequest platformRequest = new ServiceManagementRequest();
                    platformRequest.setUserAccount(userAccount);
                    platformRequest.setRequestInfo(reqInfo);
                    platformRequest.setServiceId(this.platformMgmt);
                    platformRequest.setPlatform(reqPlatform);
                    platformRequest.setApplicationId(this.appConfig.getApplicationId());
                    platformRequest.setApplicationName(this.appConfig.getApplicationName());

                    if (DEBUG)
                    {
                        DEBUGGER.debug("ServiceManagementRequest: {}", platformRequest);
                    }

                    ServiceManagementResponse platformResponse = platformMgr.getPlatformData(platformRequest);

                    if (DEBUG)
                    {
                        DEBUGGER.debug("ServiceManagementResponse: {}", platformResponse);
                    }

                    if (platformResponse.getRequestStatus() == CoreServicesStatus.SUCCESS)
                    {
                        Service resPlatform = platformResponse.getPlatformData();

                        if (DEBUG)
                        {
                            DEBUGGER.debug("Service: {}", resPlatform);
                        }

                        if (resPlatform != null)
                        {
                            // excellent
                            if (StringUtils.isNotEmpty(resApplication.getInstallPath()))
                            {
                                // this is an scm build. make sure the version number was populated
                                if ((request.getVersion() == 0.0) || (resApplication.getVersion() == request.getVersion()))
                                {
                                    // good. at this point we're going to download the files and then
                                    // well, do something.. not really sure how this is gonna work out
                                    // quite yet.
                                    mView.addObject(Constants.RESPONSE_MESSAGE, this.messageFileUploaded);
                                    mView.addObject("application", resApplication);
                                    mView.setViewName(this.viewAppPage);
                                }
                                else
                                {
                                    // whoops.
                                    mView.addObject(Constants.ERROR_MESSAGE, this.messageNoAppVersionProvided);
                                    mView.addObject("command", new ApplicationRequest());
                                    mView.addObject("application", resApplication);
                                    mView.addObject("platform", resPlatform);
                                    mView.setViewName(this.deployAppPage);
                                }
                            }
                            else
                            {
                                // we should have a binary file attached to the request
                                if (request.getApplicationBinary() != null)
                                {
                                    // excellent
                                    MultipartFile binary = request.getApplicationBinary();
                                    File repository = FileUtils.getFile(this.appConfig.getUploadDirectory());

                                    if (DEBUG)
                                    {
                                        DEBUGGER.debug("MultipartFile: {}", binary);
                                    }

                                    if (binary != null)
                                    {
                                        FileUtils.writeByteArrayToFile(FileUtils.getFile(repository, binary.getOriginalFilename()), binary.getBytes());

                                        // all set here
                                        mView.addObject(Constants.RESPONSE_MESSAGE, this.messageFileUploaded);
                                        mView.addObject("application", resApplication);
                                        mView.setViewName(this.viewAppPage);
                                    }
                                    else
                                    {
                                        // no files
                                        // add the server listing to the page
                                        mView.addObject(Constants.ERROR_MESSAGE, this.messageNoBinaryProvided);
                                        mView.addObject("command", new ApplicationRequest());
                                        mView.addObject("application", resApplication);
                                        mView.addObject("platform", resPlatform);
                                        mView.setViewName(this.deployAppPage);
                                    }
                                }
                                else
                                {
                                    mView.addObject(Constants.ERROR_MESSAGE, this.messageNoBinaryProvided);
                                    mView.addObject("command", new ApplicationRequest());
                                    mView.addObject("application", resApplication);
                                    mView.addObject("platform", resPlatform);
                                    mView.setViewName(this.deployAppPage);
                                }
                            }
                        }
                        else
                        {
                            // no platform
                            mView.addObject(Constants.ERROR_MESSAGE, this.messageNoPlatformAssigned);
                            mView.setViewName(this.appConfig.getErrorResponsePage());
                        }
                    }
                    else if (platformResponse.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                    {
                        mView.setViewName(this.appConfig.getUnauthorizedPage());
                    }
                    else
                    {
                        // error
                        mView.setViewName(this.appConfig.getErrorResponsePage());
                    }
                }
                else if (appRes.getRequestStatus() == CoreServicesStatus.UNAUTHORIZED)
                {
                    mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            catch (ApplicationManagementException amx)
            {
                ERROR_RECORDER.error(amx.getMessage(), amx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
            catch (ServiceManagementException pmx)
            {
                ERROR_RECORDER.error(pmx.getMessage(), pmx);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
            catch (IOException iox)
            {
                ERROR_RECORDER.error(iox.getMessage(), iox);

                mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        else
        {
            mView.setViewName(this.appConfig.getUnavailablePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }
}
