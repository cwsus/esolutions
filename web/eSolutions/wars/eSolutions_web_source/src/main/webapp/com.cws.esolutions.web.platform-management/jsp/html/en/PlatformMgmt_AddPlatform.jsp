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
 * Package: com.cws.esolutions.web.service-management\jsp\html\en
 * File: ServiceMgmt_AddService.jsp
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

<script>
<!--
    function validateForm(theForm)
    {
        if (theForm.name.value == '')
        {
            clearText(theForm);

            document.getElementById('validationError').innerHTML = 'A platform name must be provided.';
            document.getElementById('txtPlatformName').style.color = '#FF0000';
            document.getElementById('execute').disabled = false;
            document.getElementById('platformName').focus();
        }
        else if ((theForm.status.value == '') || (theForm.status.value = '------'))
        {
            clearText(theForm);

            document.getElementById('validationError').innerHTML = 'A platform status must be provided.';
            document.getElementById('txtPlatformStatus').style.color = '#FF0000';
            document.getElementById('execute').disabled = false;
            document.getElementById('platformName').focus();
        }
        else if (theForm.servers.value == '')
        {
            clearText(theForm);

            document.getElementById('validationError').innerHTML = 'Target servers must be provided.';
            document.getElementById('txtPlatformServers').style.color = '#FF0000';
            document.getElementById('execute').disabled = false;
            document.getElementById('platformServers').focus();
        }
        else
        {
            theForm.submit();
        }
    }
//-->
</script>

<div id="sidebar">
    <h1><spring:message code="platform.mgmt.header" /></h1>
    <ul>
        <li><a href="${pageContext.request.contextPath}/ui/datacenter-management/list-datacenters" title="<spring:message code='platform.mgmt.list.datacenters' />"><spring:message code="platform.mgmt.list.datacenters" /></a></li>
        <li><a href="${pageContext.request.contextPath}/ui/datacenter-management/add-datacenter" title="<spring:message code='platform.mgmt.add.datacenter' />"><spring:message code="platform.mgmt.add.datacenter" /></a></li>
        <li><a href="${pageContext.request.contextPath}/ui/platform-management/list-platforms" title="<spring:message code='platform.mgmt.list.platforms' />"><spring:message code="platform.mgmt.list.platforms" /></a></li>
    </ul>
</div>

<div id="main">
    <h1><spring:message code="platform.mgmt.add.platform" /></h1>
    <div id="validationError" style="color: #FF0000"></div>

    <div id="validationError"></div>

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
        <form:form id="submitPlatformData" name="submitPlatformData" action="${pageContext.request.contextPath}/ui/platform-management/submit-platform" method="post">
            <label id="txtPlatformName"><spring:message code="platform.mgmt.name" /></label>
            <form:input path="platformName" />
            <form:errors path="platformName" cssClass="error" />

            <label id="txtPlatformStatus"><spring:message code="platform.mgmt.status" /></label>
            <form:select path="platformStatus" multiple="false">
                <option><spring:message code="theme.option.select" /></option>
                <option><spring:message code="theme.option.spacer" /></option>
                <form:options items="${statusList}" />
            </form:select>  
            <form:errors path="platformStatus" cssClass="error" />

            <label id="txtPlatformDescription"><spring:message code="platform.mgmt.description" /></label>
            <form:textarea path="platformDescription" />
            <form:errors path="description" cssClass="error" />

            <br /><br />
            <input type="button" name="execute" value="<spring:message code='theme.button.submit.text' />" id="execute" class="submit" onclick="disableButton(this); validateForm(this.form, event);" />
            <input type="button" name="reset" value="<spring:message code='theme.button.reset.text' />" id="reset" class="submit" onclick="clearForm();" />
            <input type="button" name="cancel" value="<spring:message code='theme.button.cancel.text' />" id="cancel" class="submit" onclick="redirectOnCancel('/esolutions/ui/platform-management/default');" />
        </form:form>
    </p>
</div>

<div id="rightbar">&nbsp;</div>
