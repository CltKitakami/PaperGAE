<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.*" %>

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

  <%
  if (user == null) {
  %>
		<script type="text/javascript">
		window.location = "/sign.jsp"
		</script>
  <%
	}
	%>
  </head>

  <body>
  <%
  if (user != null) {
  %>
    <div id="main">
      <header id="masthead" role="banner">
      <h2 id="site-description">Welcome the website!</h2>
      <nav id="access">
        <div class="menu">
          <ul>
            <li ><a href="/index.html">Home</a></li>
            <li class="page_item page-item-2"><a href="/about.html">About</a></li>
            <li class="page_item page-item-199"><a href="/SearchService.jsp">Search</a></li>
            <li class="page_item page-item-171"><a href="/UploadService.jsp">Upload</a></li>
            <li class="page_item page-item-38 page_item_has_children"><a href="/">Web Service</a>
              <ul class='children'>
                <li class="page_item page-item-58"><a href="/index.html">GAE</a>
                </li>
              </ul>
            </li>
            <li class="right">
              <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>"><%= user.getNickname() %> sign out</a></li>
          </ul>
        </div>
      </nav>
      </header>
      <br></br><p></p>
      <div id="content">
<%
	String no = request.getParameter("no");
	DatastoreService dataService = DatastoreServiceFactory.getDatastoreService();

	if (no != null) {
		out.println("<input type=\"hidden\" name=\"paperId\" value=\"" + no + "\">");
		out.println("<table><tr><td>No: </td><td>" + no + "</td></tr>");
		Key key = KeyFactory.createKey("PAPER", Integer.parseInt(no));
		Entity e = dataService.get(key);
%>
			<tr><td>Title:</td>
<%
		out.println("<td>" + e.getProperty("title") + "</td></tr>");
%>
			<tr><td>Author:</td>
<%
		out.println("<td>" + e.getProperty("author") + "</td></tr>");
%>
			<tr><td>Published in:</td>
<%
		out.println("<td>" + e.getProperty("published") + "</td></tr>");
%>
			<tr><td width="200">Date of Conference:</td>
<%
		out.println("<td>" + e.getProperty("dateOfConference") + "</td></tr>");
%>
		</table>
		<p></p>
		Comment:
<%
		out.println("<p>" + e.getProperty("comment") + "</p>");
%>

		<p></p>
		<label class="uploadLabel">
<%
  String blobKeyStr = (String) e.getProperty("blobKey");
  if (blobKeyStr != null && blobKeyStr.equals("") == false) {
    String downloadUrl = "/serve?blob-key=" + blobKeyStr;
    out.println("<span><a href=" + downloadUrl +
      "><img src=\"/download.png\" height=\"16\" width=\"16\"></img></a></span>");
	out.println("<input type=\"hidden\" name=\"blobKey\" value=\"" + blobKeyStr + "\">");
  } else {
    out.print("<span>No file.</span>");
  }
%>
		</label>
		<p></p>
<%
	}
%>
      </div>
    </div>
    </div>
  <%
  }
  %>

  </body>
</html>
