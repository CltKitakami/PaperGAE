package com.cloud.papergae;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.AbstractMap.SimpleEntry;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.api.datastore.Transaction;

@SuppressWarnings("serial")
public class Upload extends HttpServlet {
	final DatastoreService dataService = DatastoreServiceFactory.getDatastoreService();
	final BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService();

    @Override
    public void doPost(HttpServletRequest req, HttpServletResponse resp)
        throws ServletException, IOException {

    	System.out.println("Upload servlet");
    	
    	String service = req.getParameter("service");
    	long paperId = 0;

		if (service == null) {
			resp.getWriter().println("service is {null}");
			
		} else if (service.equals("upload")) {
			paperId = findLastPaperId() + 1;
	        Map<String, List<BlobKey>> blobs = blobstoreService.getUploads(req);
	        List<BlobKey> blobKeys = blobs.get("paperFile");
	
	        if (blobKeys == null || blobKeys.isEmpty()) {
	            resp.sendRedirect("/UploadFail.html");
	        } else {
	        	String blobKeyStr = blobKeys.get(0).getKeyString();
	        	processUpload(req, resp, paperId, blobKeyStr);
	            //resp.sendRedirect("/serve?blob-key=" + blobKeyStr);
	        }
		}
    }
    

    @Override
    public void doGet(HttpServletRequest req, HttpServletResponse resp)
    	        throws ServletException, IOException {

    	System.out.println("Upload servlet");
    	
    	String service = req.getParameter("service");
    	long paperId = 0;

		if (service == null) {
			resp.getWriter().println("service is {null}");
		} else if (service.equals("update")) {
			String paperIdStr = req.getParameter("paperId");
			if (paperIdStr != null) {
				paperId = Long.parseLong(paperIdStr);
				processUpload(req, resp, paperId, req.getParameter("blobKey"));
			} else {
				resp.setContentType("text/plain");
				resp.getWriter().println("update paper ID = {null}");
			}
		}
    }
    

	private long findLastPaperId() {
		Query qry = new Query("PAPER");
        Iterable<Entity> entitys = dataService.prepare(qry).asIterable();
        long maxId = 0;
        for (Entity e : entitys) {
        	long id = e.getKey().getId();
        	if (maxId < id) {
        		maxId = id;
        	}
        }
		return maxId;
	}

	private void processUpload(HttpServletRequest req, HttpServletResponse resp, long paperId, String blobKeyStr)
			throws IOException {
		PrintWriter out = resp.getWriter();
		
		List<SimpleEntry<String, String>> list = new ArrayList<>();
		list.add(new SimpleEntry<String, String>("title", req.getParameter("title")));
		list.add(new SimpleEntry<String, String>("author", req.getParameter("author")));
		list.add(new SimpleEntry<String, String>("published", req.getParameter("published")));
		list.add(new SimpleEntry<String, String>("dateOfConference", req.getParameter("dateOfConference")));
		list.add(new SimpleEntry<String, String>("comment", req.getParameter("comment")));
		list.add(new SimpleEntry<String, String>("uploadBy", req.getParameter("uploadBy")));
		list.add(new SimpleEntry<String, String>("blobKey", blobKeyStr));
		
		if (uploadToGae(paperId, list) != 0) {
			resp.sendRedirect("/UploadSuccess.html");
		} else {
			resp.sendRedirect("/UploadFail.html");
		}
	}
	
	private int uploadToGae(long paperId, List<SimpleEntry<String, String>> list) {
		System.out.println("=============uploadToGae");
		System.out.println("id = " + paperId);
		Transaction transaction = dataService.beginTransaction();
		int isSuccessful = 0;
		
		try {
			Entity e = new Entity("PAPER", paperId);
			
			for (SimpleEntry<String, String> se : list) {
				e.setProperty(se.getKey(), se.getValue());
				System.out.println("" + se.getKey() + " = " + se.getValue());
			}
			
			dataService.put(e);
			transaction.commit();
			isSuccessful = 1;
		} finally {
			if (transaction.isActive()) {
				transaction.rollback();
			}
		}
		
		return isSuccessful;
	}
	
}
