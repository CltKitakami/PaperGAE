<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.*" %>
<%@ page import="com.google.appengine.api.datastore.*" %>

<%
String path = request.getContextPath();
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";
UserService userService = UserServiceFactory.getUserService();
User user = userService.getCurrentUser();
BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
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
      <form action="<%= blobstoreService.createUploadUrl("/upload") %>"
      	method="post" enctype="multipart/form-data">

	    <table>
			<tr><td>Title:</td>
			<td><input type="text" name="title" required/></td></tr>
			<tr><td>Author:</td>
			<td><input type="text" name="author" /></td></tr>
			<tr><td>Published In:</td>
			<td><input type="text" name="published" /></td></tr>
			<tr><td>Date of Conference:</td>
			<td><input type="text" name="dateOfConference" /></td></tr>
		</table>
		<p></p>
		Comment:
		<textarea name="comment" rows="3" cols="30"></textarea>
		<p></p>

		<label class="uploadLabel">
		    <input type="file" name="paperFile" required/>
		    <span>Choose a file</span>
		</label>

		<p></p>
<%
		out.println("<input type=\"hidden\" name=\"uploadBy\" value=\"" + user.getNickname() + "\">");
%>
		<input type="hidden" name="service" value="upload">
		<input type="submit" value="Upload" />
	    </form>
      </div>
    </div>
    </div>
  <%
  }
  %>

  </body>
</html>
