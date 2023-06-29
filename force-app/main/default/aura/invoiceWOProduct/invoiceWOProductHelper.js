({
	helperMethod : function() {
		
	},
    getRecordTypeList : function(component,event,objectName){
        var action = component.get('c.workOrderType');
        action.setParams({
            ObjectName : objectName,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var allValues = response.getReturnValue();
                component.set('v.WORecordTypeList',allValues);  
            } 
        });
        $A.enqueueAction(action);
    },
    showErrorToast : function(component, event) {
        var errorMessage = component.get('v.errorMessage');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": "error",
            "title": "Error!",
            "message": errorMessage,
        });
        toastEvent.fire();
    },
    getFieldSetList : function(component,event,objectName){
        var action = component.get('c.getAllfeildsets');
        action.setParams({
            ObjectName : objectName,
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var allValues = response.getReturnValue();
                if(objectName=='Work_Order__c')
                	component.set('v.WOFieldSetList',allValues);  
                else if(objectName=='Work_Order_Line_Item__c')
                    component.set('v.WOLIFieldSetList',allValues);
            } 
        });
        $A.enqueueAction(action);
    },
    SetOpportunityFields : function(component,event,helper){
		 var action = component.get("c.objectFeildsSecond");  
        action.setParams({ 
            objectName : 'Opportunity',
            fieldType : 'All',
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var optionsList = [];
                var allValues = response.getReturnValue();
                console.log("all Oppo Fields Values =>",allValues);
                component.set('v.picklistOptionsList', allValues); 
                component.set('v.picklistOptionsListDuplicate', allValues);
                
                console.log("AllOppoField",JSON.stringify(component.get('v.picklistOptionsListDuplicate')));
               
              
                
              
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if(errors){
                    if(errors[0] && errors[0].message){
                        console.log("Error Message1: " + errors[0].message);
                    }
                }
                else{
                    console.log("Unknown Error");
                }
            }
        });        
        $A.enqueueAction(action);  
    
    }
    
})