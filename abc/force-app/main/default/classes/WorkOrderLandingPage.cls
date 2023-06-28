public class WorkOrderLandingPage {
    
    //Saves/update configration in custom setting in org.
    @AuraEnabled
    public static void saveConfigrationCustomSetting(String PlatformConfigration, String ProductField, String WOLIFieldset, String WorkOrderRecordType, String WOFieldset){
        
        if((Configrations__c.getOrgDefaults().ID != null) == true){
            Configrations__c mc = Configrations__c.getOrgDefaults();
           		mc.PlatformConfigration__c = PlatformConfigration;
            	mc.ProductField__c = ProductField;
            	mc.WOLIFieldset__c = WOLIFieldset;
            	mc.Work_Order_Record_Type__c = WorkOrderRecordType;
            	mc.WOFieldset__c = WOFieldset;
            update mc;
        }
        else{
			Configrations__c mc = new Configrations__c();
           		mc.PlatformConfigration__c = PlatformConfigration;
            	mc.ProductField__c = ProductField;
            	mc.WOLIFieldset__c = WOLIFieldset;
            	mc.Work_Order_Record_Type__c = WorkOrderRecordType;
            	mc.WOFieldset__c = WOFieldset;
            insert mc;            
        }
    }
	
	//fetch configration Setting values from custom settings of the org.
    @AuraEnabled
    public static Map<String , String > getConfigrationCustomSetting(){
        
        Map<String , String > returnMap = new Map<String , String >();
        Configrations__c mc = Configrations__c.getOrgDefaults();     
        if((mc.ID != null) == true){
            returnMap.put('PlatformConfigration',mc.PlatformConfigration__c);
            returnMap.put('ProductField',mc.ProductField__c);
            returnMap.put('WOFieldset',mc.WOFieldset__c);
            returnMap.put('WorkOrderRecordType',mc.Work_Order_Record_Type__c);
            returnMap.put('WOLIFieldset',mc.WOLIFieldset__c);
        }
        System.debug('returnMap--->'+returnMap);
        return returnMap;
    }   
    
    //Returns all feild sets of an object.
    @AuraEnabled
    public static List <String> getAllfeildsets(String ObjectName){
        List <String> fieldSetName = new List <String>();
        if(ObjectName != NULL || ObjectName != ''){
            for(Schema.FieldSet fs: Schema.getGlobalDescribe().get(ObjectName).getDescribe().FieldSets.getMap().values()){
                fieldSetName.add(fs.getLabel());
            }
        }
        system.debug('fieldSetNamefieldSetName'+fieldSetName);
        return fieldSetName;
    }
    
    //Returns filter condition from work order setting for editing. Pass Id of WorkOrder Setting record.
    @AuraEnabled
    public static List<Filterwrapper> getWorkOrderSettingFilter(ID recordID){
        List < Filterwrapper > WODataUpdate = new List < Filterwrapper >();
        if(recordID != NULL){
            List<Work_Order_Setting__c> fetchedWorkOrderSettings = [SELECT Filter_JSON__c, Id FROM Work_Order_Setting__c where Id =:recordID];
            WODataUpdate = ( List < Filterwrapper > ) JSON.deserialize( fetchedWorkOrderSettings.get(0).Filter_JSON__c ,List < Filterwrapper >.class);
        } 
        System.debug('WODataUpdate=>'+WODataUpdate);
        return WODataUpdate;
    }
    
    //Returns invoice condition from work order setting for editing. Pass Id of WorkOrder Setting record.
    @AuraEnabled
    public static List<invoiceingFieldsMapping> getWorkOrderInvoiceSettings(ID recordID){
        List < invoiceingFieldsMapping > WODataUpdate = new List < invoiceingFieldsMapping >();
        if(recordID != NULL){
            List<Work_Order_Setting__c> fetchedWorkOrderSettings = [SELECT Invoice_Payment_JSON__c , Id FROM Work_Order_Setting__c where Id =:recordID];
            WODataUpdate = ( List < invoiceingFieldsMapping > ) JSON.deserialize( fetchedWorkOrderSettings.get(0).Invoice_Payment_JSON__c  ,List < invoiceingFieldsMapping >.class);
        } 
        System.debug('WODataUpdate=>'+WODataUpdate);
        return WODataUpdate;
    }
    //Returns filter condition from work order setting for editing. Pass Id of WorkOrder Setting record.
    @AuraEnabled
    public static List<Filterwrapper> getWorkOrderFieldSetJSON(ID recordID){
        List < Filterwrapper > WODataUpdate = new List < Filterwrapper >();
        if(recordID != NULL){
            List<Work_Order_Setting__c> fetchedWorkOrderSettings = [SELECT Id, WorkOrder_FieldSet_JSON__c FROM Work_Order_Setting__c where Id =:recordID];
            WODataUpdate = ( List < Filterwrapper > ) JSON.deserialize( fetchedWorkOrderSettings.get(0).Filter_JSON__c ,List < Filterwrapper >.class);
        }    
        return WODataUpdate;
    }
    
    //Returns workorder mapping condition from work order setting for editing. Pass Id of WorkOrder Setting record.
    @AuraEnabled
    public static List<ConditionsWrapper> getWorkOrderSettingWOrderCondition (ID recordID){
        List < ConditionsWrapper > WODataUpdate = new List < ConditionsWrapper >();
        if(recordID != NULL){
            List<Work_Order_Setting__c> fetchedWorkOrderSettings = [SELECT Feild_Mapping_JSON__c, Id FROM Work_Order_Setting__c where Id =:recordID];
            WODataUpdate = ( List < ConditionsWrapper > ) JSON.deserialize( fetchedWorkOrderSettings.get(0).Feild_Mapping_JSON__c ,List < ConditionsWrapper >.class);
        }
        return WODataUpdate;
    }
    
    //Returns all or requested work order setting records bases on the id passed. Pass Id of work order setting record.
    @AuraEnabled
    public static List<Work_Order_Setting__c> getWorkOrderSettingRecords(Id recId){
        List<Work_Order_Setting__c> fetchedWorkOrderSettings = new List<Work_Order_Setting__c>();
        if(recId != NULL)
            fetchedWorkOrderSettings = [SELECT Id, Is_Active__c, Name, RecordType.DeveloperName FROM Work_Order_Setting__C where Id =: recId];
        else if(recId == NULL)
            fetchedWorkOrderSettings = [SELECT Id, Is_Active__c, Name, RecordType.DeveloperName,LastModifiedDate FROM Work_Order_Setting__C order BY Is_Active__c DESC  ];
        return fetchedWorkOrderSettings;
    }
    
    //Returns feildset feilds for the passed feildset name of an object.Parameters to be passed are feildset Label and object api name.
    @AuraEnabled
    public static List<String> readFieldSet(String fieldSetLable,String ObjectName){
        List<String> returnList = new List<String>(); 
        if(ObjectName != NULL || ObjectName != '' || fieldSetLable != NULL || fieldSetLable != ''){
            Map<String, Schema.FieldSet> SObjectTypeObj = Schema.getGlobalDescribe().get(ObjectName).getDescribe().FieldSets.getMap();
            String fieldsetName;
            for(Schema.FieldSet fs: SObjectTypeObj.values()){
                if(fs.getLabel() == fieldSetLable)
                    fieldsetName = fs.getName();
            }
            for(Schema.FieldSetMember fsm: SObjectTypeObj.get(fieldsetName).getFields()){
                returnList.add(fsm.getLabel());
            }
        }  
        return returnList;
    }
    //Returns work order record type of work order object.Parameter object api name.
    @AuraEnabled
    public static List<String> workOrderType (String ObjectName){
        System.debug('passed objectname-->'+ObjectName);
        List<String> returnType = new List<String>();
        for(Schema.RecordTypeInfo rti : Schema.getGlobalDescribe().get(ObjectName).getDescribe().getRecordTypeInfos()){
            if(rti.getName() != 'Master')
                returnType.add(rti.getName());
        }
        System.debug('return string values---->'+returnType);
        return returnType;
    }
    
    //Returns work order record type from product.
    @AuraEnabled
    public static List<String> workOrderOptions (){
        String objectName = 'Product2';
        String fieldName = 'Work_Order_Type__c';
        List <String> values = new List<String>();
        for (Schema.PicklistEntry entry : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getPicklistValues()){
            if (entry.isActive())
                values.add(entry.getValue());   
        }
        return values;
    }
    
    //Returns feilds values of a object. The parameters to be passed are object api name and the required feild type.
    @AuraEnabled
    public static List<String> objectFeildsSecond(String objectName,String fieldType){	
        System.debug('passed fieldType---> '+fieldType);
        System.debug('passed objectName---> '+objectName);
        List<String> listObjValues = new List<String>();
        if(objectName != NULL || objectName != '' || fieldType != NULL || fieldType != ''){
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for (Schema.SObjectField fieldName: fieldMap.values()){                
                if(fieldType == 'PICKLIST'){
                    if(fieldName.getDescribe().getType() == Schema.DisplayType.PICKLIST && fieldName.getDescribe().isUpdateable()) 
                        listObjValues.add(fieldName.getDescribe().getLabel());  
                }
                else if(fieldType == 'All'){
                    if(objectName != 'Work_Order__c'){
                        if(fieldName.getDescribe().getType() != Schema.DisplayType.REFERENCE && fieldName.getDescribe().isUpdateable())
                            listObjValues.add(fieldName.getDescribe().getLabel());
                    }
                    else{
                        if(fieldName.getDescribe().getType() != Schema.DisplayType.REFERENCE && fieldName.getDescribe().isUpdateable() && fieldName.getDescribe().getLabel() != 'Number of WO Line')
                            listObjValues.add(fieldName.getDescribe().getLabel());
                    }
                } 
                else if(fieldType == 'DATE' || fieldType == 'DateTime'){
                    if(fieldName.getDescribe().getType() == Schema.DisplayType.DATE && fieldName.getDescribe().isUpdateable())
                        listObjValues.add(fieldName.getDescribe().getLabel()); 
                }  
                else if(fieldType == 'BOOLEAN'){
                    if(fieldName.getDescribe().getType() == Schema.DisplayType.BOOLEAN)
                        listObjValues.add(fieldName.getDescribe().getLabel());   
                }  
                else if(fieldType == 'STRING' || fieldType == 'TEXTAREA' ){
                    if((fieldName.getDescribe().getType() == Schema.DisplayType.STRING || fieldName.getDescribe().getType() == Schema.DisplayType.TEXTAREA))
                        listObjValues.add(fieldName.getDescribe().getLabel()); 
                }
                else if(fieldType == 'CURRENCY' || fieldType == 'INTEGER' ){
                    if((fieldName.getDescribe().getType() == Schema.DisplayType.CURRENCY || fieldName.getDescribe().getType() == Schema.DisplayType.INTEGER || fieldName.getDescribe().getType() == Schema.DisplayType.DOUBLE))
                        listObjValues.add(fieldName.getDescribe().getLabel()); 
                }
            }
        }
        System.debug('listObjValues=====>'+listObjValues);
        return listObjValues;   
    }
    // Return only reference field
    @AuraEnabled
    public static List<string> onlyReferenceField(String objectName){
        List<String> fieldListToReturn = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        for (Schema.SObjectField fieldName: fieldMap.values()){
            if(fieldName.getDescribe().getType() == Schema.DisplayType.REFERENCE && fieldName.getDescribe().isUpdateable()){
                String feildLable = String.valueOf(fieldName.getDescribe().getReferenceTo());
                feildLable = feildLable.replace('(',''); 
                feildLable = feildLable.replace(')','');
                feildLable = feildLable +  ' ---->';
                fieldListToReturn.add(feildLable);
            }
        }
        return fieldListToReturn;
    }
    @AuraEnabled
    public static List<String> getReferenceFieldValue(String objectName){
        List<String> test = new List<String>();
        System.debug('passed values--->'+objectName);
        if(objectName != NULL || objectName != ''){
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for (Schema.SObjectField fieldName: fieldMap.values()){
                if(fieldName.getDescribe().getType() == Schema.DisplayType.REFERENCE && fieldName.getDescribe().isUpdateable()){
                    String feildLable = String.valueOf(fieldName.getDescribe().getReferenceTo());
                    System.debug('feildLable----->'+feildLable);
                    feildLable = feildLable.replace('(',''); 
                    feildLable = feildLable.replace(')','');
                    feildLable = feildLable +  ' ---->';
                    test.add(feildLable);
                }
            }            
            for (Schema.SObjectField fieldName: fieldMap.values()){
                if(fieldName.getDescribe().getType() != Schema.DisplayType.REFERENCE && fieldName.getDescribe().isUpdateable())
                    test.add(String.valueOf(fieldName.getDescribe().getLabel()));
            }
        }
        System.debug('return list -- > '+ test);
        return test;    
    }
    // Returns all reference type fields of an object. Pass object api name.
    @AuraEnabled
    public static List<String> objectReferenceFeilds(String objectName){	 
        List<String> listObjValues = new List<String>();
        if(objectName != NULL || objectName != ''){
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for (Schema.SObjectField fieldName: fieldMap.values()){
                if(fieldName.getDescribe().getType() == Schema.DisplayType.REFERENCE && fieldName.getDescribe().isUpdateable()){
                    String feildLable = String.valueOf(fieldName.getDescribe().getLabel());
                    feildLable = feildLable.replace(' ID', '');
                    listObjValues.add(feildLable);  
                }
            }
        }
        return listObjValues;   
    }
    
    
    //Returns all the Picklist values of a field. The parameters to be passed are required feild and object api name.
    @AuraEnabled
    public static List <String> pickListValuesSecond (String objectName,String fieldLabel){
        List <String> values = new List <String>();
        if(objectName != NULL || objectName != '' || fieldLabel != NULL || fieldLabel != ''){
            Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            String fieldApiName;
            for(Schema.SObjectField strField : mfields.values()){
                if(fieldLabel == strField.getDescribe().getLabel())
                    fieldApiName = strField.getDescribe().getName();
            }
            for (Schema.PicklistEntry entry :mfields.get(fieldApiName).getDescribe().getPicklistValues()){
                if (entry.isActive())
                    values.add(entry.getValue());
            }
        }
        return values;
    }
    
    //Creates workorder setting record from the data provided from the front UI.
    @AuraEnabled
    public static void saveArrey (String filterArrey,String fieldMapping,String filterName,Boolean isActive, String woRecordType, String woFieldSet, String woLiFieldSet,ID WOSID, String productMappingJson){
        List <Work_Order_Setting__c> toInsertSetting = new List <Work_Order_Setting__c>();
        Work_Order_Setting__c wos = new Work_Order_Setting__c();
        if(WOSID != null || WOSID != '')
            wos.Id = WOSID;
        if(filterName != null || filterName != '')
            wos.Name = filterName;
        if(isActive != null )
            wos.Is_Active__c = isActive;
        if(productMappingJson != null || productMappingJson != '' || productMappingJson != '[]')
            wos.Product_Type_mapping__c = productMappingJson;
        if(filterArrey != null || filterArrey != '' || filterArrey != '[]')
            wos.Filter_JSON__c = filterArrey;
        if(fieldMapping != null || fieldMapping != '' || fieldMapping != '[]')
            wos.Feild_Mapping_JSON__c = fieldMapping;
        if(woRecordType != null || woRecordType != '' || woRecordType != '[]')
            wos.WorkOrder_Record_Type_JSON__c = woRecordType;
        if(woFieldSet != null || woFieldSet != '' || woFieldSet != '[]')
            wos.WorkOrder_FieldSet_JSON__c = woFieldSet;
        if(woLiFieldSet != null || woLiFieldSet != '' || woLiFieldSet != '[]')
            wos.WorkOrder_LineItem_FieldSet_JSON__c = woLiFieldSet;
        toInsertSetting.add(wos);
        
        if(toInsertSetting.size() > 0){
            List <Work_Order_Setting__c> oldActiveSetting = new List <Work_Order_Setting__c>();
            if(WOSID != null || WOSID != ''){
                oldActiveSetting = [SELECT Id, Is_Active__c, RecordTypeId FROM Work_Order_Setting__c WHERE RecordTypeId != '012C20000004MpxIAE' AND Id !=: WOSID AND Is_Active__c = true]; 
            }
            else
                oldActiveSetting = [SELECT Id, Is_Active__c, RecordTypeId FROM Work_Order_Setting__c WHERE RecordTypeId != '012C20000004MpxIAE' AND Is_Active__c = true];
            List <Work_Order_Setting__c> toUpdateSetting = new List <Work_Order_Setting__c>();
            for(Work_Order_Setting__c oas: oldActiveSetting){
                oas.Is_Active__c = false;
                toUpdateSetting.add(oas);
            } 
            update toUpdateSetting; 
        }
        Upsert toInsertSetting;
    }
    
    //Creates workorder invoiceing setting recordtype record from the data provided from the front UI.
    @AuraEnabled
    public static void saveInvoiceingArrey(String invoieingJson , String platformJosn, String invoiceFieldsMapping){
        
        List <Work_Order_Setting__c> toInsertSetting = new List <Work_Order_Setting__c>();
        if(invoieingJson != null || invoieingJson != '' || invoieingJson != '[]' || platformJosn != null || platformJosn != '' || platformJosn != '[]'){
            Work_Order_Setting__c wos = new Work_Order_Setting__c();
            wos.RecordTypeId = '012C20000004MpxIAE';
            wos.Invoice_Payment_JSON__c = invoieingJson;
            wos.Invoicing_Fields__c = invoiceFieldsMapping;
            System.debug('Platform Selection List = '+platformJosn);
            wos.Platform_Selection_JSON__c = platformJosn;
            wos.Is_Active__c = true;
            toInsertSetting.add(wos); 
        }
        if(toInsertSetting.size() > 0){ 
            List <Work_Order_Setting__c> oldActiveSetting = [SELECT Id, Is_Active__c, RecordTypeId FROM Work_Order_Setting__c WHERE RecordTypeId = '012C20000004MpxIAE' AND Is_Active__c = true];
            List <Work_Order_Setting__c> toUpdateSetting = new List <Work_Order_Setting__c>();
            
            if(oldActiveSetting.size() > 0){
                for(Work_Order_Setting__c oas: oldActiveSetting){
                    oas.Is_Active__c = false;
                    toUpdateSetting.add(oas);
                } 
                update toUpdateSetting;   
            }
            insert toInsertSetting;
        }
    }
    
    //Returns feild type. The parameters to be passed are required feild and object api name.
    @AuraEnabled
    public static String fieldTypeMacherSecond (String objectName,String fieldLabel){
        String stringIntance;
        if(objectName != NULL || objectName != '' || fieldLabel != NULL || fieldLabel != ''){
            Map<String,Schema.SObjectField> mfields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            String fieldApiName;
            for(Schema.SObjectField strField : mfields.values()) {
                if(fieldLabel == strField.getDescribe().getLabel())
                    fieldApiName = strField.getDescribe().getName();
            }
            stringIntance = String.valueOf(mfields.get(fieldApiName).getDescribe().getType());
        }
        return(stringIntance); 
    }
    //Opportunity Filter Wrapper
    public class Filterwrapper {
        @AuraEnabled public workOrderSetting[] workOrderSetting{get;set;} 
    } 
    public class workOrderSetting {
        @AuraEnabled public String condition{get;set;}
        @AuraEnabled public String logicValue{get;set;}
        @AuraEnabled public List<InnerList> InnerList{get;set;}
    }
    public class InnerList {
        @AuraEnabled public String opportunityselectField{get;set;}
        @AuraEnabled public String operator{get;set;}
        @AuraEnabled public String enteredValue{get;set;}
    }
    
    //Work Order setting Wrapper.
    public class ConditionsWrapper {
        @AuraEnabled public workOrderAllData[] workOrderAllData{get;set;}  
    }
    public class workOrderAllData {
        @AuraEnabled public String workOrderLineItemCreateAsPer{get;set;}
        @AuraEnabled public String woRelatedTypeValue{get;set;}
        @AuraEnabled public String selectedFieldSet{get;set;}
        @AuraEnabled public String wolifieldSetName{get;set;}
        @AuraEnabled public List<workOrderFieldList>  workOrderFieldList{get;set;}
        @AuraEnabled Public List<woliFieldMappingData> woliFieldMappingData{get;set;}
    }
    public class woliFieldMappingData{
        @AuraEnabled public String lineItemselectField{get;set;}
        @AuraEnabled public String LineItemvalueType{get;set;}
        @AuraEnabled public String woLineItemInsertedValue{get;set;}
    }
    public class workOrderFieldList {
        @AuraEnabled public String selectField{get;set;}
        @AuraEnabled public String valueType{get;set;}
        @AuraEnabled public String InsertedValue{get;set;}
    }
    
    //Work Order invoice setting Wrapper.
    
    public class invoiceingFieldsMapping {
        @AuraEnabled public invoicingData[] invoicingData{get;set;}
    }
    
    public class invoicingData {
        @AuraEnabled public String paymentType{get;set;}
        @AuraEnabled public Boolean isActive{get;set;}
        @AuraEnabled public opportunityFieldsFilter[] opportunityFieldsFilter{get;set;}
        @AuraEnabled public FieldsMapping[] FieldsMapping{get;set;}
    }
    public class opportunityFieldsFilter{
        @AuraEnabled public String condition{get;set;}
        @AuraEnabled public String logicValue{get;set;}
        @AuraEnabled public Boolean active{get;set;}
        @AuraEnabled public InnerList[] InnerList{get;set;}
    }
    
    public class FieldsMapping{
        @AuraEnabled public String woRecordTypeValue{get;set;}
        @AuraEnabled public woFieldsMappingList[] woFieldsMappingList{get;set;}
    }
    public class woFieldsMappingList {
        @AuraEnabled public String selectField{get;set;}
        @AuraEnabled public String valueType{get;set;}
        @AuraEnabled public String InsertedValue{get;set;}
    }
}