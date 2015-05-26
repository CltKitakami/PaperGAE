package com.cloud.papergae;

import java.io.IOException;
import java.util.Map;

import javax.servlet.http.*;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.*;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;


@SuppressWarnings("serial")
public class PaperGAEServlet extends HttpServlet {
	final DatastoreService dataService = DatastoreServiceFactory.getDatastoreService();
	final BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();
	final String redirectHtmlBegin = "<html><head><script type=\"text/javascript\">window.location = \"/";
	final String redirectHtmlEnd = ".html\"</script></head><body></body></html>";

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
	
		String service = req.getParameter("service");
            
		if (service == null) {
			resp.getWriter().println("service is {null}");
		} else if (service.equals("delete")) {
			String paperId = req.getParameter("paperId");
			if (paperId != null) {
				if (executeDelete(Integer.parseInt(paperId)) != 0) {
					resp.sendRedirect("/DeleteSuccess.html");
				} else {
					resp.setContentType("text/plain");
					resp.getWriter().println("delete fail");
				}
			} else {
				resp.setContentType("text/plain");
				resp.getWriter().println("delete paper ID = {null}");
			}
		} else if (service.equals("search")) {
			String queryModeStr = req.getParameter("query");
			String keyword = req.getParameter("keyword");
			if (queryModeStr != null && keyword != null) {
				int mode = Integer.parseInt(queryModeStr);
				switch (mode) {
				case 1:
					executeSelectFromPaperWhereTitleComment(keyword);
					break;
				default:
					executeSelectAll("PAPER");
					break;
				}
			}
		} else {
			resp.setContentType("text/plain");
			resp.getWriter().println("Unknow service: " + service);
		}
		
	}
	
	private void queryFromGae(long paperId) {
		System.out.println("=============queryFromGae");
        try {
        	System.out.println("id = " + paperId);
        	Key todoKey = KeyFactory.createKey("PAPER", paperId);
        	Entity entity = dataService.get(todoKey);
        	for (Map.Entry<String, Object> mapEntry : entity.getProperties().entrySet())
				System.out.println("" + mapEntry.getKey() + " = " + mapEntry.getValue());
        } catch (EntityNotFoundException e) {
            System.out.println("Entry not found.");
        }
        
	}
	
	private int executeCount(String entity) {
        Query qry = new Query(entity);
        int totalCount = dataService.prepare(qry).countEntities(FetchOptions.Builder.withDefaults());
        return totalCount;
	}
	
	private int executeDelete(long paperId) {
		System.out.println("=============executeDelete");
		Transaction transaction = dataService.beginTransaction();
		int isSuccessful = 0;

		try {
			Key todoKey = KeyFactory.createKey("PAPER", paperId);
			Entity entity = dataService.get(todoKey);
			
			String blobKeyStr = (String) entity.getProperty("blob-key");
			if (blobKeyStr != null) {
				BlobKey blobKey = new BlobKey(blobKeyStr);
	            blobstoreService.delete(blobKey);
			}
			
	        dataService.delete(entity.getKey());
			transaction.commit();
			isSuccessful = 1;
		} catch (EntityNotFoundException e) {
			if (transaction.isActive()) {
				transaction.rollback();
			}
			e.printStackTrace();
		} finally {
			if (transaction.isActive()) {
				transaction.rollback();
			}
		}
		
		return isSuccessful;
	}
	
	private void executeSelectAll(String entity) {
		System.out.println("=============executeSelectAll");
		Query qry = new Query(entity);
        Iterable<Entity> entitys = dataService.prepare(qry).asIterable();
        for (Entity e : entitys) {
        	for (Map.Entry<String, Object> mapEntry : e.getProperties().entrySet())
				System.out.println("" + mapEntry.getKey() + " = " + mapEntry.getValue());
        }
	}
	
	private void executeSelectFromPaperWhereTitleComment(String keyword) {
		System.out.println("=============executeSelectFromPaperWhereTitleComment");
		Query qry = new Query("PAPER");
        Iterable<Entity> entitys = dataService.prepare(qry).asIterable();
        for (Entity e : entitys) {
        	String title = (String) e.getProperty("title");
        	String comment = (String) e.getProperty("comment");
        	
        	if (title != null && comment != null) {
        		if (title.contains(keyword) || comment.contains(keyword)) {
        			System.out.println("Id " + e.getKey().getId() + " match: " + title);
        		}
        	}
        }
	}
	
	private void executeSelectFromPaperWhereAuthor(String keyword) {
		System.out.println("=============executeSelectFromPaperWhereAuthor");
		Query qry = new Query("PAPER");
        Iterable<Entity> entitys = dataService.prepare(qry).asIterable();
        for (Entity e : entitys) {
        	String author = (String) e.getProperty("Author");
        	
        	if (author != null) {
        		if (author.contains(keyword)) {
        			System.out.println("Id " + e.getKey().getId() + " match: " + author);
        		}
        	}
        }
	}

	private void executeDeleteAll(String entity) {
		System.out.println("=============executeDeleteAll");
		Query qry = new Query(entity);
        Iterable<Entity> entitys = dataService.prepare(qry).asIterable();

		try {
	        for (Entity e : entitys) {
	        	dataService.delete(dataService.get(e.getKey()).getKey());
	        }
		} catch (EntityNotFoundException e) {
			e.printStackTrace();
		}
	}
}
