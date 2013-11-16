/**
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
package com.cws.us.esolutions.controllers;

import org.slf4j.Logger;
import java.util.Enumeration;
import org.slf4j.LoggerFactory;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.validation.BindingResult;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import com.cws.us.esolutions.Constants;
import com.cws.us.esolutions.dto.UserChangeRequest;
import com.cws.esolutions.security.dto.UserAccount;
import com.cws.esolutions.security.dto.UserSecurity;
import com.cws.us.esolutions.ApplicationServiceBean;
import com.cws.us.esolutions.validators.PasswordValidator;
import com.cws.us.esolutions.validators.TelephoneValidator;
import com.cws.esolutions.security.audit.dto.RequestHostInfo;
import com.cws.us.esolutions.validators.EmailAddressValidator;
import com.cws.esolutions.security.enums.SecurityRequestStatus;
import com.cws.esolutions.security.processors.enums.LoginStatus;
import com.cws.us.esolutions.validators.SecurityResponseValidator;
import com.cws.esolutions.security.processors.enums.ModificationType;
import com.cws.esolutions.security.processors.dto.AccountResetRequest;
import com.cws.esolutions.security.processors.dto.AccountResetResponse;
import com.cws.esolutions.security.processors.dto.AccountChangeRequest;
import com.cws.esolutions.security.processors.dto.AccountChangeResponse;
import com.cws.esolutions.security.processors.impl.AccountResetProcessorImpl;
import com.cws.esolutions.security.processors.impl.AccountChangeProcessorImpl;
import com.cws.esolutions.security.processors.exception.AccountResetException;
import com.cws.esolutions.security.processors.exception.AccountChangeException;
import com.cws.esolutions.security.processors.interfaces.IAccountResetProcessor;
import com.cws.esolutions.security.processors.interfaces.IAccountChangeProcessor;
/**
 * eSolutions_java_source
 * com.cws.us.esolutions.controllers
 * UserAccountController.java
 *
 * $Id$
 * $Author$
 * $Date$
 * $Revision$
 * @author kh05451
 * @version 1.0
 *
 * History
 * ----------------------------------------------------------------------------
 * kh05451 @ Jan 16, 2013 11:53:26 AM
 *     Created.
 * khuntly @ May 28, 2013 09:47:00 AM
 *     Finalized - individual user modification complete
 */
@Controller
@RequestMapping("/user-account")
public class UserAccountController
{
    private String myAccountPage = null;
    private String changeEmailPage = null;
    private String changeContactPage = null;
	private String changeKeysComplete = null;
    private String changeSecurityPage = null;
    private String changePasswordPage = null;
    private String changeEmailComplete = null;
    private String changeContactComplete = null;
    private String changePasswordComplete = null;
    private String changeSecurityComplete = null;
    private TelephoneValidator telValidator = null;
    private ApplicationServiceBean appConfig = null;
    private PasswordValidator passwordValidator = null;
    private EmailAddressValidator emailValidator = null;
    private SecurityResponseValidator securityValidator = null;

    private static final String CNAME = UserAccountController.class.getName();

