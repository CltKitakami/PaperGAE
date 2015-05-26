<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.lang.*" %>
<%@ page import="java.io.IOException" %>
<%@ page import="javax.servlet.jsp.JspWriter" %>
<%@ page import="com.google.appengine.api.users.*" %>
<%@ page import="com.google.appengine.api.users.User.*" %>
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
      <h2 id="site-description">Welcome Paper Search Engine!</h2>
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
    <form action= "SearchService.jsp" method="get">
    <input type="hidden" name="service" value="search">
    <table><tr>
      <td width="60"><b>Search:<b></td>
      <td width="200"><input type="text" name="keyword" /></td>
      <td width="20"><input type="radio" name="query" value="1" checked="checked"/></td>
      <td width="110">Basic Search</label></td>
      <td width="20"><input type="radio" name="query" value="2"/></td>
      <td width="110">Author Search</td>
      <td width="20"><input type="radio" name="query" value="3"/></td>
      <td width="150">Publication Search</td>
    <td width="120"><input type="submit" value="Submit Query" /></td>
    <td width="120"><input type="reset" value ="Clear Query" /></td>
    </tr></table>
    </form>

<p></p>
<%
  Query qry = new Query("PAPER");
  DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
  PreparedQuery pq = datastore.prepare(qry);
%>
<table class="result"><tr>
<th align="center"><b>No</b></th>
<th align="center"><b>Title</b></th>
<th align="center"><b>Author</b></th>
<th align="center"><b>Published in</b></th>
<th align="center"><b>Date of Conference</b></th>
<th align="center"><b>Comment</b></th>
<th align="center"><b>Upload by</b></th>
<th align="center"><b>Download</b></th>
<th align="center"><b>Edit</b></th>
<th align="center"><b>Delete</b></th>
</tr>
<%!
public String trimLength(String str, int maxLength) {
  if (str == null) {
    return "{null}";
  } else if (str.length() > maxLength) {
    return str.substring(0, maxLength - 1) + "...";
  } else {
    return str;
  }
}

public void printEntity(JspWriter out, Entity e) throws IOException {
  UserService userService = UserServiceFactory.getUserService();
  User user = userService.getCurrentUser();
  long id = e.getKey().getId();
  String blobKeyStr = (String) e.getProperty("blobKey");
  String title = trimLength((String) e.getProperty("title"), 30);
  String author = trimLength((String) e.getProperty("author"), 10);
  String published = trimLength((String) e.getProperty("published"), 10);
  String dateOfConference = trimLength((String) e.getProperty("dateOfConference"), 10);
  String comment = trimLength((String) e.getProperty("comment"), 20);
  String uploadBy = (String) e.getProperty("uploadBy");
  String trimedUploadBy = trimLength(uploadBy, 20);
  String nickname = user.getNickname();
  String viewUrl = "/view.jsp?no=" + id;

  out.print("<tr>");
  out.print("<td align=\"center\">" + id + "</td>");
  out.print("<td align=\"left\"><a href=\"" + viewUrl + "\">" + title + "</a></td>");
  out.print("<td align=\"left\">" + author + "</td>");
  out.print("<td align=\"left\">" + published + "</td>");
  out.print("<td align=\"left\">" + dateOfConference + "</td>");
  out.print("<td align=\"left\">" + comment + "</td>");
  out.print("<td align=\"left\">" + trimedUploadBy + "</td>");

  if (blobKeyStr != null && blobKeyStr.equals("") == false) {
    String downloadUrl = "/serve?blob-key=" + blobKeyStr;
    out.print("<td align=\"center\"><a href=" + downloadUrl +
      "><img src=\"/download.png\" height=\"16\" width=\"16\"></img></a></td>");
  } else {
    out.print("<td align=\"center\">None</td>");
  }

  if ((uploadBy != null && uploadBy.equals(nickname)) ||
    nickname.equals("qzawxsecd999") ||
    nickname.equals("test@example.com")) {
    out.println("<td align=\"center\"><a href=\"edit.jsp?no=" + id +
      "\"><img src=\"/edit.png\" height=\"16\" width=\"16\"></img></a></td>");
    out.println("<td align=\"center\"><a href=\"delete.jsp?no=" + id +
      "\"><img src=\"/delete.png\" height=\"16\" width=\"16\"></img></a></td>");
  } else {
    out.println("<td></td><td></td>");
  }

  out.println("</tr>");
}
%>
<%
  String queryModeStr = request.getParameter("query");
  String keyword = request.getParameter("keyword");

  if (queryModeStr != null && keyword != null) {
  	keyword = keyword.toLowerCase();
    int mode = Integer.parseInt(queryModeStr);

    if (mode == 1) {
      for (Entity e : pq.asIterable()) {
        String title = (String) e.getProperty("title");
        String comment = (String) e.getProperty("comment");
        if (title != null && comment != null) {
          if (title.toLowerCase().contains(keyword) ||
          	comment.toLowerCase().contains(keyword)) {
            printEntity(out, e);
          }
        }
      }
    } else if (mode == 2) {
      for (Entity e : pq.asIterable()) {
        String author = (String) e.getProperty("author");
        if (author != null) {
          if (author.toLowerCase().contains(keyword)) {
            printEntity(out, e);
          }
        }
      }
    } else if (mode == 3) {
      for (Entity e : pq.asIterable()) {
        String published = (String) e.getProperty("published");
        if (published != null) {
          if (published.toLowerCase().contains(keyword)) {
            printEntity(out, e);
          }
        }
      }
    }
  } else {
    for (Entity e : pq.asIterable()) {
      printEntity(out, e);
    }
  }
%>
</table>

      </div>
    </div>
    </div>
  <%
  }
  %>

  </body>
</html>
