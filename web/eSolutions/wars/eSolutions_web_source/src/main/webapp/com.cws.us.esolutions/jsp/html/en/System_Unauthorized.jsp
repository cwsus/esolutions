<%--
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
 *
 * eSolutions_web_source
 * com.cws.us.esolutions/jsp/html/en
 * System_Unauthorized.jsp
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
 */
--%>

<div id="InfoLine"><spring:message code="theme.request.unauthorized" /></div>
<div id="content">
    <div id="content-right">
        <spring:message code="theme.system.request.unauthorized" />

        <c:choose>
            <c:when test="${requestScope.isUserLoggedIn != 'true'}">
                <p>
                    <a href="${pageContext.request.contextPath}/ui/common/default" title="<spring:message code='theme.navbar.home' />">
                        <spring:message code="theme.click.continue" /></a>
                </p>
            </c:when>
            <c:otherwise>
                <p>
                    <a href="${pageContext.request.contextPath}/ui/login/default" title="<spring:message code='theme.navbar.login' />">
                        <spring:message code="theme.click.continue" /></a>
                </p>
            </c:otherwise>
        </c:choose>
    </div>
</div>
