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
 *
 */
package com.cws.esolutions.web.controllers;
/*
 * Project: eSolutions_java_source
 * Package: com.cws.esolutions.web.controllers
 * File: UserManagementController.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly          11/23/2008 22:39:20             Created.
 */
import java.util.Date;
import java.util.List;
import java.util.Enumeration;
import org.springframework.ui.Model;
import javax.servlet.http.HttpSession;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;
import javax.servlet.http.HttpServletRequest;
import org.springframework.mail.MailException;
import org.springframework.stereotype.Controller;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.validation.BindingResult;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.cws.esolutions.web.Constants;
import com.cws.esolutions.security.dto.UserAccount;
import com.cws.esolutions.web.ApplicationServiceBean;
import com.cws.esolutions.security.processors.dto.AuditEntry;
import com.cws.esolutions.web.validators.UserAccountValidator;
import com.cws.esolutions.security.processors.dto.AuditRequest;
import com.cws.esolutions.security.enums.SecurityRequestStatus;
import com.cws.esolutions.security.processors.dto.AuditResponse;
import com.cws.esolutions.security.processors.dto.RequestHostInfo;
import com.cws.esolutions.security.processors.impl.AuditProcessorImpl;
import com.cws.esolutions.security.processors.dto.AccountSearchRequest;
import com.cws.esolutions.security.processors.dto.AccountControlRequest;
import com.cws.esolutions.security.processors.dto.AccountSearchResponse;
import com.cws.esolutions.security.processors.dto.AccountControlResponse;
import com.cws.esolutions.security.processors.interfaces.IAuditProcessor;
import com.cws.esolutions.security.processors.impl.AccountSearchProcessorImpl;
import com.cws.esolutions.security.processors.exception.AuditServiceException;
import com.cws.esolutions.security.processors.exception.AccountSearchException;
import com.cws.esolutions.security.processors.impl.AccountControlProcessorImpl;
import com.cws.esolutions.security.processors.exception.AccountControlException;
import com.cws.esolutions.security.processors.interfaces.IAccountSearchProcessor;
import com.cws.esolutions.security.processors.interfaces.IAccountControlProcessor;
/**
 * @author cws-khuntly
 * @version 1.0
 * @see org.springframework.stereotype.Controller
 */
@Controller
@RequestMapping("user-management")
public class UserManagementController
{
    private String resetURL = null;
    private int recordsPerPage = 20;
    private String viewUserPage = null;
    private String viewAuditPage = null;
    private String createUserPage = null;
    private String searchUsersPage = null;
    private JavaMailSender mailSender = null;
    private String messageAddUserFailed = null;
    private String messageAddUserSuccess = null;
    private UserAccountValidator validator = null;
    private String messageRoleChangeSuccess = null;
    private ApplicationServiceBean appConfig = null;
    private String messageAccountLockSuccess = null;
    private SimpleMailMessage adminResetEmail = null;
    private String messageAccountResetSuccess = null;
    private String messageAccountUnlockSuccess = null;
    private String messageAccountSuspendSuccess = null;
    private String messageAccountUnsuspendSuccess = null;

    private static final String CNAME = UserManagementController.class.getName();
    private static final String ADD_USER_REDIRECT = "redirect:/ui/user-management/add-user";

