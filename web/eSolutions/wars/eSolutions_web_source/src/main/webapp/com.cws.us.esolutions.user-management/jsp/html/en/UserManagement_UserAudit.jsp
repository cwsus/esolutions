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
 * com.cws.us.esolutions.user-management/jsp/html/en
 * UserManagement_UserAudit.jsp
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

<div class="feature">
    <c:choose>
        <c:when test="${sessionScope.userAccount.role eq 'USERADMIN' or sessionScope.userAccount.role eq 'SITEADMIN'}">
            <div id="breadcrumb" class="lpstartover">
                <a href="${pageContext.request.contextPath}/ui/user-management/add-user"
                    title="<spring:message code='admin.account.create.user' />"><spring:message code="admin.account.create.user" /></a>
            </div>

            <c:if test="${not empty messageResponse}">
                <p id="info">${messageResponse}</p>
            </c:if>
            <c:if test="${not empty errorResponse}">
                <p id="error">${errorResponse}</p>
            </c:if>
            <c:if test="${not empty errorMessage}">
                <p id="error"><spring:message code="${errorMessage}" /></p>
            </c:if>

            <spring:message code="admin.account.view.audit" arguments="${userAccount.username}" />
            <br />
            <hr />
            <br />

            <table id="viewAuditTrail">
                <tr>
                    <td><spring:message code="admin.account.audit.timestamp" /></td>
                    <td><spring:message code="admin.account.audit.type" /></td>
                    <td><spring:message code="admin.account.audit.application" /></td>
                    <td><spring:message code="admin.account.audit.hostinfo" /></td>
                </tr>
                <c:forEach var="entry" items="${auditEntries}">
                    <tr>
                        <td>${entry.auditDate}</td>
                        <td>${entry.auditType}</td>
                        <td>${entry.applicationName}</td>
                        <td>${entry.hostInfo.hostName} / ${entry.hostInfo.hostAddress}</td>
                    </tr>
                </c:forEach>
            </table>

		    <c:if test="${pages gt 1}">
		        <br />
		        <hr />
		        <br />
		        <table>
		            <tr>
		                <c:forEach begin="1" end="${pages}" var="i">
		                    <c:choose>
		                        <c:when test="${page eq i}">
		                            <td>${i}</td>
		                        </c:when>
		                        <c:otherwise>
		                            <td>
		                                <a href="${pageContext.request.contextPath}/ui/service-management/list-platforms/page/${i}"
		                                    title="<spring:message code='system.next.page' />">${i}</a>
		                            </td>
		                        </c:otherwise>
		                    </c:choose>
		                </c:forEach>
		            </tr>
		        </table>
		    </c:if>
        </c:when>
        <c:otherwise>
            <spring:message code="admin.account.not.authorized" />
            <c:if test="${requestScope.isUserLoggedIn ne 'true'}">
                <p>Click <a href="${pageContext.request.contextPath}/ui/home/default" title="Home">here</a> to continue.</p>
            </c:if>
        </c:otherwise>
    </c:choose>
</div>
<br /><br />