    private static final Logger DEBUGGER = LoggerFactory.getLogger(Constants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(Constants.ERROR_LOGGER + CNAME);

    public final void setMyAccountPage(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setMyAccountPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.myAccountPage = value;
    }

    public final void setChangeEmailPage(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangeEmailPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changeEmailPage = value;
    }

    public final void setChangeSecurityPage(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangeSecurityPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changeSecurityPage = value;
    }

    public final void setChangePasswordPage(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangePasswordPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changePasswordPage = value;
    }

    public final void setChangeContactPage(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangeContactPage(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changeContactPage = value;
    }

    public final void setChangeEmailComplete(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangeEmailComplete(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changeEmailComplete = value;
    }

    public final void setChangePasswordComplete(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangePasswordComplete(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changePasswordComplete = value;
    }

    public final void setChangeSecurityComplete(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangeSecurityComplete(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changeSecurityComplete = value;
    }

    public final void setChangeContactComplete(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangeContactComplete(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changeContactComplete = value;
    }

    public final void setChangeKeysComplete(final String value)
    {
        final String methodName = UserAccountController.CNAME + "#setChangeKeysComplete(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.changeKeysComplete = value;
    }

    public final void setAppConfig(final ApplicationServiceBean value)
    {
        final String methodName = UserAccountController.CNAME + "#setAppConfig(final CoreServiceBean value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.appConfig = value;
    }

    public final void setPasswordValidator(final PasswordValidator value)
    {
        final String methodName = UserAccountController.CNAME + "#setPasswordValidator(final PasswordValidator value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.passwordValidator = value;
    }

    public final void setSecurityValidator(final SecurityResponseValidator value)
    {
        final String methodName = UserAccountController.CNAME + "#setSecurityValidator(final SecurityResponseValidator value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.securityValidator = value;
    }

    public final void setEmailValidator(final EmailAddressValidator value)
    {
        final String methodName = UserAccountController.CNAME + "#setEmailValidator(final EmailAddressValidator value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.emailValidator = value;
    }

    public final void setTelValidator(final TelephoneValidator value)
    {
        final String methodName = UserAccountController.CNAME + "#setTelValidator(final TelephoneValidator value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.telValidator = value;
    }

    @RequestMapping(value = "/default", method = RequestMethod.GET)
    public final ModelAndView showDefaultPage()
    {
        final String methodName = UserAccountController.CNAME + "#showDefaultPage()";

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

        mView.setViewName(this.myAccountPage);

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/password", method = RequestMethod.GET)
    public final ModelAndView showPasswordChange()
    {
        final String methodName = UserAccountController.CNAME + "#showPasswordChange()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        ModelAndView mView = new ModelAndView();
        UserChangeRequest changeReq = new UserChangeRequest();

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

        if ((userAccount.getStatus() == LoginStatus.RESET) || (userAccount.getStatus() == LoginStatus.EXPIRED))
        {
            mView.addObject(Constants.RESPONSE_MESSAGE, appConfig.getMessagePasswordExpired());
        }

        mView.addObject("command", changeReq);
        mView.setViewName(this.changePasswordPage);

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/security", method = RequestMethod.GET)
    public final ModelAndView showSecurityChange()
    {
        final String methodName = UserAccountController.CNAME + "#showSecurityChange()";

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

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostName(hRequest.getRemoteHost());
            reqInfo.setHostAddress(hRequest.getRemoteAddr());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            AccountResetRequest request = new AccountResetRequest();
            request.setHostInfo(reqInfo);
            request.setRequestor(userAccount);
            request.setUserAccount(userAccount);
            request.setApplicationId(appConfig.getApplicationId());
            request.setApplicationName(appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("AccountResetRequest: {}", request);
            }

            IAccountResetProcessor resetProcess = new AccountResetProcessorImpl();
            AccountResetResponse response = resetProcess.getSecurityQuestions(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountResetResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                mView.addObject("questionList", response.getQuestionList());
                mView.addObject("command", new UserChangeRequest());
                mView.setViewName(this.changeSecurityPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
                mView.setViewName(appConfig.getUnauthorizedPage());
            }
            else
            {
                mView.addObject(Constants.ERROR_RESPONSE, response.getResponse());
                mView.setViewName(this.myAccountPage);
            }
        }
        catch (AccountResetException arx)
        {
            ERROR_RECORDER.error(arx.getMessage(), arx);

            mView.setViewName(appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/email", method = RequestMethod.GET)
    public final ModelAndView showEmailChange()
    {
        final String methodName = UserAccountController.CNAME + "#showEmailChange()";

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

        mView.addObject("command", new UserChangeRequest());
        mView.setViewName(this.changeEmailPage);

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/contact", method = RequestMethod.GET)
    public final ModelAndView showContactChange()
    {
        final String methodName = UserAccountController.CNAME + "#showContactChange()";

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

        mView.addObject("command", new UserChangeRequest());
        mView.setViewName(this.changeContactPage);

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/regenerate-keys", method = RequestMethod.GET)
    public final ModelAndView doRegenerateKeys()
    {
        final String methodName = UserAccountController.CNAME + "#doRegenerateKeys()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountChangeProcessor processor = new AccountChangeProcessorImpl();

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

        try
        {
            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            // reset keys !
            AccountChangeRequest req = new AccountChangeRequest();
            req.setApplicationId(appConfig.getApplicationId());
            req.setApplicationName(appConfig.getApplicationName());
            req.setHostInfo(reqInfo);
            req.setUserAccount(userAccount);
            req.setRequestor(userAccount);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeRequest: {}", req);
            }

            AccountChangeResponse response = processor.changeUserKeys(req);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                hSession.removeAttribute(Constants.USER_ACCOUNT);
                hSession.setAttribute(Constants.USER_ACCOUNT, response.getUserAccount());

                mView.addObject(Constants.RESPONSE_MESSAGE, this.changeKeysComplete);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
                mView.setViewName(appConfig.getUnauthorizedPage());

                return mView;
            }
            else
            {
                mView.addObject(Constants.ERROR_RESPONSE, response.getResponse());
            }

            mView.setViewName(this.myAccountPage);
        }
        catch (AccountChangeException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/password", method = RequestMethod.POST)
    public final ModelAndView doPasswordChange(@ModelAttribute("changeReq") final UserChangeRequest changeReq, final BindingResult bindResult)
    {
        final String methodName = UserAccountController.CNAME + "#doPasswordChange(@ModelAttribute(\"changeReq\") final UserChangeRequest changeReq, final BindingResult bindResult)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("UserChangeRequest: {}", changeReq);
            DEBUGGER.debug("BindingResult: {}", bindResult);
        }

        UserSecurity userSecurity = null;
        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountChangeProcessor processor = new AccountChangeProcessorImpl();

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

        // validate our new password here
        passwordValidator.validate(changeReq, bindResult);

        if (bindResult.hasErrors())
        {
            UserChangeRequest command = new UserChangeRequest();
            changeReq.setIsReset(changeReq.isReset());

            mView.addObject("command", command);
            mView.addObject(Constants.ERROR_MESSAGE, appConfig.getMessageValidationFailed());
            mView.setViewName(this.changePasswordPage);
        }

        try
        {
            if (userAccount.getStatus() == LoginStatus.RESET)
            {
                userSecurity = new UserSecurity();
                userSecurity.setNewPassword(changeReq.getConfirmPassword());
            }
            else
            {
                userSecurity = new UserSecurity();
                userSecurity.setPassword(changeReq.getCurrentPassword());
                userSecurity.setNewPassword(changeReq.getConfirmPassword());
            }

            if (DEBUG)
            {
                DEBUGGER.debug("UserSecurity: {}", userSecurity);
            }

            RequestHostInfo reqInfo = new RequestHostInfo();
            reqInfo.setHostAddress(hRequest.getRemoteAddr());
            reqInfo.setHostName(hRequest.getRemoteHost());

            if (DEBUG)
            {
                DEBUGGER.debug("RequestHostInfo: {}", reqInfo);
            }

            AccountChangeRequest request = new AccountChangeRequest();
            request.setHostInfo(reqInfo);
            request.setIsLogonRequest(false);
            request.setModType(ModificationType.PASSWORD);
            request.setRequestor(userAccount);
            request.setUserAccount(userAccount);
            request.setUserSecurity(userSecurity);
            request.setIsReset(changeReq.isReset());
            request.setApplicationId(appConfig.getApplicationId());
            request.setApplicationName(appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeRequest: {}", request);
            }

            AccountChangeResponse response = processor.changeUserPassword(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                // yay
                if (changeReq.isReset())
                {
                    if (DEBUG)
                    {
                        DEBUGGER.debug("Invalidating existing session object...");
                    }

                    hRequest.getSession().invalidate();
                    hSession.invalidate();

                    // redirect to logon page
                    mView.addObject(Constants.RESPONSE_MESSAGE, this.changePasswordComplete);
                    mView.setViewName(appConfig.getLogonRedirect());
                }
                else
                {
                    mView.addObject(Constants.RESPONSE_MESSAGE, this.changePasswordComplete);
                    mView.setViewName(this.myAccountPage);
                }
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
                mView.setViewName(appConfig.getUnauthorizedPage());
            }
            else
            {
                mView.addObject(Constants.ERROR_RESPONSE, response.getResponse());
                mView.setViewName(this.changePasswordPage);
            }
        }
        catch (AccountChangeException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);

            mView.setViewName(appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/security", method = RequestMethod.POST)
    public final ModelAndView doSecurityChange(@ModelAttribute("changeReq") final UserChangeRequest changeReq, final BindingResult bindResult)
    {
        final String methodName = UserAccountController.CNAME + "#doSecurityChange(@ModelAttribute(\"changeReq\") final UserChangeRequest changeReq, final BindingResult bindResult)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("UserChangeRequest: {}", changeReq);
            DEBUGGER.debug("BindingResult: {}", bindResult);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountChangeProcessor processor = new AccountChangeProcessorImpl();

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

        // validate our new password here
        securityValidator.validate(changeReq, bindResult);

        if (bindResult.hasErrors())
        {
            mView.addObject("command", new UserChangeRequest());
            mView.addObject(Constants.ERROR_MESSAGE, appConfig.getMessageValidationFailed());
            mView.setViewName(this.changeSecurityPage);

            return mView;
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

            UserSecurity userSecurity = new UserSecurity();
            userSecurity.setSecQuestionOne(changeReq.getSecQuestionOne());
            userSecurity.setSecQuestionTwo(changeReq.getSecQuestionTwo());
            userSecurity.setSecAnswerOne(changeReq.getSecQuestionOne());
            userSecurity.setSecAnswerTwo(changeReq.getSecAnswerTwo());
            userSecurity.setPassword(changeReq.getCurrentPassword());

            if (DEBUG)
            {
                DEBUGGER.debug("UserSecurity: {}", userSecurity);
            }

            AccountChangeRequest request = new AccountChangeRequest();
            request.setHostInfo(reqInfo);
            request.setIsLogonRequest(false);
            request.setModType(ModificationType.SECINFO);
            request.setRequestor(userAccount);
            request.setUserAccount(userAccount);
            request.setUserSecurity(userSecurity);
            request.setApplicationId(appConfig.getApplicationId());
            request.setApplicationName(appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeRequest: {}", request);
            }

            AccountChangeResponse response = processor.changeUserSecurity(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                mView.addObject(Constants.RESPONSE_MESSAGE, this.changeSecurityComplete);
                mView.setViewName(this.myAccountPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
                mView.setViewName(appConfig.getUnauthorizedPage());
            }
            else
            {
                mView.addObject(Constants.ERROR_RESPONSE, response.getResponse());
                mView.setViewName(this.changeSecurityPage);
            }
        }
        catch (AccountChangeException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);
            
            mView.setViewName(appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/email", method = RequestMethod.POST)
    public final ModelAndView doEmailChange(@ModelAttribute("changeReq") final UserChangeRequest changeReq, final BindingResult bindResult)
    {
        final String methodName = UserAccountController.CNAME + "#doEmailChange(@ModelAttribute(\"changeReq\") final UserChangeRequest changeReq, final BindingResult bindResult)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("UserChangeRequest: {}", changeReq);
            DEBUGGER.debug("BindingResult: {}", bindResult);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountChangeProcessor processor = new AccountChangeProcessorImpl();

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

        emailValidator.validate(changeReq, bindResult);

        if (bindResult.hasErrors())
        {
            mView.addObject("command", new UserChangeRequest());
            mView.addObject(Constants.ERROR_MESSAGE, appConfig.getMessageValidationFailed());
            mView.setViewName(this.changeSecurityPage);

            return mView;
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

            UserSecurity userSecurity = new UserSecurity();
            userSecurity.setPassword(changeReq.getCurrentPassword());

            if (DEBUG)
            {
                DEBUGGER.debug("UserSecurity: {}", userSecurity);
            }

            UserAccount modAccount = userAccount;
            modAccount.setEmailAddr(changeReq.getEmailAddr());

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", modAccount);
            }

            AccountChangeRequest request = new AccountChangeRequest();
            request.setHostInfo(reqInfo);
            request.setIsLogonRequest(false);
            request.setModType(ModificationType.SECINFO);
            request.setRequestor(userAccount);
            request.setUserAccount(userAccount);
            request.setUserSecurity(userSecurity);
            request.setApplicationId(appConfig.getApplicationId());
            request.setApplicationName(appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeRequest: {}", request);
            }

            AccountChangeResponse response = processor.changeUserEmail(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                // yay
                hSession.removeAttribute(Constants.USER_ACCOUNT);
                hSession.setAttribute(Constants.USER_ACCOUNT, response.getUserAccount());

                mView.addObject(Constants.RESPONSE_MESSAGE, this.changeEmailComplete);
                mView.setViewName(this.myAccountPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
                mView.setViewName(appConfig.getUnauthorizedPage());
            }
            else
            {
                mView.addObject(Constants.ERROR_RESPONSE, response.getResponse());
                mView.setViewName(this.changePasswordPage);
            }
        }
        catch (AccountChangeException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);
            
            mView.setViewName(appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }

    @RequestMapping(value = "/contact", method = RequestMethod.POST)
    public final ModelAndView doContactChange(@ModelAttribute("changeReq") final UserChangeRequest changeReq, final BindingResult bindResult)
    {
        final String methodName = UserAccountController.CNAME + "#doEmailChange(@ModelAttribute(\"changeReq\") final UserChangeRequest changeReq, final BindingResult bindResult)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("UserChangeRequest: {}", changeReq);
            DEBUGGER.debug("BindingResult: {}", bindResult);
        }

        ModelAndView mView = new ModelAndView();

        final ServletRequestAttributes requestAttributes = (ServletRequestAttributes) RequestContextHolder.currentRequestAttributes();
        final HttpServletRequest hRequest = requestAttributes.getRequest();
        final HttpSession hSession = hRequest.getSession();
        final UserAccount userAccount = (UserAccount) hSession.getAttribute(Constants.USER_ACCOUNT);
        final IAccountChangeProcessor processor = new AccountChangeProcessorImpl();

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

        // validate our new password here
        telValidator.validate(changeReq, bindResult);

        if (bindResult.hasErrors())
        {
            mView.addObject("command", new UserChangeRequest());
            mView.addObject(Constants.ERROR_MESSAGE, appConfig.getMessageValidationFailed());
            mView.setViewName(this.changeContactPage);

            return mView;
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

            UserSecurity userSecurity = new UserSecurity();
            userSecurity.setPassword(changeReq.getCurrentPassword());

            if (DEBUG)
            {
                DEBUGGER.debug("UserSecurity: {}", userSecurity);
            }

            UserAccount modAccount = userAccount;
            modAccount.setEmailAddr(changeReq.getEmailAddr());

            if (DEBUG)
            {
                DEBUGGER.debug("UserAccount: {}", modAccount);
            }

            AccountChangeRequest request = new AccountChangeRequest();
            request.setHostInfo(reqInfo);
            request.setIsLogonRequest(false);
            request.setModType(ModificationType.SECINFO);
            request.setRequestor(userAccount);
            request.setUserAccount(userAccount);
            request.setUserSecurity(userSecurity);
            request.setApplicationId(appConfig.getApplicationId());
            request.setApplicationName(appConfig.getApplicationName());

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeRequest: {}", request);
            }

            AccountChangeResponse response = processor.changeUserContact(request);

            if (DEBUG)
            {
                DEBUGGER.debug("AccountChangeResponse: {}", response);
            }

            if (response.getRequestStatus() == SecurityRequestStatus.SUCCESS)
            {
                // yay
                hSession.removeAttribute(Constants.USER_ACCOUNT);
                hSession.setAttribute(Constants.USER_ACCOUNT, response.getUserAccount());

                mView.addObject(Constants.RESPONSE_MESSAGE, this.changeContactComplete);
                mView.setViewName(this.myAccountPage);
            }
            else if (response.getRequestStatus() == SecurityRequestStatus.UNAUTHORIZED)
            {
                mView.setViewName(appConfig.getUnauthorizedPage());
            }
            else
            {
                mView.addObject(Constants.ERROR_RESPONSE, response.getResponse());
                mView.setViewName(this.changeContactPage);
            }
        }
        catch (AccountChangeException acx)
        {
            ERROR_RECORDER.error(acx.getMessage(), acx);
            
            mView.setViewName(appConfig.getErrorResponsePage());
        }

        if (DEBUG)
        {
            DEBUGGER.debug("ModelAndView: {}", mView);
        }

        return mView;
    }
}
