/*
 * Copyright (c) 2009 - 2020 CaspersBox Web Services
 * 
 * All rights reserved. These materials are confidential and
 * proprietary to CaspersBox Web Services N.A and no part of
 * these materials should be reproduced, published in any form
 * by any means, electronic or mechanical, including photocopy
 * or any information storage or retrieval system not should
 * the materials be disclosed to third parties without the
 * express written authorization of CaspersBox Web Services, N.A.
 */
package com.cws.esolutions.security.processors.dto;
/*
 * Project: eSolutions_java_source
 * Package: com.cws.esolutions.web.dto
 * File: UserChangeRequest.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly           11/23/2008 22:39:20             Created.
 */
import org.slf4j.Logger;
import java.io.Serializable;
import java.lang.reflect.Field;
import org.slf4j.LoggerFactory;

import com.cws.esolutions.security.SecurityServiceConstants;
import com.cws.esolutions.security.processors.enums.ResetRequestType;
/**
 * @author cws-khuntly
 * @version 1.0
 */
public final class AccountChangeData implements Serializable
{
    private int count = 0;
    private String resetKey = null;
    private String username = null;
    private String telNumber = null;
    private boolean isReset = false;
    private String emailAddr = null;
    private String pagerNumber = null;
    private String newPassword = null;
    private String secAnswerOne = null;
    private String secAnswerTwo = null;
    private String secQuestionOne = null;
    private String secQuestionTwo = null;
    private String currentPassword = null;
    private String confirmPassword = null;
    private ResetRequestType resetType = null;

    private static final String CNAME = AccountChangeData.class.getName();
    private static final long serialVersionUID = -990715180500683492L;

    private static final Logger DEBUGGER = LoggerFactory.getLogger(SecurityServiceConstants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();
    private static final Logger ERROR_RECORDER = LoggerFactory.getLogger(SecurityServiceConstants.ERROR_LOGGER);

    public final void setIsReset(final boolean value)
    {
        final String methodName = AccountChangeData.CNAME + "#setIsReset(final boolean value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.isReset = value;
    }

    public final void setResetKey(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setResetKey(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.resetKey = value;
    }

    public final void setResetType(final ResetRequestType value)
    {
        final String methodName = AccountChangeData.CNAME + "#setResetType(final ResetRequestType value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.resetType = value;
    }

    public final void setUsername(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setUsername(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.username = value;
    }

    public final void setCurrentPassword(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setCurrentPassword(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        this.currentPassword = value;
    }

    public final void setNewPassword(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setNewPassword(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        this.newPassword = value;
    }

    public final void setConfirmPassword(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setConfirmPassword(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        this.confirmPassword = value;
    }

    public final void setEmailAddr(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setEmailAddr(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.emailAddr = value;
    }

    public final void setSecAnswerOne(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setSecAnswerOne(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        this.secAnswerOne = value;
    }

    public final void setSecAnswerTwo(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setSecAnswerTwo(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        this.secAnswerTwo = value;
    }

    public final void setSecQuestionOne(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setSecQuestionOne(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.secQuestionOne = value;
    }

    public final void setSecQuestionTwo(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setSecQuestionTwo(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.secQuestionTwo = value;
    }

    public final void setTelNumber(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setTelNumber(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.telNumber = value;
    }

    public final void setPagerNumber(final String value)
    {
        final String methodName = AccountChangeData.CNAME + "#setPagerNumber(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.pagerNumber = value;
    }

    public final void setCount(final int value)
    {
        final String methodName = AccountChangeData.CNAME + "#setCount(final int value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.count = value;
    }

    public final boolean getIsReset()
    {
        final String methodName = AccountChangeData.CNAME + "#getIsReset()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.isReset);
        }

        return this.isReset;
    }

    public final boolean isReset()
    {
        final String methodName = AccountChangeData.CNAME + "#isReset()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.isReset);
        }

        return this.isReset;
    }

    public final String getResetKey()
    {
        final String methodName = AccountChangeData.CNAME + "#getResetKey(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.resetKey);
        }

        return this.resetKey;
    }

    public final ResetRequestType getResetType()
    {
        final String methodName = AccountChangeData.CNAME + "#getResetType()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.resetType);
        }

        return this.resetType;
    }

    public final String getUsername()
    {
        final String methodName = AccountChangeData.CNAME + "#getUsername()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.username);
        }

        return this.username;
    }

    public final String getCurrentPassword()
    {
        final String methodName = AccountChangeData.CNAME + "#getCurrentPassword";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        return this.currentPassword;
    }

    public final String getNewPassword()
    {
        final String methodName = AccountChangeData.CNAME + "#getNewPassword";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        return this.newPassword;
    }

    public final String getConfirmPassword()
    {
        final String methodName = AccountChangeData.CNAME + "#getConfirmPassword";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        return this.confirmPassword;
    }

    public final String getEmailAddr()
    {
        final String methodName = AccountChangeData.CNAME + "#getEmailAddr()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.emailAddr);
        }

        return this.emailAddr;
    }

    public final String getSecAnswerOne()
    {
        final String methodName = AccountChangeData.CNAME + "#getSecAnswerOne()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        return this.secAnswerOne;
    }

    public final String getSecAnswerTwo()
    {
        final String methodName = AccountChangeData.CNAME + "#getSecAnswerTwo()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        return this.secAnswerTwo;
    }

    public final String getSecQuestionOne()
    {
        final String methodName = AccountChangeData.CNAME + "#getSecQuestionOne()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.secQuestionOne);
        }

        return this.secQuestionOne;
    }

    public final String getSecQuestionTwo()
    {
        final String methodName = AccountChangeData.CNAME + "#getSecQuestionTwo()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.secQuestionTwo);
        }

        return this.secQuestionTwo;
    }

    public final String getTelNumber()
    {
        final String methodName = AccountChangeData.CNAME + "#getTelNumber()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.telNumber);
        }

        return this.telNumber;
    }

    public final String getPagerNumber()
    {
        final String methodName = AccountChangeData.CNAME + "#getPagerNumber()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.pagerNumber);
        }

        return this.pagerNumber;
    }

    public final int getCount()
    {
        final String methodName = AccountChangeData.CNAME + "#getCount()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", this.count);
        }

        return this.count;
    }

