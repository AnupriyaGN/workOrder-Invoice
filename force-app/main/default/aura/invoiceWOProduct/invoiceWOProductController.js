({
	myAction : function(component, event, helper) {
		component.set("v.UI1",true);
        // all filter list UI1
        var action = component.get('c.getWorkOrderSettingRecords');
        action.setParams({
            recId : null,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state); 
            if(state === "SUCCESS"){
                var allValues = response.getReturnValue();
                component.set('v.allFilterList',allValues);
                component.set('v.Feild_Mapping_JSON__c',allValues[0].Feild_Mapping_JSON__c);
            } 
        });
        $A.enqueueAction(action);
        
        //Get list of record type for WO
        helper.getRecordTypeList(component,event,'Work_Order__c');
        console.log('get valuess:-',component.get("v.WOLIRecordTypeList"));
        helper.getFieldSetList(component,event,'Work_Order__c');
        helper.getFieldSetList(component,event,'Work_Order_Line_Item__c');
        
        var opportunityFieldlist = component.get('v.opportunityfieldMapping');
        	opportunityFieldlist.push({
            	'condition':'',
            	'logicValue':'',
            	'ruleName':'',
            	'active':false,
            	'InnerList':[],
        });   
        component.set('v.opportunityfieldMapping',opportunityFieldlist); 
	},
    openFilterList : function(component,event,helper){
        component.set("v.ShowFilter",true);
    },
    handleFilterChangeButton : function(component,event,helper){
        component.set("v.ShowFilter",false);
        component.set("v.CurrentFilter",event.currentTarget.dataset.filter);
    },
    openConfigurations : function(component,event,helper){
        component.set("v.Configuration",true);
        component.set("v.UI1",false);
        component.set("v.Platform",true);
        component.set("v.WO",true);
        component.set("v.WOLI",true);
    },
    BackToUI1: function(component,event,helper){
		component.set("v.Configuration",false);
        component.set("v.UI1",true);
    },
    getSalesCloudPlatform : function(component,event,helper){
        component.set("v.platformSelectionList",[]);
        var platformSelectionList = component.get("v.platformSelectionList");
        platformSelectionList.push({
            "salesCloud" : false,
            "salesforceCPQ" : false,
            "OnlyOpportunity" : false,
        });
        component.set("v.platformSelectionList",platformSelectionList);
        var PSCheckboxList = document.getElementsByClassName("PSCheckbox");
        for(var i=0;i<PSCheckboxList.length;i++)
        {
			PSCheckboxList.item(i).checked = false;
        }
        event.target.checked = true;
        var platformSelectionList = component.get("v.platformSelectionList");
        platformSelectionList[0][event.target.id] = true;
        component.set("v.platformSelectionList",platformSelectionList);
        console.log('platformSelectionList List is: ',JSON.stringify(component.get("v.platformSelectionList")));
    },
    addWORecordType : function(component,event,helper){
        var WORecordTypeSelectedValue = component.get("v.WOrecordTypeValue"); 
        var listWO = component.get("v.WOrecordTypeListSelected");
        var bool = false;
        for(var i=0;i<listWO.length;i++){
            if(listWO[i] == WORecordTypeSelectedValue)
                bool = true;
        }
        if(bool!=true)  
       		listWO.push(WORecordTypeSelectedValue);
        component.set("v.WOrecordTypeListSelected",listWO);
        
    },
    addWOFieldSet : function(component, event, helper){
        var WOFieldSetSelectedValue = component.get("v.WOFieldSetValue"); 
        var listWO = component.get("v.WOFieldSetValueListSelected");
        var bool = false;
        for(var i=0;i<listWO.length;i++){
            if(listWO[i] == WOFieldSetSelectedValue)
                bool = true;
        }
        if(bool!=true)  
       		listWO.push(WOFieldSetSelectedValue);
        component.set("v.WOFieldSetValueListSelected",listWO);
    },
    addWOLIFieldSet : function(component, event, helper){
        var WOLIFieldSetSelectedValue = component.get("v.WOLIFieldSetValue"); 
        var listWO = component.get("v.WOLIFieldSetValueListSelected");
        var bool = false;
        for(var i=0;i<listWO.length;i++){
            if(listWO[i] == WOLIFieldSetSelectedValue)
                bool = true;
        }
        if(bool!=true)  
       		listWO.push(WOLIFieldSetSelectedValue);
        component.set("v.WOLIFieldSetValueListSelected",listWO);
    },
    viewFilter : function(component, event, helper){
    	console.log('in view filter');
        console.log(event.currentTarget.dataset.recordid);
        
    },
    createNewFilter : function(component, event, helper){
        console.log('in newfilter');
        var platformSelectionList = component.get("v.platformSelectionList");
        //component.set('v.UI1', false);  
        //component.set('v.NewFilter', true); 
        //component.set('v.Configuration', false);
        
        /*console.log('tetsing   ',component.get("v.EditFilter"));
        if(component.get("v.EditFilter")){
            console.log('in if condition');
            helper.selectOptions(component, event);
            helper.getWorkOrderField(component, event);
            helper.getWorkOrderLineItemField(component, event);
            helper.woRelatedPicklistValue(component, event);
            component.set("v.errorMessage","");
            component.set('v.setFilterToggle',true);
            component.set('v.hideUI1', true);
            console.log("Hello,1");
            component.set('v.onNewFilterToggle', true);
            console.log("Hello,2");
            component.set('v.allFiltersToggle',false);
            component.set("v.viewFilterToggle",false);
            console.log("Helle,3");
            component.set('v.onInvoiceFilterToggle', false);
            
        }*/
         
         
       	/*if(component.get("v.WOrecordTypeListSelected").length <= 0){            
       		component.set("v.errorMessage","Please Fill RecordType Configuration");
            helper.showErrorToast(component, event);
        }else if(component.get("v.WOFieldSetValueListSelected").length <= 0){            
            component.set("v.errorMessage","Please Fill WorkOrder FieldSet Configuration");
            helper.showErrorToast(component, event);
        }else if(component.get("v.WOLIFieldSetValueListSelected").length <= 0){            
            component.set("v.errorMessage","Please Fill WorkOrder LineItem FieldSet Configuration");
            helper.showErrorToast(component, event);
        }else if(platformSelectionList[0].salesCloud == false && platformSelectionList[0].salesforceCPQ == false  && platformSelectionList[0].OnlyOpportunity == false){        	
            component.set("v.errorMessage","Please Select One Platform");
            helper.showErrorToast(component, event);
        }*/
        
        
            console.log('everything is okay!!');
            //helper.selectOptions(component, event);
            //helper.getWorkOrderField(component, event);
            //helper.getWorkOrderLineItemField(component, event);
            //helper.woRelatedPicklistValue(component, event);
            component.set("v.errorMessage","");
            //component.set('v.setFilterToggle',true);
            component.set('v.UI1', false);  
            console.log('Before New filter :',component.get('v.NewFilter'));
            component.set('v.Configuration', false);
            component.set("v.NewFilter",true); 
            console.log('After New filter :',component.get('v.NewFilter'));
            
            //component.set('v.onNewFilterToggle', true);            
            //component.set('v.allFiltersToggle',false);            
            //component.set('v.onInvoiceFilterToggle', false);
        
    },
    getRuleName : function(component,event,helper){
        
    }
   
})