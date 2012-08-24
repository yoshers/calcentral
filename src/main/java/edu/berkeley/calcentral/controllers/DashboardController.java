package edu.berkeley.calcentral.controllers;

/**
 * DashboardController.java
 * Copyright (c) 2012 The Regents of the University of California
 */
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

/**
 * Controller for pulling up the initial dashboard after a user logs in.
 */
@Controller
public class DashboardController {
	
	/**
	 * GET call for the dashboard. 
	 * 
	 * @param model map to return to the view.
	 * @param request servlet request object.
	 * @return dashboard view.
	 */
	@PreAuthorize("hasRole('ROLE_USER')")
	@RequestMapping(value = { "/dashboard" }, method = RequestMethod.GET)
	public String getDashboard(
			Map<String, Object> model,
			HttpServletRequest request) {
		String uid = request.getUserPrincipal().getName();
		model.put("uid", uid);
		return "dashboard";
	}
}
