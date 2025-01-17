component extends="mura.plugin.pluginGenericEventHandler" {
	variables.package = "";
	variables.groupStudent = "";
	variables.groupProvider = "";
	$ = "";
	variables.pluginpath = "";

	public void function onApplicationLoad(required struct $) {

		var ioc=getServiceFactory();
		var bean = "";

		variables.$ = arguments.$;

		var beanArray=[
			'gsmsettings'
			];

		var checkSchema=isDefined('url.applydbupdates') || !ioc.containsBean('gsmsettings');

		variables.package = arguments.$.getPlugin("MasaGoogleSitemaps");

		variables.pluginPath =
			variables.$.globalConfig('context')
			& '/plugins/'
			& variables.package.getPackage();

		for(var item in beanArray){
			try {
				ioc.declareBean(beanName=item, dottedPath='MasaGoogleSitemaps.model.bean.#item#', isSingleton = false );

			// call instance
				bean = ioc.getBean(item);
			}
			catch( any e ) {
				writeDump(item);
				writeDump(e);
				abort;
			}

			// check schema on each bean first
			if(checkSchema){
				try {
					bean.checkSchema();
				}
				catch( any e ) {
					writeDump(item);
					writeDump(e);
					abort;
				}
			}
		}

		ioc.declareBean(beanName='GoogleSitemapsManager', dottedPath='MasaGoogleSitemaps.model.manager.googlesitemapsmanager', isSingleton = true );

		variables.pluginConfig.addEventHandler(this);
		validateSession();

		var assignedSites=variables.pluginConfig.getAssignedSites();
		var pluginManager=getBean('pluginManager');

		for(var s=1;s <=assignedSites.recordcount;s++){
			var site=getBean('settingsManager').getSite(assignedSites.siteid[s]);

			var APIUtility=site.getApi('json','v1');

			APIUtility.secureRequest = this.secureRequest;
			APIUtility.registerMethod('echo',echo);

			for(var item in beanArray){
				var config={
						moduleid=variables.pluginConfig.getModuleID(),
						public=false
					};

				APIUtility.registerEntity(item,config);
			}
		}
		validateSession();

		// Check for every site when the Task is enabled, that the Task actually exists
		// We need to check this, beacause deploying a new cloud container instance the task is lost

		// Get all the sites
		var allSites = arguments.$.getBean('settingsManager').getSites();
		// Get all the scheduled tasks
		schedule action="list" returnvariable="rsSchedules";
		// Convert to array
		var arSchedules = QueryColumnData(rsSchedules,'task');

		for(var currentSiteID in allSites){
			var gsmsettings = arguments.$.getBean('gsmsettings').loadBy(siteid = currentSiteID);
			if(gsmsettings.getIsEnabled()){
				var currentDomain = arguments.$.getBean('settingsManager').getSite(currentSiteID).get('domain');
				var scheduleTaskName = "Masa Google Sitemaps #currentDomain# - #currentSiteID#";
				// Task is enabled, but doesnt exist
				if(!arSchedules.find(scheduleTaskName)){
					// Create the task
					arguments.$.getBean('GoogleSitemapsManager').schedule(arguments.$, currentSiteID, true);
				}
			}
		}

		arguments.$.announceEvent('GSMApplicationLoad');

	}

	remote function echo() {
		arguments['echo'] = true;
		return arguments;
	}

	function onSiteAsyncRequestStart($){
		$.announceEvent('GSMGlobalRequestStart');


//		$.setCustomMuraScopeKey(variables.package.getPackage(), new scopeFunctions().setScope($));
	}

	function onGlobalRequestStart($){
		$.announceEvent('GSMGlobalRequestStart');

//		$.setCustomMuraScopeKey(variables.package.getPackage(), new scopeFunctions().setScope($));
	}

	function onContentEdit ( $ ) {
	}

	function onSiteRequestStart($){
		$.announceEvent('GSMSiteRequestStart');

//		$.setCustomMuraScopeKey(variables.package.getPackage(), new scopeFunctions().setScope($));
	}

	function onSiteLogin($) {
		validateSession();

	}

	function onAICSiteRequestStart($){
		$.announceEvent('AICConnectionReset');
	}

	function onAfterSiteLogout($){
	}

	function onRenderStart($) {

		validateSession();
	}

	function onAdminHTMLHeadRender( $ ) {

		var jsAdded = "";

		savecontent variable="jsAdded" {
//			writeOutput("<script type='text/javascript' src='#variables.pluginPath#/includes/assets/js/admin.js'></script>");
		}

		return jsAdded;

	}

	function onSiteSessionEnd($){
		onGlobalSessionEnd(argumentCollection=arguments);
	}

	function onBeforeUserSave( any $,any event ) {
	}

	function onBeforeUserUpdate(any $,any event) {
		onBeforeUserSave( argumentCollection=arguments );
	}

	function onAfterUserSave( any $,any event ) {

	}

	function onAfterUserUpdate(any $,any event) {
		onAfterUserSave( argumentCollection=arguments );
	}

	function secureRequest( $ ) {
		return false;
	}

	private function validateSession() {
		if( !isDefined("session") )
			return;

		if( !structKeyExists( session,'GSM')) {
			session['GSM'] = {};
		}
	}


}
