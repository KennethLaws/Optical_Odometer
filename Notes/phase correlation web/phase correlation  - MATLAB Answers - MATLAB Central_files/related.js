function createOptions() {

    var options = {};

    options.targetElementClassName = 'relatedContentMicro';
    options.cacheRequests = JSON.parse(true);
    options.async = JSON.parse(true);
    options.debug = JSON.parse(false);
	options.showMainHeading = JSON.parse(true);
	options.heading = 'MATLAB Answers';
    options.showHeading = JSON.parse(true);
    options.maxTitleLength = 128;
    options.maxDescriptionLength = 72;
    options.maxSummaryLength = 50;
	options.primaryCore = 'answers';
    options.cores = ["answers"];
    options.fields = ["url", "title_en", "answers_count", "status", "asset_id", "asked_by", "methods_used"];
    options.rows = 3;
    options.startAt = 1;
    options.serviceUrl = '/searchresults/related/v1';
    options.itemUrl = '';
    options.itemID = 'answers:question:' + document.getElementById(options.targetElementClassName).getAttribute("itemID");
	
	options.filters = ["(subcollection:answers)", "-(status:unanswered)"];
	options.excludeIDs = document.getElementById(options.targetElementClassName).getAttribute("excludeIDs");
	
    options.itemTemplate = '<div class="media" style="margin-bottom:10px;">'+
                           '    <a href="{{url}}" title="{{title_en}}">'+
                           '        <p class="related-title">{{title_en}}</p>'+
                           '    </a>'+
                           '    <div class="answer-count-status {{status}}">{{answers_count}}<span style="color:#000000; float:right;">{{mathworks-support-membrane}}</span></div>'+
						   '</div>';
    options.tracking = ['answers_rc1-1_p1', 'answers_rc1-2_p2', 'answers_rc1-3_p3'];
	  
    mwRelatedContentLib.init(options);
	

    var options2 = {};

    options2.targetElementClassName = 'relatedContentMacro';
    options2.cacheRequests = JSON.parse(true);
    options2.async = JSON.parse(true);
    options2.debug = JSON.parse(false);
	options2.showMainHeading = JSON.parse(true);
	options2.heading = 'Entire Website';
    options2.showHeading = JSON.parse(true);
    options2.maxTitleLength = 128;
    options2.maxDescriptionLength = 72;
    options2.maxSummaryLength = 50;
	options2.primaryCore = 'answers';
    options2.cores = ["fileexchange", "latest_documentation", "entire_site","examples-gallery"];
    options2.fields = ["url", "title_en", "answers_count", "subcollection", "methods_used"];
    options2.rows = 3;
    options2.startAt = 1;
    options2.serviceUrl = '/searchresults/related/v1';
    options2.itemUrl = '';
    options2.itemID = 'answers:question:' + document.getElementById(options2.targetElementClassName).getAttribute("itemID");
    
    options2.filters = ["-(subcollection:fileexchange_nopub)"];
    
    options2.itemTemplate = '<div class="media" style="margin-bottom:10px;">'+             
                            '    <a href="{{url}}" title="{{title_en}}">'+
                            '        <p class="related-title">{{title_en}}</p>'+
                            '    </a>'+
				            '    <div class="small">{{subcollection}}</div>'+
                            '</div>';
    options2.tracking = ['answers_rc2-1_p4', 'answers_rc2-2_p5', 'answers_rc2-3_p6'];

	mwRelatedContentLib.init(options2);  
}

jQuery(document).ready(function(){
    createOptions();		   
});