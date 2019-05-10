<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setBundle basename="config" var="config" scope="request"/>
<fmt:message key="md5Token" var="md5Token" bundle="${config}" scope="request"/>
<fmt:message key="nginxLogPath" var="nginxLogPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxConfigPath" var="nginxConfigPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxStatusUrl" var="nginxStatusUrl" bundle="${config}" scope="request"/>
<%
    // 这个jsp直接当servlet用 提供接口
    // 先校验密码
    String token = request.getParameter("t");
    if (!String.valueOf(request.getAttribute("md5Token")).equalsIgnoreCase(token)) {
        response.sendError(403);
        return;
    }


%>