    private static final Logger DEBUGGER = LogManager.getLogger(Constants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LogManager.getLogger(Constants.ERROR_LOGGER + CNAME);

    public final void setMailSender(final JavaMailSender value)
    {
        final String methodName = UserManagementController.CNAME + "#setMailSender(final JavaMailSender value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.mailSender = value;
    }

    public final void setValidator(final UserAccountValidator value)
    {
        final String methodName = UserManagementController.CNAME + "#setValidator(final UserAccountValidator value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.validator = value;
    }

    public final void setRecordsPerPage(final int value)
    {
        final String methodName = UserManagementController.CNAME + "#setRecordsPerPage(final int value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.recordsPerPage = value;
    }

    public final void setViewUserPage(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setViewUserPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.viewUserPage = value;
    }

    public final void setViewAuditPage(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setViewAuditPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.viewAuditPage = value;
    }

    public final void setCreateUserPage(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setCreateUserPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.createUserPage = value;
    }

    public final void setSearchUsersPage(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setSearchUsersPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.searchUsersPage = value;
    }

    public final void setMessageAccountResetSuccess(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setMessageResetComplete(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageAccountResetSuccess = value;
    }

    public final void setMessageAccountLockSuccess(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setMessageAccountLocked(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageAccountLockSuccess = value;
    }

    public final void setMessageAccountUnlockSuccess(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setMessageAccountUnlockSuccess(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageAccountUnlockSuccess = value;
    }

    public final void setMessageAccountUnsuspendSuccess(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setMessageAccountUnsuspendSuccess(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageAccountUnsuspendSuccess = value;
    }

    public final void setMessageAccountSuspendSuccess(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setMessageAccountSuspendSuccess(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageAccountSuspendSuccess = value;
    }

    public final void setMessageRoleChangeSuccess(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setMessageRoleChangeSuccess(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageRoleChangeSuccess = value;
    }

    public final void setAppConfig(final ApplicationServiceBean value)
    {
        final String methodName = UserManagementController.CNAME + "#setAppConfig(final ApplicationServiceBean value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.appConfig = value;
    }

    public final void setResetURL(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setResetURL(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.resetURL = value;
    }

    public final void setAdminResetEmail(final SimpleMailMessage value)
    {
        final String methodName = UserManagementController.CNAME + "#setAdminResetEmail(final SimpleMailMessage value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.adminResetEmail = value;
    }

    public final void setMessageAddUserSuccess(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setMessageAddUserSuccess(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageAddUserSuccess = value;
    }

    public final void setMessageAddUserFailed(final String value)
    {
        final String methodName = UserManagementController.CNAME + "#setMessageAddUserFailed(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageAddUserFailed = value;
    }

    @RequestMapping(value = "/default", method = RequestMethod.GET)
    public final ModelAndView showDefaultPage(final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#showDefaultPage(final Model model)";

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
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        mView.addObject(Constants.COMMAND, new AccountSearchRequest());
        mView.setViewName(this.searchUsersPage);

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/add-user", method = RequestMethod.GET)
    public final ModelAndView showAddUser(final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#showAddUser(final Model model)";

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
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

    	// mView.addObject("roles", availableRoles);
    	mView.addObject(Constants.COMMAND, new UserAccount());
    	mView.setViewName(this.createUserPage);

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/view/account/{userGuid}", method = RequestMethod.GET)
    public final ModelAndView showAccountData(@PathVariable("userGuid") final String userGuid, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#showAccountData(@PathVariable(\"userGuid\") final String userGuid, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("userGuid: {}", userGuid);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountControlProcessor processor = (IAccountControlProcessor) new AccountControlProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            // ensure authenticated access
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            UserAccount searchAccount = new UserAccount();
            searchAccount.setGuid(userGuid);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", searchAccount);
            }

            AccountControlRequest request = new AccountControlRequest();
            request.setHostInfo(reqInfo);
            request.setUserAccount(searchAccount);
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setRequestor(userAccount);
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setApplicationName(this.appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlRequest: {}", request);
            }

            AccountControlResponse response = processor.loadUserAccount(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                if (response.getUserAccount() != null)
                {
                    // mView.addObject("userRoles", Role.values());
                	mView.addObject("userAccount", response.getUserAccount());
                	mView.setViewName(this.viewUserPage);
                }
                else
                {
                	mView.addObject(Constants.ERROR_MESSAGE, this.appConfig.getMessageNoSearchResults());
                	mView.setViewName(this.searchUsersPage);
                }
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AccountControlException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/audit/account/{userGuid}", method = RequestMethod.GET)
    public final ModelAndView showAuditData(@PathVariable("userGuid") final String userGuid, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#showAuditData(@PathVariable(\"userGuid\") final String userGuid, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAuditProcessor processor = (IAuditProcessor) new AuditProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            UserAccount searchAccount = new UserAccount();
            searchAccount.setGuid(userGuid);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", searchAccount);
            }

            AuditEntry entry = new AuditEntry();
            entry.setUserAccount(searchAccount);

            if (DEBUG)
            {
                DEBUGGER.debug("AuditEntry: {}", entry);
            }

            AuditRequest request = new AuditRequest();
            request.setUserAccount(userAccount);
            request.setAuditEntry(entry);
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setApplicationName(this.appConfig.getApplicationName());
            request.setHostInfo(reqInfo);

            if (DEBUG)
            {
                DEBUGGER.debug("AuditRequest: {}", request);
            }

            AuditResponse response = processor.getAuditEntries(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                List<AuditEntry> auditEntries = response.getAuditList();

                if (DEBUG)
                {
                    DEBUGGER.debug("List<AuditEntry>: {}", auditEntries);
                }

                if ((auditEntries != null) && (auditEntries.size() != 0))
                {
                    mView.addObject("pages", (int) Math.ceil(response.getEntryCount() * 1.0 / this.recordsPerPage));
                    mView.addObject("page", 1);
                    mView.addObject("auditEntries", auditEntries);
                }
                else
                {
                	mView.addObject(Constants.ERROR_RESPONSE, this.appConfig.getMessageNoSearchResults());
                }

                mView.setViewName(this.viewAuditPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AuditServiceException asx)
        {
            ERROR_RECORDER.error(asx.getMessage(), asx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/audit/account/{userGuid}/page/{page}", method = RequestMethod.GET)
    public final ModelAndView showAuditData(@PathVariable("userGuid") final String userGuid, @PathVariable("page") final int page, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#showAuditData(@PathVariable(\"userGuid\") final String userGuid, @PathVariable(\"page\") final int page, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
            DEBUGGER.debug("Value: {}", page);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAuditProcessor processor = (IAuditProcessor) new AuditProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            UserAccount searchAccount = new UserAccount();
            searchAccount.setGuid(userGuid);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", searchAccount);
            }

            AuditEntry entry = new AuditEntry();
            entry.setUserAccount(searchAccount);

            if (DEBUG)
            {
                DEBUGGER.debug("AuditEntry: {}", entry);
            }

            AuditRequest request = new AuditRequest();
            request.setUserAccount(userAccount);
            request.setAuditEntry(entry);
            request.setStartRow(page);
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setApplicationName(this.appConfig.getApplicationName());
            request.setHostInfo(reqInfo);

            if (DEBUG)
            {
                DEBUGGER.debug("AuditRequest: {}", request);
            }

            AuditResponse response = processor.getAuditEntries(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                List<AuditEntry> auditEntries = response.getAuditList();

                if (DEBUG)
                {
                    DEBUGGER.debug("List<AuditEntry>: {}", auditEntries);
                }

                if ((auditEntries != null) && (auditEntries.size() != 0))
                {
                    mView.addObject("pages", (int) Math.ceil(response.getEntryCount() * 1.0 / this.recordsPerPage));
                    mView.addObject("page", page);
                    mView.addObject("auditEntries", auditEntries);
                }
                else
                {
                	mView.addObject(Constants.ERROR_RESPONSE, this.appConfig.getMessageNoSearchResults());
                }

                mView.setViewName(this.viewAuditPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AuditServiceException asx)
        {
            ERROR_RECORDER.error(asx.getMessage(), asx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/lock/account/{userGuid}", method = RequestMethod.GET)
    public final ModelAndView lockUserAccount(@PathVariable("userGuid") final String userGuid, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#lockUserAccount(@PathVariable(\"userGuid\") final String userGuid, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountControlProcessor processor = (IAccountControlProcessor) new AccountControlProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            UserAccount account = new UserAccount();
            account.setGuid(userGuid);
            account.setFailedCount(3);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", account);
            }

            AccountControlRequest request = new AccountControlRequest();
            request.setHostInfo(reqInfo);
            request.setUserAccount(account);
            request.setApplicationName(this.appConfig.getApplicationName());
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setRequestor(userAccount);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlRequest: {}", request);
            }

            AccountControlResponse response = processor.modifyUserLockout(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
            	mView.addObject(Constants.RESPONSE_MESSAGE, this.messageAccountLockSuccess);
            	mView.addObject("userAccount", response.getUserAccount());
            	mView.setViewName(this.viewUserPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AccountControlException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/unlock/account/{userGuid}", method = RequestMethod.GET)
    public final ModelAndView unlockUserAccount(@PathVariable("userGuid") final String userGuid, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#unlockUserAccount(@PathVariable(\"userGuid\") final String userGuid, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountControlProcessor processor = (IAccountControlProcessor) new AccountControlProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            UserAccount account = new UserAccount();
            account.setGuid(userGuid);
            account.setFailedCount(0);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", account);
            }

            AccountControlRequest request = new AccountControlRequest();
            request.setHostInfo(reqInfo);
            request.setUserAccount(account);
            request.setApplicationName(this.appConfig.getApplicationName());
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setRequestor(userAccount);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlRequest: {}", request);
            }

            AccountControlResponse response = processor.modifyUserLockout(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
            	mView.addObject(Constants.RESPONSE_MESSAGE, this.messageAccountUnlockSuccess);
            	mView.addObject("userAccount", response.getUserAccount());
            	mView.setViewName(this.viewUserPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AccountControlException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/suspend/account/{userGuid}", method = RequestMethod.GET)
    public final ModelAndView suspendUserAccount(@PathVariable("userGuid") final String userGuid, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#suspendUserAccount(@PathVariable(\"userGuid\") final String userGuid, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountControlProcessor processor = (IAccountControlProcessor) new AccountControlProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            UserAccount account = new UserAccount();
            account.setGuid(userGuid);
            account.setSuspended(true);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", account);
            }

            AccountControlRequest request = new AccountControlRequest();
            request.setHostInfo(reqInfo);
            request.setUserAccount(account);
            request.setApplicationName(this.appConfig.getApplicationName());
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setRequestor(userAccount);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlRequest: {}", request);
            }

            AccountControlResponse response = processor.modifyUserSuspension(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
            	mView.addObject(Constants.RESPONSE_MESSAGE, this.messageAccountSuspendSuccess);
                // mView.addObject("userRoles", Role.values());
            	mView.addObject("userAccount", response.getUserAccount());
            	mView.setViewName(this.viewUserPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AccountControlException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/unsuspend/account/{userGuid}", method = RequestMethod.GET)
    public final ModelAndView unsuspendUserAccount(@PathVariable("userGuid") final String userGuid, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#unsuspendUserAccount(@PathVariable(\"userGuid\") final String userGuid, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountControlProcessor processor = (IAccountControlProcessor) new AccountControlProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            UserAccount account = new UserAccount();
            account.setGuid(userGuid);
            account.setSuspended(false);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", account);
            }

            AccountControlRequest request = new AccountControlRequest();
            request.setHostInfo(reqInfo);
            request.setUserAccount(account);
            request.setApplicationName(this.appConfig.getApplicationName());
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setRequestor(userAccount);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlRequest: {}", request);
            }

            AccountControlResponse response = processor.modifyUserSuspension(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
            	mView.addObject(Constants.RESPONSE_MESSAGE, this.messageAccountUnsuspendSuccess);
            	mView.addObject("userAccount", response.getUserAccount());
            	mView.setViewName(this.viewUserPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AccountControlException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/reset/account/{userGuid}", method = RequestMethod.GET)
    public final ModelAndView resetUserAccount(@PathVariable("userGuid") final String userGuid, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#resetUserAccount(@PathVariable(\"userGuid\") final String userGuid, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountControlProcessor processor = (IAccountControlProcessor) new AccountControlProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            // load the user account
            UserAccount searchAccount = new UserAccount();
            searchAccount.setGuid(userGuid);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", searchAccount);
            }

            AccountControlRequest request = new AccountControlRequest();
            request.setHostInfo(reqInfo);
            request.setUserAccount(searchAccount);
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setRequestor(userAccount);
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setApplicationName(this.appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlRequest: {}", request);
            }

            AccountControlResponse response = processor.loadUserAccount(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                UserAccount account = response.getUserAccount();

                if (DEBUG)
                {
                    DEBUGGER.debug("UserAccount: {}", account);
                }

                AccountControlRequest resetReq = new AccountControlRequest();
                resetReq.setHostInfo(reqInfo);
                resetReq.setUserAccount(account);
                resetReq.setApplicationName(this.appConfig.getApplicationName());
                resetReq.setApplicationId(this.appConfig.getApplicationId());
                resetReq.setRequestor(userAccount);

                if (DEBUG)
                {
                    DEBUGGER.debug("AccountResetRequest: {}", resetReq);
                }

                AccountControlResponse resetRes = processor.modifyUserPassword(request);

                if (DEBUG)
                {
                    DEBUGGER.debug("AccountResetResponse: {}", resetRes);
                }

                if (resetRes.getRequestStatus() == SecurityRequestStatus.SUCCESS)
                {
                    StringBuilder targetURL = new StringBuilder()
                        .append(hRequest.getScheme() + "://" + hRequest.getServerName())
                        .append((hRequest.getServerPort() == 443) ? null : ":" + hRequest.getServerPort())
                        .append(hRequest.getContextPath() + this.resetURL + resetRes.getResetId());

                    if (DEBUG)
                    {
                        DEBUGGER.debug("targetURL: {}", targetURL);
                    }

                    try
                    {
                    	SimpleMailMessage emailMessage = new SimpleMailMessage();
                    	emailMessage.setTo(this.adminResetEmail.getTo());
                    	emailMessage.setSubject(this.adminResetEmail.getSubject());
                    	emailMessage.setFrom(this.appConfig.getEmailAddress());
                    	emailMessage.setText(String.format(this.adminResetEmail.getText(),
                                account.getGivenName(),
                                new Date(System.currentTimeMillis()),
                                reqInfo.getHostName(),
                                targetURL.toString(),
                                8, 128));

                    	if (DEBUG)
                    	{
                    		DEBUGGER.debug("SimpleMailMessage: {}", emailMessage);
                    	}

                    	mailSender.send(emailMessage);
                    }
                    catch (final MailException mx)
                    {
                        ERROR_RECORDER.error(mx.getMessage(), mx);

                        mView.addObject(Constants.ERROR_MESSAGE, this.appConfig.getMessageEmailSendFailed());
                    }

                    mView.addObject(Constants.RESPONSE_MESSAGE, this.messageAccountResetSuccess);
                    mView.addObject("userAccount", response.getUserAccount());
                    mView.setViewName(this.viewUserPage);
                }
                else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
                {
                	mView.setViewName(this.appConfig.getUnauthorizedPage());
                }
                else
                {
                    // some failure occurred
                	mView.setViewName(this.appConfig.getErrorResponsePage());
                }
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
                // some failure occurred
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AccountControlException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/change-role/account/{userGuid}/role/{role}", method = RequestMethod.GET)
    public final ModelAndView changeUserRole(@PathVariable("userGuid") final String userGuid, @PathVariable("role") final String role, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#changeUserRole(@PathVariable(\"userGuid\") final String userGuid, @PathVariable(\"role\") final String role, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", userGuid);
            DEBUGGER.debug("Value: {}", role);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountControlProcessor processor = (IAccountControlProcessor) new AccountControlProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            UserAccount account = new UserAccount();
            account.setGuid(userGuid);

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", account);
            }

            AccountControlRequest request = new AccountControlRequest();
            request.setHostInfo(reqInfo);
            request.setUserAccount(account);
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setRequestor(userAccount);
            request.setApplicationId(this.appConfig.getApplicationId());
            request.setApplicationName(this.appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlRequest: {}", request);
            }

            AccountControlResponse response = processor.modifyUserRole(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountControlResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
            	mView.addObject("userAccount", response.getUserAccount());
            	mView.addObject(Constants.RESPONSE_MESSAGE, this.messageRoleChangeSuccess);
            	mView.setViewName(this.viewUserPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
                mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AccountControlException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/search", method = RequestMethod.POST)
    public final ModelAndView doSearchUsers(@ModelAttribute("request") final AccountSearchRequest request, final BindingResult bindResult, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#doSearchUsers(@ModelAttribute(\"request\") final AccountSearchRequest request, final BindingResult bindResult, final Model model)";

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
        final IAccountSearchProcessor searchProcessor = (IAccountSearchProcessor) new AccountSearchProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("Session ID: {}", hSession.getId());
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            // search accounts
            AccountSearchResponse response = searchProcessor.searchAccounts(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountSearchResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                if ((response.getUserList() != null) && (response.getUserList().size() != 0))
                {
                    List<UserAccount> userList = response.getUserList();

                    if (DEBUG)
                    {
                        DEBUGGER.debug("List<UserAccount> {}", userList);
                    }

                    mView.addObject("userList", userList);
                    mView.addObject("pages", (int) Math.ceil(response.getEntryCount() * 1.0 / this.recordsPerPage));
                    mView.addObject("page", 1);
                    mView.addObject(Constants.COMMAND, new AccountSearchRequest());
                    mView.addObject("searchResults", userList);
                }
                else
                {
                	mView.addObject(Constants.COMMAND, new UserAccount());
                	mView.addObject(Constants.ERROR_RESPONSE, this.appConfig.getMessageNoSearchResults());
                }

                mView.setViewName(this.searchUsersPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
            	mView.setViewName(this.appConfig.getUnauthorizedPage());
            }
            else
            {
            	mView.setViewName(this.appConfig.getErrorResponsePage());
            }
        }
        catch (final AccountSearchException asx)
        {
            ERROR_RECORDER.error(asx.getMessage(), asx);

            mView.setViewName(this.appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/add-user", method = RequestMethod.POST)
    public final ModelAndView doAddUser(@ModelAttribute("user") final UserAccount user, final BindingResult bindResult, final Model model)
    {
        final String methodName = UserManagementController.CNAME + "#doAddUser(@ModelAttribute(\"user\") final UserAccount user, final BindingResult bindResult, final Model model)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", user);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountControlProcessor processor = (IAccountControlProcessor) new AccountControlProcessorImpl();

        if (DEBUG)
        {
            DEBUGGER.debug("ServletRequestAttributes: {}", requestAttributes);
            DEBUGGER.debug("HttpServletRequest: {}", hRequest);
            DEBUGGER.debug("HttpSession: {}", hSession);
            DEBUGGER.debug("UserAccount: {}", userAccount);

            DEBUGGER.debug("Dumping session content:");
            Enumeration<String> sessionEnumeration = hSession.getAttributeNames();

            while (sessionEnumeration.hasMoreElements())
            {
                String element = sessionEnumeration.nextElement();
                Object value = hSession.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request content:");
            Enumeration<String> requestEnumeration = hRequest.getAttributeNames();

            while (requestEnumeration.hasMoreElements())
            {
                String element = requestEnumeration.nextElement();
                Object value = hRequest.getAttribute(element);

                DEBUGGER.debug("Attribute: {}; Value: {}", element, value);
            }

            DEBUGGER.debug("Dumping request parameters:");
            Enumeration<String> paramsEnumeration = hRequest.getParameterNames();

            while (paramsEnumeration.hasMoreElements())
            {
                String element = paramsEnumeration.nextElement();
                Object value = hRequest.getParameter(element);

                DEBUGGER.debug("Parameter: {}; Value: {}", element, value);
            }
        }

        this.validator.validate(user, bindResult);

        if (bindResult.hasErrors())
        {
            ERROR_RECORDER.error("Errors: {}", bindResult.getAllErrors());

            mView.addObject(Constants.ERROR_MESSAGE, this.appConfig.getMessageValidationFailed());
            mView.addObject(Constants.BIND_RESULT, bindResult.getAllErrors());
            mView.addObject(Constants.COMMAND, user);
            mView.setViewName(this.createUserPage);
        }
        else
        {
	        try
	        {
	            RequestHostInfo reqInfo = new RequestHostInfo();
	            reqInfo.setHostAddress(hRequest.getRemoteAddr());
	            reqInfo.setHostName(hRequest.getRemoteHost());
	
	            if (DEBUG)
	            {
	                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
	            }
	
	            UserAccount newUser = new UserAccount();
	            newUser.setGuid(user.getGuid());
	            newUser.setSurname(user.getSurname());
	            newUser.setFailedCount(user.getFailedCount());
	            newUser.setSuspended(user.isSuspended());
	            newUser.setDisplayName(user.getGivenName() + " " + user.getSurname());
	            newUser.setEmailAddr(user.getEmailAddr());
	            newUser.setGivenName(user.getGivenName());
	            newUser.setUsername(user.getUsername());
	
	            if (DEBUG)
	            {
	                DEBUGGER.debug("UserAccount: {}", newUser);
	            }

	            // search accounts
	            AccountControlRequest request = new AccountControlRequest();
	            request.setHostInfo(reqInfo);
	            request.setUserAccount(newUser);
	            request.setApplicationId(this.appConfig.getApplicationName());
	            request.setRequestor(userAccount);
	            request.setApplicationId(this.appConfig.getApplicationId());
	            request.setApplicationName(this.appConfig.getApplicationName());
	
	            if (DEBUG)
	            {
	                DEBUGGER.debug("AccountControlRequest: {}", request);
	            }
	
	            AccountControlResponse response = processor.createNewUser(request);
	
	            if (DEBUG)
	            {
	                DEBUGGER.debug("AccountControlResponse: {}", response);
	            }
	
	            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
	            {
	                // account created
	                AccountControlRequest resetReq = new AccountControlRequest();
	                resetReq.setHostInfo(reqInfo);
	                resetReq.setUserAccount(newUser);
	                resetReq.setApplicationId(this.appConfig.getApplicationName());
	                resetReq.setRequestor(userAccount);
	                resetReq.setApplicationId(this.appConfig.getApplicationId());
	                resetReq.setApplicationName(this.appConfig.getApplicationName());
	
	                if (DEBUG)
	                {
	                    DEBUGGER.debug("AccountControlRequest: {}", resetReq);
	                }
	
	                AccountControlResponse resetRes = processor.modifyUserPassword(resetReq);
	
	                if (DEBUG)
	                {
	                    DEBUGGER.debug("AccountControlResponse: {}", resetRes);
	                }
	
	                if (resetRes.getRequestStatus() == SecurityRequestStatus.SUCCESS)
	                {
	                    // good, send email
	                    UserAccount responseAccount = resetRes.getUserAccount();
	
	                    if (DEBUG)
	                    {
	                        DEBUGGER.debug("UserAccount: {}", responseAccount);
	                    }

	                    StringBuilder targetURL = new StringBuilder()
	                        .append(hRequest.getScheme() + "://" + hRequest.getServerName())
	                        .append((hRequest.getServerPort() == 443) ? null : ":" + hRequest.getServerPort())
	                        .append(hRequest.getContextPath() + this.resetURL + resetRes.getResetId());
	
	                    if (DEBUG)
	                    {
	                        DEBUGGER.debug("targetURL: {}", targetURL);
	                    }
	                        
	                    try
	                    {
	                    	SimpleMailMessage emailMessage = new SimpleMailMessage();
	                    	emailMessage.setTo(this.adminResetEmail.getTo());
	                    	emailMessage.setSubject(this.adminResetEmail.getSubject());
	                    	emailMessage.setFrom(this.appConfig.getEmailAddress());
	                    	emailMessage.setText(String.format(this.adminResetEmail.getText(),
	                                newUser.getGivenName(),
	                                new Date(System.currentTimeMillis()),
	                                reqInfo.getHostName(),
	                                targetURL.toString(),
	                                8, 128));
	
	                    	if (DEBUG)
	                    	{
	                    		DEBUGGER.debug("SimpleMailMessage: {}", emailMessage);
	                    	}
	
	                    	mailSender.send(emailMessage);
	                    }
	                    catch (final MailException mx)
	                    {
	                        ERROR_RECORDER.error(mx.getMessage(), mx);
	
	                        mView.addObject(Constants.ERROR_MESSAGE, this.appConfig.getMessageEmailSendFailed());
	                    }
	
	                    mView.addObject(Constants.RESPONSE_MESSAGE, this.messageAddUserSuccess);
	
	                    mView.setViewName(UserManagementController.ADD_USER_REDIRECT);
	                }
	                else
	                {
	                    // some failure occurred
	                	mView.addObject(Constants.ERROR_RESPONSE, this.messageAddUserFailed);
	                	mView.setViewName(this.appConfig.getErrorResponsePage());
	                }
	            }
	            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
	            {
	            	mView.setViewName(this.appConfig.getUnauthorizedPage());
	            }
	            else
	            {
	            	mView.setViewName(this.appConfig.getErrorResponsePage());
	            }
	        }
	        catch (final AccountControlException acx)
	        {
	            ERROR_RECORDER.error(acx.getMessage(), acx);
	
	            mView.setViewName(this.appConfig.getErrorResponsePage());
	        }
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }
}