    @Override
    public final String toString()
    {
        final String methodName = AccountChangeData.CNAME + "#toString()";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
        }

        StringBuilder sBuilder = new StringBuilder()
            .append("[" + this.getClass().getName() + "]" + SecurityServiceConstants.LINE_BREAK + "{" + SecurityServiceConstants.LINE_BREAK);

        for (Field field : this.getClass().getDeclaredFields())
        {
            if (DEBUG)
            {
                DEBUGGER.debug("field: {}", field);
            }

            if (!(field.getName().equals("methodName")) &&
                    (!(field.getName().equals("CNAME"))) &&
                    (!(field.getName().equals("DEBUGGER"))) &&
                    (!(field.getName().equals("DEBUG"))) &&
                    (!(field.getName().equals("ERROR_RECORDER"))) &&
                    (!(field.getName().equals("newPassword"))) &&
                    (!(field.getName().equals("secAnswerOne"))) &&
                    (!(field.getName().equals("secAnswerTwo"))) &&
                    (!(field.getName().equals("currentPassword"))) &&
                    (!(field.getName().equals("confirmPassword"))) &&
                    (!(field.getName().equals("serialVersionUID"))))
            {
                try
                {
                    if (field.get(this) != null)
                    {
                        sBuilder.append("\t" + field.getName() + " --> " + field.get(this) + SecurityServiceConstants.LINE_BREAK);
                    }
                }
                catch (IllegalAccessException iax)
                {
                    ERROR_RECORDER.error(iax.getMessage(), iax);
                }
            }
        }

        sBuilder.append('}');

        if (DEBUG)
        {
            DEBUGGER.debug("sBuilder: {}", sBuilder);
        }

        return sBuilder.toString();
    }
}
