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
        
        helper.SetNewFilterPreValues(component,event);
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
        component.set("v.NewFilter");
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
    createNewFilter : function(component, event,helper){
        // set opp fields for dropdown
        helper.SetOpportunityFields(component, event);
        component.set('v.NewFilter',true);
        component.set('v.UI1',false);
        component.set('v.Configuration',false);
    },
    // NEw Filter upto operator selection.
    getSelectedCondition : function(component,event,helper){
        console.log('getSelectedCondition',component.get("v.opportunityfieldMapping[0].ruleName"));
        console.log('getSelectedCondition  bbbbb',component.get("v.opportunityfieldMapping[0].condition"));
    },
    getFieldValueOpportunity : function(component,event,helper){        
        var indexValue = event.getSource().attributes.name.Qh;
        var vv = "v.opoInnerList["+indexValue+"].opportunityselectField";
        var currentField = component.get(vv);        
        if(component.get(vv) != event.getSource().get('v.value')){            
            var oppfieldList = component.get("v.opoInnerList");
            oppfieldList.splice(indexValue,1);
			helper.SetNewFilterPreValues(component,event);
        }
        var action = component.get("c.fieldTypeMacherSecond");         
        action.setParams({
            objectName : 'Opportunity',
            fieldLabel : currentField,   
        });  
        action.setCallback(this, function(response){            
            var state = response.getState();           
            if(state === "SUCCESS"){
                var allValues = response.getReturnValue();                
                var valNames = Object.values(allValues);                
                var keyNames = Object.keys(allValues); 
                var vv = "v.opoInnerList["+indexValue+"].typeInput";
        		component.set(vv,allValues);        
                component.set('v.typeInput', allValues);
                if(component.get('v.typeInput')=='PICKLIST'){
                    vv = "v.opoInnerList["+indexValue+"].PICKLIST";
                    component.set(vv,true);
                    vv = "v.opoInnerList["+indexValue+"].BOOLEAN";
                    component.set(vv,false);
                    vv = "v.opoInnerList["+indexValue+"].typeInput";
                	component.set(vv,false);
                }
                else if(component.get('v.typeInput')=='BOOLEAN'){
                    vv = "v.opoInnerList["+indexValue+"].BOOLEAN";
                    component.set(vv,true);
                    vv = "v.opoInnerList["+indexValue+"].PICKLIST";
                    component.set(vv,false);
                    vv = "v.opoInnerList["+indexValue+"].typeInput";
                	component.set(vv,false);
                }
                else{
                    if(component.get('v.typeInput') == 'CURRENCY'){                        
						vv = "v.opoInnerList["+indexValue+"].typeInput";
                		component.set(vv,'number');
                        component.set('v.typeInput','number');                        
                    }
                    else{
                        vv = "v.opoInnerList["+indexValue+"].typeInput";
                		component.set(vv,allValues);
                    }
                    vv = "v.opoInnerList["+indexValue+"].BOOLEAN";
                    component.set(vv,false);
                    vv = "v.opoInnerList["+indexValue+"].PICKLIST";
                    component.set(vv,false);
                }
                console.log('AfterPickList',component.get('v.opoInnerList'));
            }
            else if(state === "ERROR") {
                console.log('After : error');
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error Message2: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            }
        });        
        $A.enqueueAction(action);
        var removeSelected = component.get("v.removeSelected");  
        console.log('indexValue',indexValue);
        console.log('testing:--',removeSelected.indexValue);  
        
        if(removeSelected==null)
       		removeSelected.push(event.getSource().get('v.value'));
        else if(removeSelected[indexValue]==null)
            removeSelected.push(event.getSource().get('v.value'));
        else
            removeSelected[indexValue] = event.getSource().get('v.value');
        
        component.set("v.removeSelected",removeSelected);
        console.log('testing again :-',component.get("v.removeSelected"));
       	var allFields = component.get('v.picklistOptionsListDuplicate');        
        var duplicateList = []; 
        var removeSelected = component.get("v.removeSelected");
        allFields.map(val=>{
            var bool = false;
            removeSelected.map(val1=>{
            	if(val.label==val1)
            	{
            		bool = true
        		}	
        	});	
            if(bool!=true){
                var item = {
                    "label":val.label,
                    "value":val.label,
                };
               duplicateList.push(item);
            }   
    	});
		component.set('v.picklistOptionsList',duplicateList);
    },
    getInsertValueNewFilter : function(component,event,helper){                  
        var indexValue = event.getSource().attributes.name.Qh;
        console.log('index value:-',indexValue);
        var opoInnerListRow= component.get("v.opoInnerList");        
        console.log('test======>',JSON.stringify(component.get("v.opoInnerList")));
        var selectedField = "v.opoInnerList["+indexValue+"].opportunityselectField";
        var typeInput = "v.opoInnerList["+indexValue+"].typeInput";
        var operator = "v.opoInnerList["+indexValue+"].operator";
       	var enteredValue = "v.opoInnerList["+indexValue+"].enteredValue";
        var listForOppInnerList = [];
        for(var ke in opoInnerListRow){
            
            console.log('valll',ke);
            console.log(" -> " + Object.keys(opoInnerListRow[ke]));
            console.log(" -> " + Object.values(opoInnerListRow[ke]));
        }
        
        console.log('values of oppInnerList:-',component.get("v.opoInnerList"));
        console.log('value of row ',component.get(selectedField) , component.get(typeInput) , component.get(operator), component.get(enteredValue));  
    },
    oppoFieldAddNewRow : function(component,event,helper){
     	helper.SetNewFilterPreValues(component,event);
    }
})