<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page trimDirectiveWhitespaces="true" %>
<%@ page import="java.io.BufferedWriter" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page import="java.io.OutputStreamWriter" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.Base64" %>
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
    // 练习项目，故用此JSP 当servlet 提供接口
    try {
        // 只接post
        if (!"post".equalsIgnoreCase(request.getMethod())) {
            throw new Exception("SYSTEM ERROR");
        }
        // 校验密码
        String token = request.getParameter("t");
        if (!String.valueOf(request.getAttribute("md5Token")).equalsIgnoreCase(token)) {
            throw new Exception("SYSTEM ERROR");
        }
        String method = request.getParameter("m");
        System.out.println(method);
        if ("saveNc".equals(method)) {
            // 保存
            String nginxConfig = request.getParameter("nc");
            if (nginxConfig == null || "".equals(nginxConfig)) {
                throw new Exception("SYSTEM ERROR");
            }
            nginxConfig = URLDecoder.decode(new String(Base64.getDecoder().decode(nginxConfig)), "UTF-8");
            System.out.println(nginxConfig);
            File file = new File(String.valueOf(request.getAttribute("nginxConfigPath")));
            OutputStreamWriter write = new OutputStreamWriter(new FileOutputStream(file), "UTF-8");
            BufferedWriter writer = new BufferedWriter(write);
            writer.write(nginxConfig);
            writer.close();
            out.print("保存成功");
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
        System.out.println(e.getMessage());
        // 这部分代码如果有错误 直接报404
        response.sendError(404);
        return;
    }
%>