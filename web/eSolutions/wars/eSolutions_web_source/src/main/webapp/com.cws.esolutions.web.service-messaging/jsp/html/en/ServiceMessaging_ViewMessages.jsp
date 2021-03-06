<%--
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
--%>
<%--
/**
 * Project: eSolutions_web_source
 * Package: com/cws/esolutions.web.service-messaging\jsp\html\en
 * File: ServiceMessaging_ViewMessages.jsp
 *
 * @author cws-khuntly
 * @version 1.0
 *
 * History
 *
 * Author               Date                            Comments
 * ----------------------------------------------------------------------------
 * cws-khuntly          11/23/2008 22:39:20             Created.
 */
--%>

<div id="sidebar">
    <h1><spring:message code="svc.messaging.list.messages" /></h1>
    <ul>
        <c:if test="${sessionScope.userAccount.role eq 'ADMIN' or sessionScope.userAccount.role eq 'SITEADMIN'}">
            <li><a href="${pageContext.request.contextPath}/ui/service-messaging/add-message" title="spring:message code='svc.messaging.create.system.message' />"><spring:message code="svc.messaging.create.system.message" /></a></li>
        </c:if>
    </ul>
</div>

<div id="main">
    <h1><spring:message code="svc.messaging.list" /></h1>

    <c:if test="${not empty fn:trim(messageResponse)}">
        <p id="info">${messageResponse}</p>
    </c:if>
    <c:if test="${not empty fn:trim(errorResponse)}">
        <p id="error">${errorResponse}</p>
    </c:if>
    <c:if test="${not empty fn:trim(responseMessage)}">
        <p id="info"><spring:message code="${responseMessage}" /></p>
    </c:if>
    <c:if test="${not empty fn:trim(errorMessage)}">
        <p id="error"><spring:message code="${errorMessage}" /></p>
    </c:if>
    <c:if test="${not empty fn:trim(param.responseMessage)}">
        <p id="info"><spring:message code="${param.responseMessage}" /></p>
    </c:if>
    <c:if test="${not empty fn:trim(param.errorMessage)}">
        <p id="error"><spring:message code="${param.errorMessage}" /></p>
    </c:if>

    <p>
        <c:choose>
            <c:when test="${not empty messageList}">
                <c:forEach var="message" items="${messageList}">
                    <div id="svcmessage">
                        <h3>
                            <a href="${pageContext.request.contextPath}/ui/service-messaging/edit-message/message/${message.messageId}"
                                title="<spring:message code='svc.messaging.view.system.message.edit' arguments='${message.messageTitle}, ${message.messageId}' />">
                                <spring:message code="svc.messaging.view.system.message.edit" arguments="${message.messageTitle}, ${message.messageId}"/></a>
                        </h3>
                        <div class="feature">
                            ${message.messageText}
                        </div>

                        <p class="post-footer align-right">
                            <spring:message code="svc.messaging.system.message.author" />: <a href="mailto:${message.messageAuthor.emailAddr}?subject=${message.messageId}" title="<spring:message code='svc.messaging.system.message.author' />">${message.messageAuthor.username}</a><br />
                            <spring:message code="svc.messaging.system.message.submit.date" /><span class="date"><fmt:formatDate value="${message.submitDate}" pattern="${dateFormat}" /></span><br />
                            <c:if test="${not empty fn:trim(message.expiryDate)}">
                                <spring:message code="svc.messaging.system.message.expiry.date" /><span class="date"><fmt:formatDate value="${message.expiryDate}" pattern="${dateFormat}" /></span>
                            </c:if>
                        </p>
                    </div>
                </c:forEach>
            </c:when>
            <c:otherwise>
                <spring:message code="svc.messaging.no.system.messages" />
                <br /><br />
                <c:if test="${sessionScope.userAccount.role eq 'ADMIN' or sessionScope.userAccount.role eq 'SITEADMIN'}">
                    <a href="${pageContext.request.contextPath}/ui/service-messaging/add-message" title="<spring:message code='svc.messaging.create.system.message' />"><spring:message code="svc.messaging.create.system.message" /></a>
                </c:if>
            </c:otherwise>
        </c:choose>
    </p>
</div>

<div id="rightbar">&nbsp;</div>
