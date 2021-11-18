<cfsilent>
<!---

This file is part of the Masa CMS Google Sitemaps Plugin

Copyright 2017 BlueRiver Inc.
Licensed under the Apache License, Version v2.0
http://www.apache.org/licenses/LICENSE-2.0

--->
</cfsilent>
<cfoutput>
	<cfif not rc.gsmsettings.get("isEnabled")>
		<div class="alert alert-error">
			<a href="#buildURL('admin:settings')#">Google Sitemaps is not currently enabled for this site. Go to the <strong>Settings tab</strong> and set <strong>Enabled</strong> to <strong>Yes</strong>.</a>
		</div>
	</cfif>

	<h2>About</h2>
	<p>Google Sitemaps is a plugin that automates sitemap generation for your Masa CMS website.</p>

	<p>The plugin will generate on demand or on a scheduled basis a sitemap.xml (as well as other specialized sitemap files) based upon the configuration information you have set for each page.
		By default all pages are included in the Google sitemap, but you can configure these settings under the "Sitemap" tab for each content page.</p>

</cfoutput>
