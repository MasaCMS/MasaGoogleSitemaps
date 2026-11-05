/*

This file is part of the Masa CMS Google Sitemaps Plugin

Copyright 2017 BlueRiver Inc.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

*/
component persistent="false" accessors="true" output="false" extends="controller" {

	// *********************************  PAGES  *******************************************

	public any function default(required rc) {

		var siteid				= rc.siteid;
		var siteConfig			= rc.$.getBean('settingsManager').getSite(siteid);
		var siteProtocol		= siteConfig.get('useSSL') ? 'https://' : 'http://';
		var mailer				= rc.$.getBean("mailer");
		var tickCount			= getTickCount();
		var msg					= "";
		var fileName			= "";
		var sitemapManager		= $.getBean('GoogleSitemapsManager');
		var sitemapXML			= sitemapManager.getSitemap(rc.$,siteid);

		rc.gsmsettings.setValue('datelastgenerate',now());
		rc.gsmsettings.save();

		if(rc.gsmsettings.getValue('location') eq "web") {
			filename = expandPath('/murawrm/sitemap.xml');
			rc.fileURL	= siteProtocol & "#siteConfig.getDomain()##rc.$.globalConfig().getServerPort()##rc.$.globalConfig().getContext()#/sitemap.xml";
		}
		else if(rc.gsmsettings.getValue('location') eq "custom"){
			filename=expandPath("#rc.gsmsettings.getValue('customlocation')#/sitemap.xml");
			rc.fileURL	= "";
		} else {
			// Core decides whether sites live in /sites or directly in the webroot
			filename = rc.$.globalConfig().getSiteDir() & "/#siteid#/sitemap.xml";
			rc.fileURL	= siteProtocol & "#siteConfig.getDomain()##rc.$.globalConfig().getServerPort()##rc.$.globalConfig().getContext()##rc.$.globalConfig().getSiteAssetPath()#/#siteid#/sitemap.xml";
		}

		fileWrite(filename,sitemapXML);

		if( len( rc.gsmsettings.getValue('notifyemail') ) )  {

			try {
				mailer.sendHTML(msg,
					#rc.gsmsettings.getValue('notifyemail')#,
					"",
					"Google Sitemap for #siteConfig.getDomain()# - #siteid# complete.",
					siteid,
					siteConfig.getContactEmail() );
			}
			catch( any e ) {
					writeDump(e);
					abort;
			}
		}


		rc.time = (getTickCount()-tickCount);


	}

}
