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
package com.cws.esolutions.web.validators;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.Errors;
import org.springframework.validation.Validator;
import org.springframework.validation.ValidationUtils;

import com.cws.esolutions.web.Constants;
import com.cws.esolutions.core.processors.dto.Service;
/*
 * Project: eSolutions_java_source
 * Package: com.cws.esolutions.web.validators
 * File: ServiceValidator.java
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * kmhuntly@gmail.com   11/23/2008 22:39:20             Created.
 */
public class ServiceValidator implements Validator
{
    private String messageDatacenterNameRequired = null;
    private String messageDatacenterStatusRequired = null;
    private String messageDatacenterDescriptionRequired = null;

    private static final String CNAME = ServiceValidator.class.getName();

    private static final Logger DEBUGGER = LoggerFactory.getLogger(Constants.DEBUGGER);
    private static final boolean DEBUG = DEBUGGER.isDebugEnabled();

    public final void setMessageDatacenterNameRequired(final String value)
    {
        final String methodName = ServiceValidator.CNAME + "#setMessageDatacenterNameRequired(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageDatacenterNameRequired = value;
    }

    public final void setMessageDatacenterStatusRequired(final String value)
    {
        final String methodName = ServiceValidator.CNAME + "#setMessageArticleCauseRequired(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageDatacenterStatusRequired = value;
    }

    public final void setMessageDatacenterDescriptionRequired(final String value)
    {
        final String methodName = ServiceValidator.CNAME + "#setMessageDatacenterDescriptionRequired(final String value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        this.messageDatacenterDescriptionRequired = value;
    }

    @Override
    public final boolean supports(final Class<?> value)
    {
        final String methodName = ServiceValidator.CNAME + "#supports(final Class<?> value)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Value: {}", value);
        }

        final boolean isSupported = Service.class.isAssignableFrom(value);

        if (DEBUG)
        {
            DEBUGGER.debug("isSupported: {}", value);
        }

        return isSupported;
    }

    @Override
    public final void validate(final Object target, final Errors errors)
    {
        final String methodName = ServiceValidator.CNAME + "#validate(final Object target, final Errors errors)";

        if (DEBUG)
        {
            DEBUGGER.debug(methodName);
            DEBUGGER.debug("Object: {}", target);
            DEBUGGER.debug("Errors: {}", errors);
        }

        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "name", this.messageDatacenterNameRequired);
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "status", this.messageDatacenterStatusRequired);
        ValidationUtils.rejectIfEmptyOrWhitespace(errors, "description", this.messageDatacenterDescriptionRequired);
    }
}