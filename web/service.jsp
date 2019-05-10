<%@ page import="java.io.File" %>
<%@ page import="java.io.PrintStream" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setBundle basename="config" var="config" scope="request"/>
<fmt:message key="md5Token" var="md5Token" bundle="${config}" scope="request"/>
<fmt:message key="nginxLogPath" var="nginxLogPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxConfigPath" var="nginxConfigPath" bundle="${config}" scope="request"/>
<fmt:message key="nginxStatusUrl" var="nginxStatusUrl" bundle="${config}" scope="request"/>
<%
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
    // 这个jsp直接当servlet用 提供接口
    // 先校验密码
    String token = request.getParameter("t");
    if (!String.valueOf(request.getAttribute("md5Token")).equalsIgnoreCase(token)) {
        response.sendError(403);
        return;
    }
    try {
        String method = request.getParameter("method");
        if ("saveNginxConfig".equals(method)) {
            // 保存
            String nginxConfig = request.getParameter("nc");
            if(nginxConfig == null || "".equals(nginxConfig)){
                throw new Exception("zz");
            }
            nginxConfig = new String(java.util.Base64.getDecoder().decode(nginxConfig));
            File file = new File(String.valueOf(request.getAttribute("nginxConfigPath")));
            PrintStream ps = new PrintStream(new FileOutputStream(file));
            ps.println(nginxConfig);
            ps.close();
            return;
        } else if ("testNginxConfig".equals(method)) {
            // 校验

            return;
        } else if ("reloadNginxConfig".equals(method)) {
            // 生效

            return;
        } else {
            response.sendError(404);
            return;
        }
    } catch (Exception e) {
        // 这部分代码如果有错误 直接报个502回去
        response.sendError(502);
        return;
    }
%>
