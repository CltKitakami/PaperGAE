<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>

<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
UserService userService = UserServiceFactory.getUserService();
User user = userService.getCurrentUser();
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <base href="<%=basePath%>">

    <title>PaperGAE</title>

	<meta http-equiv="pragma" content="no-cache">
	<meta http-equiv="cache-control" content="no-cache">
	<meta http-equiv="expires" content="0">
	<meta http-equiv="keywords" content="keyword1,keyword2,keyword3">
	<meta http-equiv="description" content="This is my page">
	<link rel="stylesheet" type="text/css" href="/css/main.css">

	<script type="text/javascript">
	function delayer(){ window.location = "/SearchService.jsp" }
	</script>
  </head>

  </head>

    <%
    if (user != null) {
	%>
  		<body onLoad="setTimeout('delayer()', 3000)">
  		<div id="main">
	  		<div id="dialog">
		  		<div id="content">
					<p>Hello, <%= user.getNickname() %>! (You can
					<a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)</p>
					<p><a href="/SearchService.jsp">Prepare to be redirected in 3 seconds!</a></p>
				</div>
			</div>
		</div>
  		</body>
	<%
	} else {
	%>
  		<body>
  		<div id="main">
	  		<div id="dialog">
		  		<div id="content">
					<a href="<%= userService.createLoginURL(request.getRequestURI()) %>">Sign in</a>
				</div>
			</div>
		</div>
  		</body>
	<%
  	}
	%>
</html>
