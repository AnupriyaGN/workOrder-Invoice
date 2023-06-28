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
    }
    
})