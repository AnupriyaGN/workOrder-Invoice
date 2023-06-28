public class workorderLandingPageHelper {
    
    public static Map< String,Schema.SObjectField > opportunityFeildsMap = Schema.getGlobalDescribe().get('opportunity').getDescribe().fields.getMap();
    public static Map< String,Schema.SObjectField > workOrderLineFeildMAp = Schema.getGlobalDescribe().get('Work_Order_Line_Item__c').getDescribe().fields.getMap();
    public static Map< String,Schema.SObjectField > workOrderFeildMap = Schema.getGlobalDescribe().get('Work_Order__c').getDescribe().fields.getMap();
    public static Map< String,Schema.SObjectField > quoteFeildMap = Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap();
    public static Map< String,Schema.SObjectField > quoteLineItemFeildMap = Schema.getGlobalDescribe().get('QuoteLineItem').getDescribe().fields.getMap();
    public static Map< String,Schema.SObjectField > productFeildMap = Schema.getGlobalDescribe().get('Product2').getDescribe().fields.getMap();
    public static Map< String,Schema.SObjectField > oliFeildMap = Schema.getGlobalDescribe().get('OpportunityLineItem').getDescribe().fields.getMap();
    public static Map< Id,String > valueChangeTracker = new Map< Id,String >(); 
    public static Map< Id,String > conditionSatisfyTracker = new Map < ID,String >();
    public static List< OpportunityLineItem > opportunityLineItemList = new List < OpportunityLineItem >();
    public static List< opportunityFieldsFilter > filterCondition = new List < opportunityFieldsFilter >();
    public static List< Filterwrapper > dataUpdate = new List < Filterwrapper >();
    public static List< Id > opportunityIDList = new List< Id >();
    public static List< Id > quoteIDList = new List< Id >();
    public static String filter = '';
    public static String workOrderConditions = '';
    public static Boolean isInvoicing = false;
    
    public static void valueChangeCheaker( List < Opportunity > newList, Map < Id , Opportunity > newMap,List< Opportunity >oldList, Map< Id,Opportunity >oldMap ){
        valueChangeTracker.clear();
        List < InnerList > innerListForCondition = new List < InnerList >();
        
        if(isInvoicing == false) {
            System.debug('in valueChangeCheaker for work order and line item creation');
            for(Work_Order_Setting__c WOInstance : [SELECT Is_Active__c, Filter_JSON__c, Feild_Mapping_JSON__c, Serial_Number__c, Name, IsDeleted, OwnerId,RecordTypeId, Id FROM Work_Order_Setting__c Where RecordTypeId != 'a0bC200000094SbIAI'AND Is_Active__c = true order BY LastModifiedDate DESC LIMIT 1]){
                System.debug('Filter name---->'+WOInstance.name);
                filter = WOInstance.Filter_JSON__c;
                system.debug('filter'+filter);
                workOrderConditions =  WOInstance.Feild_Mapping_JSON__c;
            }
            
            if(filter != '')
                dataUpdate = ( List < Filterwrapper > ) JSON.deserialize( filter ,List < Filterwrapper >.class);
            system.debug('dataUpdate'+dataUpdate);
            if( dataUpdate[0].workOrderSetting[0].InnerList.size() > 0 && dataUpdate!=null)
                innerListForCondition = dataUpdate[0].workOrderSetting[0].InnerList;	
        }
        else if(isInvoicing == true){
            System.debug('in valueChangeCheaker for invoiceing work order and line item creation ');
            if( filterCondition[0].InnerList.size() > 0)
                innerListForCondition = filterCondition[0].InnerList;
        }
        
        List< String > opportunityFeilds = new List< String >();
        
        if(innerListForCondition.size() > 0){
            system.debug('in filter condition');
            for(InnerList fw: innerListForCondition ){
                String fieldApiName = '';
                for(Schema.SObjectField strField : opportunityFeildsMap.values()){
                    if(strField != Null){
                        if( strField.getDescribe().getLabel() == fw.opportunityselectField && fieldApiName == '' && fw.opportunityselectField != null && fw.opportunityselectField != ''){ 
                            system.debug('founf field');
                            fieldApiName = strField.getDescribe().getName();
                            Break; 
                        }
                    } 
                }
                opportunityFeilds.add(fieldApiName);
            }
            if(opportunityFeilds.size() > 0){
                for( Opportunity oppo : newList ){ 
                    List<String> hasChanged = new List<String>();
                    for(String feild : opportunityFeilds){
                        String changedORNOt = 'false';
                        if(String.valueOf(oppo.get(feild)) == String.valueOf(oldMap.get(oppo.Id).get(feild)))
                            changedORNOt = 'false';
                        else if(String.valueOf(oppo.get(feild)) != String.valueOf(oldMap.get(oppo.Id).get(feild)))
                            changedORNOt = 'true';
                        hasChanged.add(changedORNOt);
                    }
                    if( hasChanged.size() > 0){
                        if(hasChanged.contains('true'))
                            valueChangeTracker.put(oppo.Id,'true');
                        else
                            valueChangeTracker.put(oppo.Id,'false'); 
                    }
                }
            }
        }
        System.debug('Has value changed__'+valueChangeTracker);
        if(valueChangeTracker.size() > 0)
            getData(newList,newMap,isInvoicing);	
    }
    
    public static void getData( List < Opportunity > newList, Map < Id , Opportunity > newMap, Boolean isInvoicing){
        conditionSatisfyTracker.clear();
        String filterConditionString = '';
        String filterCustomLogicString = ''; 
        
        List < InnerList > fromLoop = new List < InnerList >();
        
        if(isInvoicing == false){
			system.debug('invoiceing false');            
            if(dataUpdate[0].workOrderSetting.size() > 0){
                for(workOrderSetting gc:dataUpdate[0].workOrderSetting ){
                    filterConditionString = gc.condition;
                    filterCustomLogicString = gc.logicValue;
                    if(gc.InnerList.size() > 0){
                        for(InnerList gf: gc.InnerList){
                            fromLoop.add(gf);
                        }
                    }
                }
            }
        }
        else if(isInvoicing == true){ 
            if(filterCondition.size() > 0){
                for(opportunityFieldsFilter off: filterCondition){
                    filterConditionString = off.condition;
                    filterCustomLogicString = off.logicValue;
                    if(off.InnerList.size() > 0){
                        for(InnerList innl : off.InnerList){
                            fromLoop.add(innl); 
                        }
                    }
                }
            }
        }
        
        
        if(fromLoop.size() > 0 && valueChangeTracker.size() > 0){
            for(Opportunity oppo: newList){
                List<String> conditionOutcome = new List<String>();
                if(valueChangeTracker.containsKey(oppo.Id)){
                    system.debug('opp found '+ oppo.Id );
                    system.debug(boolean.valueOf(valueChangeTracker.get(oppo.Id)));
                    if(boolean.valueOf(valueChangeTracker.get(oppo.Id))){
                        system.debug('valueChangeTracker boolean'+ boolean.valueOf(valueChangeTracker.get(oppo.Id)));
                        for(InnerList gf: fromLoop){
                            String fieldApiName = '';
                            String oppoFieldValue = '';
                            String fieldsType = '';
                            for(Schema.SObjectField strField : opportunityFeildsMap.values()){
                                if(strField != Null){
                                    if( strField.getDescribe().getLabel() == gf.opportunityselectField && fieldApiName == '' && gf.opportunityselectField != null && gf.opportunityselectField != ''){ 
                                        fieldApiName = strField.getDescribe().getName();
                                        fieldsType = String.valueOf(strField.getDescribe().getType());
                                        Break; 
                                    }
                                } 
                            }
                            System.debug('fieldsTypefieldsType-->'+fieldsType);
                            if((fieldApiName != null || fieldApiName != '') && fieldsType != 'DATE')
                                oppoFieldValue = String.valueOf(oppo.get(fieldApiName));
                            else if((fieldApiName != null || fieldApiName != '') && fieldsType == 'DATE' || fieldsType == 'DATETIME')
                                oppoFieldValue = String.valueOf(Date.valueOf(oppo.get(fieldApiName)));
                            
                            String result = '';
                            
                            if(gf.operator == 'Equals'){
                                if(String.valueOf(gf.enteredValue) == oppoFieldValue && gf.enteredValue != '')
                                    result = 'true';
                                else
                                    result = 'false'; 
                            }
                            else if(gf.operator == 'Does Not Equals'){
                                if(String.valueOf(gf.enteredValue) != oppoFieldValue && gf.enteredValue != '')
                                    result = 'true';
                                else
                                    result = 'false';
                            }
                            else if(gf.operator == 'Contains' && gf.enteredValue != ''){   
                                if(oppoFieldValue.contains(String.valueOf(gf.enteredValue)))
                                    result = 'true';
                                else
                                    result = 'false';
                            }
                            else if(gf.operator == 'Is Null' && gf.enteredValue != ''){
                                if(gf.enteredValue == 'True'){
                                    if(oppoFieldValue == Null)
                                        result = 'true';
                                    else
                                        result = 'false';
                                }
                                else if(gf.enteredValue == 'False' && gf.enteredValue != ''){
                                    if(oppoFieldValue != Null)
                                        result = 'true';
                                    else
                                        result = 'false';
                                }
                            } 
                            conditionOutcome.add(result);
                        }
                        System.debug('conditionOutcome-->'+conditionOutcome);
                        If(conditionOutcome.size() > 0){
                            if(filterConditionString == 'AND'){
                                if(conditionOutcome.contains('false'))
                                    conditionSatisfyTracker.put(oppo.Id,'false');
                                else
                                    conditionSatisfyTracker.put(oppo.Id,'true');
                            }
                            
                            else if(filterConditionString == 'OR'){
                                if(conditionOutcome.contains('true'))
                                    conditionSatisfyTracker.put(oppo.Id,'true');
                                else
                                    conditionSatisfyTracker.put(oppo.Id,'false');
                            }
                            else if(filterConditionString == 'CUSTOM LOGIC'){
                                //??
                            }   
                        }
                    }
                }
            }
        }
        System.debug('Condition satisfied--->'+conditionSatisfyTracker);
        if(conditionSatisfyTracker.size() > 0){
            if(isInvoicing == false){
                System.debug('Calling WorkOrder creation');
                WorkOrder(newList,newMap);
            }
            else if(isInvoicing == true){
                System.debug('calliing invoice work order creation no use');
                invoiceingWorkOrder(newList,newMap);
            }
        }
    }
    public static void invoiceingWorkOrder (List < Opportunity > newList , Map < Id , Opportunity > newMap){
        
        List < OpportunityLineItem > opportunityLineItemList = new List< OpportunityLineItem >();
        
        if( opportunityIDList.size() > 0)
            opportunityLineItemList = [SELECT Id, OpportunityId, Quantity, Product2.Work_Order_Type__c FROM OpportunityLineItem where OpportunityId =: opportunityIDList];
        
        Map < ID, List < String >> opportunityWorkorderType = new Map < ID, List < String >>();
        
        if(opportunityLineItemList.size() > 0){
            for(OpportunityLineItem oli : opportunityLineItemList){
                if(!opportunityWorkorderType.containskey(oli.OpportunityId))
                    opportunityWorkorderType.put((oli.OpportunityId),new List<String> {oli.Product2.Work_Order_Type__c});
                else
                    opportunityWorkorderType.get(oli.OpportunityId).add(oli.Product2.Work_Order_Type__c);    
            }
            System.debug('opportunityWorkorderType for invoiceing--->'+opportunityWorkorderType);
        }
    }
    
    //creating work order
    public static void WorkOrder (List < Opportunity > newList , Map < Id , Opportunity > newMap){
        
        for(Opportunity oppor : newList){
            if(conditionSatisfyTracker.containsKey(oppor.Id)){
                if(boolean.valueOf(conditionSatisfyTracker.get(oppor.Id)) )
                    opportunityIDList.add(oppor.Id);
            }  
        }
        
        List< OpportunityLineItem > opportunityLineItemList = new List< OpportunityLineItem >();
        MAp< Id, Quote > opportunityIDQuoteRecords = new MAp< Id, Quote >();
        
        if(opportunityIDList.size() > 0){
            
            
                List< Quote > QuoteRecords = new List< Quote >();
                String query1 = 'SELECT ';
                for(Schema.SObjectField strField : quoteFeildMap.values()){
                    if(strField != null)
                        query1 += strField.getDescribe().getName() + ', ' ; 
                }
                
                query1 = query1.removeEnd(', ');
                if( query1 != 'SELECT '){
                    query1 +=  ' from Quote where OpportunityId =: opportunityIDList And IsSyncing = true';
                    System.debug('querysdknkajndsajdna-->'+query1);
                    QuoteRecords = Database.query(query1);
                }
                System.debug('QuoteRecords --->'+QuoteRecords);
                for(Quote quo : QuoteRecords){
                    opportunityIDQuoteRecords.put(quo.OpportunityId , quo);
                    quoteIDList.add(quo.Id);
                }
            
        }
        
        Map < ID, List < String >> opportunityWorkorderType = new Map < ID, List < String >>();
        {
                List< OpportunityLineItem > QuoteRecords = new List< OpportunityLineItem >();
                String query1 = 'SELECT Product2.Work_Order_Type__c, ';
                for(Schema.SObjectField strField : oliFeildMap.values()){
                    if(strField != null)
                        query1 += strField.getDescribe().getName() + ', ' ; 
                }
                
                query1 = query1.removeEnd(', ');
                if( query1 != 'SELECT Product2.Work_Order_Type__c, '){
                    query1 +=  ' from OpportunityLineItem where OpportunityId =: opportunityIDList';
                    System.debug('querysdknkajndsajdna-->'+query1);
                    opportunityLineItemList = Database.query(query1);
                }
                System.debug('QuoteRecords --->'+QuoteRecords);
            }
        
        
        if(opportunityLineItemList.size() > 0){
            for(OpportunityLineItem oli : opportunityLineItemList){
                if(!opportunityWorkorderType.containskey(oli.OpportunityId))
                    opportunityWorkorderType.put((oli.OpportunityId),new List<String> {oli.Product2.Work_Order_Type__c});
                else
                    opportunityWorkorderType.get(oli.OpportunityId).add(oli.Product2.Work_Order_Type__c);    
            }
        }
        System.debug('opportunityWorkorderType ->'+opportunityWorkorderType);
        List < ConditionsWrapper > WODataUpdate = new List < ConditionsWrapper >();
        
        if(workOrderConditions != '')
            WODataUpdate = ( List < ConditionsWrapper > ) JSON.deserialize( workOrderConditions ,List < ConditionsWrapper >.class);
        
        system.debug('WODataUpdate'+WODataUpdate);
        
        String createdAsPer = '';
        Map< id,List< Work_Order__c >> previousWorkOrder = new map< id,List< Work_Order__c > >();
        Map< id,List< String >> previousWorkOrderTypes = new map< id,List< String > >();
        Map< id,List< String >> createdWorkOrderTypes = new map< id,List< String > >();
        List< Work_Order__c > finalWOrder = new List< Work_Order__c >();
        Map< id,List< Work_Order__c >> finalWOrderMap = new map< id,List< Work_Order__c >>();
        
        if(opportunityIDList.size() > 0){
            List < Work_Order__c > tempWorkOrder = [SELECT Id, Opportunity__c,RecordTypeId,RecordType.name FROM Work_Order__c where Opportunity__c =: opportunityIDList];
            if(tempWorkOrder.size() > 0){
                for(Work_Order__c fwo : tempWorkOrder){
                    if(fwo.Id != null){
                        if(!previousWorkOrder.containskey(fwo.Opportunity__c)){
                            previousWorkOrder.put(fwo.Opportunity__c,new List < Work_Order__c > {fwo});
                            previousWorkOrderTypes.put(fwo.Opportunity__c,new List < String > {fwo.RecordType.name});
                        }
                        else if(previousWorkOrder.containskey(fwo.Opportunity__c)){
                            previousWorkOrder.get(fwo.Opportunity__c).add(fwo);  
                            previousWorkOrderTypes.get(fwo.Opportunity__c).add(fwo.RecordType.name);
                        }
                    }
                }
            }
        }
        System.debug('previousWorkOrder--->'+previousWorkOrder);
        System.debug('previousWorkOrderTypes--->'+previousWorkOrderTypes);
        
        for(Opportunity oppo : newList){
            System.debug('Inside opportunity loop');
            if(conditionSatisfyTracker.containsKey(oppo.Id)){
                if(boolean.valueOf(conditionSatisfyTracker.get(oppo.Id))){
                    if(WODataUpdate.size() > 0){
                        for(workOrderAllData c: WODataUpdate[0].workOrderAllData){
                            if(opportunityWorkorderType.containsKey(oppo.Id)){
                                if(opportunityWorkorderType.get(oppo.Id).contains(c.woRelatedTypeValue)){
                                    if(previousWorkOrderTypes.containsKey(oppo.Id)){
                                        if(!previousWorkOrderTypes.get(oppo.Id).contains(c.woRelatedTypeValue)){
                                            createdAsPer = c.workOrderLineItemCreateAsPer;
                                            Work_Order__c WO = new Work_Order__c();
                                            for(workOrderFieldList gWO: c.workOrderFieldList){
                                                String fieldApiName = '';
                                                String fieldType = '';
                                                System.debug('inside work order object creation');
                                                for(Schema.SObjectField strField : workOrderFeildMap.values()){
                                                    if(strField != null){
                                                        fieldType = String.valueOf(strField.getDescribe().getType());
                                                        if( strField.getDescribe().getLabel() == gWO.selectField && fieldApiName == ''){                             
                                                            fieldApiName = strField.getDescribe().getName();
                                                            Break; 
                                                        } 
                                                    }
                                                }
                                                if(c.woRelatedTypeValue != '')
                                                    WO.RecordTypeId = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get(c.woRelatedTypeValue).getRecordTypeId();
                                                if(gWO.valueType == 'Assign Value'){
                                                    if(fieldType == 'BOOLEAN')
                                                        WO.put(fieldApiName, Boolean.valueOf(gWO.InsertedValue));
                                                    else if(fieldType == 'DATE')
                                                        WO.put(fieldApiName, Date.valueOf(gWO.InsertedValue));
                                                    else if(fieldType == 'DateTime')
                                                        WO.put(fieldApiName, DateTime.valueOfGmt(gWO.InsertedValue));
                                                    else if(fieldType == 'Double')
                                                        WO.put(fieldApiName,Double.valueOf(gWO.InsertedValue));   
                                                    else if(fieldType == 'Integer')
                                                        WO.put(fieldApiName,Integer.valueOf(gWO.InsertedValue)); 
                                                    else if(fieldType == 'Base64')
                                                        WO.put(fieldApiName, Blob.valueOf(gWO.InsertedValue));
                                                    else if(fieldType == 'CURRENCY' || fieldType == 'Percent')
                                                        WO.put(fieldApiName, Decimal.valueOf(gWO.InsertedValue));
                                                    else
                                                        WO.put(fieldApiName, gWO.InsertedValue);
                                                }
                                                else if(gWO.valueType == 'Assign From Opportunity'){
                                                    String oppoApiName = '';
                                                    for(Schema.SObjectField strField2 : opportunityFeildsMap.values()){
                                                        if( strField2.getDescribe().getlabel() == gWO.InsertedValue && oppoApiName == ''){   
                                                            oppoApiName = strField2.getDescribe().getName();
                                                            Break; 
                                                        }        
                                                    }
                                                    WO.put(fieldApiName, oppo.get(oppoApiName));
                                                }
                                                else if(gWO.valueType == 'Assign From Standard Quote'){
                                                    if( opportunityIDQuoteRecords.size() > 0){
                                                        if( opportunityIDQuoteRecords.keyset().contains(oppo.Id)){
                                                            String oppoApiName = '';
                                                            for(Schema.SObjectField strField2 : quoteFeildMap.values()){
                                                                if( strField2.getDescribe().getlabel() == gWO.InsertedValue && oppoApiName == ''){   
                                                                    oppoApiName = strField2.getDescribe().getName();
                                                                    Break; 
                                                                }        
                                                            }
                                                            WO.put(fieldApiName, opportunityIDQuoteRecords.get(oppo.Id).get(oppoApiName));
                                                        }
                                                    }
                                                }
                                                WO.Opportunity__c = oppo.Id;
                                                WO.Create_As_Per__c = createdAsPer;
                                            }
                                            finalWOrder.add(WO);
                                            if(!createdWorkOrderTypes.keyset().contains(oppo.Id))
                                                createdWorkOrderTypes.put(oppo.Id, new List< String > {c.woRelatedTypeValue});
                                            else if(createdWorkOrderTypes.keyset().contains(oppo.Id))
                                                createdWorkOrderTypes.get(oppo.Id).add(c.woRelatedTypeValue);
                                        }
                                    }
                                    else{
                                        createdAsPer = c.workOrderLineItemCreateAsPer;
                                        Work_Order__c WO = new Work_Order__c();
                                        for(workOrderFieldList gWO: c.workOrderFieldList){
                                            String fieldApiName = '';
                                            String fieldType = '';
                                            System.debug('inside work order object creation');
                                            for(Schema.SObjectField strField : workOrderFeildMap.values()){
                                                if(strField != null){
                                                    fieldType = String.valueOf(strField.getDescribe().getType());
                                                    if( strField.getDescribe().getLabel() == gWO.selectField && fieldApiName == ''){                             
                                                        fieldApiName = strField.getDescribe().getName();
                                                        Break; 
                                                    } 
                                                }
                                            }
                                            if(c.woRelatedTypeValue != '')
                                                WO.RecordTypeId = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get(c.woRelatedTypeValue).getRecordTypeId();
                                            if(gWO.valueType == 'Assign Value'){
                                                if(fieldType == 'BOOLEAN')
                                                    WO.put(fieldApiName, Boolean.valueOf(gWO.InsertedValue));
                                                else if(fieldType == 'DATE')
                                                    WO.put(fieldApiName, Date.valueOf(gWO.InsertedValue));
                                                else if(fieldType == 'DateTime')
                                                    WO.put(fieldApiName, DateTime.valueOfGmt(gWO.InsertedValue));
                                                else if(fieldType == 'Double')
                                                    WO.put(fieldApiName,Double.valueOf(gWO.InsertedValue));   
                                                else if(fieldType == 'Integer')
                                                    WO.put(fieldApiName,Integer.valueOf(gWO.InsertedValue)); 
                                                else if(fieldType == 'Base64')
                                                    WO.put(fieldApiName, Blob.valueOf(gWO.InsertedValue));
                                                else if(fieldType == 'CURRENCY' || fieldType == 'Percent')
                                                    WO.put(fieldApiName, Decimal.valueOf(gWO.InsertedValue));
                                                else
                                                    WO.put(fieldApiName, gWO.InsertedValue);
                                            }
                                            else if(gWO.valueType == 'Assign From Opportunity'){ 
                                                SObjectType q = Schema.getGlobalDescribe().get('Opportunity');
                                                Map<String,Schema.SObjectField> mapingFields = q.getDescribe().fields.getMap();
                                                String oppoApiName = '';
                                                for(String strField2 : mapingFields.keySet()){
                                                    SObjectField fl = mapingFields.get(strField2);
                                                    if( fl.getDescribe().getlabel() == gWO.InsertedValue && oppoApiName == ''){   
                                                        oppoApiName = strField2;
                                                        Break; 
                                                    }        
                                                }
                                                WO.put(fieldApiName, oppo.get(oppoApiName));
                                            }
                                            else if(gWO.valueType == 'Assign From Standard Quote'){
                                                String oppoApiName = '';
                                                for(Schema.SObjectField strField2 : quoteFeildMap.values()){
                                                    if( strField2.getDescribe().getlabel() == gWO.InsertedValue && oppoApiName == ''){   
                                                        oppoApiName = strField2.getDescribe().getName();
                                                        Break; 
                                                    }        
                                                }
                                                WO.put(fieldApiName, opportunityIDQuoteRecords.get(oppo.Id).get(oppoApiName));
                                            }
                                            WO.Opportunity__c = oppo.Id;
                                            WO.Create_As_Per__c = createdAsPer;
                                        }
                                        finalWOrder.add(WO);
                                        if(!createdWorkOrderTypes.keyset().contains(oppo.Id))
                                            createdWorkOrderTypes.put(oppo.Id, new List< String > {c.woRelatedTypeValue});
                                        else if(createdWorkOrderTypes.keyset().contains(oppo.Id))
                                            createdWorkOrderTypes.get(oppo.Id).add(c.woRelatedTypeValue);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        if(finalWOrder.size() > 0){ 
            Insert finalWOrder;
            System.debug('finalWOrder.size()--->'+finalWOrder.size());
            System.debug('final work order inserted');
        }
        WorkOrderLine(newMap,opportunityLineItemList,opportunityIDQuoteRecords,createdWorkOrderTypes);   
    }        
    
    public static void WorkOrderLine (Map < Id , Opportunity > newMap, List<OpportunityLineItem> opportunityLineItemList, MAp< Id, Quote > opportunityIDQuoteRecords, Map< id,List< String >> createdWorkOrderTypes){
        
        List<Work_Order_Line_Item__c> finalWorkOrderLine = new List<Work_Order_Line_Item__c>();
        List < ConditionsWrapper > mappingData = new List < ConditionsWrapper >();
        Map < ID,List< QuoteLineItem >> opportunityIDQuoteLineItemRecords = new  Map < ID, List <QuoteLineItem >>();
        
        if(quoteIDList.size() > 0){
            {
                List< QuoteLineItem > QuoteLineItemRecords = new List< QuoteLineItem >();
                String query1 = 'SELECT Quote.OpportunityId, ';
                for(Schema.SObjectField strField : quoteLineItemFeildMap.values()){
                    if(strField != null)
                        query1 += strField.getDescribe().getName() + ', ' ; 
                }
                
                query1 = query1.removeEnd(', ');
                if( query1 != 'SELECT Quote.OpportunityId, '){
                    query1 +=  ' from QuoteLineItem where QuoteId  =: quoteIDList';
                    System.debug('querysdknkajndsajdna-->'+query1);
                    QuoteLineItemRecords = Database.query(query1);
                }
                System.debug('QuoteRecords --->'+QuoteLineItemRecords);
                for(QuoteLineItem quo : QuoteLineItemRecords){
                    if(!opportunityIDQuoteLineItemRecords.keyset().contains(quo.Product2Id))
                        opportunityIDQuoteLineItemRecords.put(quo.Product2Id , new List <QuoteLineItem > {quo});
                    else if(opportunityIDQuoteLineItemRecords.keyset().contains(quo.Product2Id))
                        opportunityIDQuoteLineItemRecords.get(quo.Product2Id).add(quo);
                }
            }
            
        }
        
        if(workOrderConditions != null)
            mappingData = ( List < ConditionsWrapper > ) JSON.deserialize( workOrderConditions ,List < ConditionsWrapper >.class);
        
        for(OpportunityLineItem oli:opportunityLineItemList){ 
            Integer noOfWorKOrderLine = (Integer)oli.Quantity;  
            Opportunity oppo =  newMap.get(oli.OpportunityId);
            List < Product2 > tempProducts = new List< Product2 >();
            
            String query1 = 'SELECT ';
            for(Schema.SObjectField strField : productFeildMap.values()){
                if(strField != null)
                    query1 += strField.getDescribe().getName() + ', ' ; 
            }
            
            query1 = query1.removeEnd(', ');
            id oliProductId = oli.Product2Id;
            if( query1 != 'SELECT '){
                query1 +=  ' from Product2 where id =:oliProductId AND IsActive = true';
                System.debug('querysdka-->'+query1);
                tempProducts = Database.query(query1);
            }
            if(tempProducts.size() > 0){
                for(Product2 pro : tempProducts){
                    id workOrderTypeID;
                    
                    Work_Order__c fetchedWorkOrder = new Work_Order__c();
                    System.debug('running for the pro.Work_Order_Type__c--->'+pro.Work_Order_Type__c);
                    System.debug('fetched work order id--->'+workOrderTypeID);
                    if(createdWorkOrderTypes.keyset().contains(oli.OpportunityId)){
                        if(createdWorkOrderTypes.get(oli.OpportunityId).contains(pro.Work_Order_Type__c)){
                            
                            if(pro.Work_Order_Type__c != '')
                                workOrderTypeID = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get(pro.Work_Order_Type__c).getRecordTypeId();
                            
                            System.debug('fetched work order id--->'+workOrderTypeID);
                            
                            if(workOrderTypeID != null)
                                fetchedWorkOrder = [SELECT Opportunity__c, RecordTypeId, RecordType.name, Create_As_Per__c ,Id FROM Work_Order__c where Opportunity__c =: oli.OpportunityId And RecordTypeId =: workOrderTypeID limit 1 ];
                        }
                        
                        if(fetchedWorkOrder != null){
                            if(fetchedWorkOrder.Create_As_Per__c == 'Per Unit'){
                                for(Integer i = 1; i <= noOfWorKOrderLine; i++){
                                    Work_Order_Line_Item__c WOL = new Work_Order_Line_Item__c();
                                    WOL.Product__c = pro.Id;
                                    WOL.Opportunity_Product__c = oli.Id; 
                                    WOL.Work_Order__c = fetchedWorkOrder.Id;
                                    WOL.Number_of_WO_Line__c = 1;
                                    For(workOrderAllData woad :mappingData[0].workOrderAllData){
                                        if(woad.woRelatedTypeValue == fetchedWorkOrder.RecordType.name){
                                            for(woliFieldMappingData wofmd : woad.woliFieldMappingData){
                                                String fieldName = '';
                                                String fieldType = '';
                                                for(Schema.SObjectField strField : workOrderLineFeildMAp.values()){
                                                    if(strField != null){
                                                        if( strField.getDescribe().getLabel() == wofmd.lineItemselectField && fieldName == '' && fieldType == ''){ 
                                                            fieldType = String.valueOf(strField.getDescribe().getType());
                                                            fieldName = strField.getDescribe().getName();
                                                            Break; 
                                                        } 
                                                    }
                                                }
                                                if(wofmd.LineItemvalueType == 'Assign Value' && fieldType!='' ){
                                                    if(fieldType == 'BOOLEAN')
                                                        WOL.put(fieldName, Boolean.valueOf(wofmd.woLineItemInsertedValue));
                                                    else if(fieldType == 'DATE')
                                                        WOL.put(fieldName, Date.valueOf(wofmd.woLineItemInsertedValue));
                                                    else if(fieldType == 'DateTime')
                                                        WOL.put(fieldName, DateTime.valueOfGmt(wofmd.woLineItemInsertedValue));
                                                    else if(fieldType == 'Double')
                                                        WOL.put(fieldName,Double.valueOf(wofmd.woLineItemInsertedValue));   
                                                    else if(fieldType == 'Integer')
                                                        WOL.put(fieldName,Integer.valueOf(wofmd.woLineItemInsertedValue)); 
                                                    else if(fieldType == 'Base64')
                                                        WOL.put(fieldName, Blob.valueOf(wofmd.woLineItemInsertedValue));
                                                    else if(fieldType == 'CURRENCY' || fieldType == 'Percent')
                                                        WOL.put(fieldName, Decimal.valueOf(wofmd.woLineItemInsertedValue));
                                                    else
                                                        WOL.put(fieldName, wofmd.woLineItemInsertedValue);
                                                    
                                                }
                                                else if(wofmd.LineItemvalueType == 'Assign From Opportunity'){ 
                                                    String oppoApiName = '';
                                                    for(Schema.SObjectField strField2 : opportunityFeildsMap.values()){
                                                        if( strField2.getDescribe().getlabel() == wofmd.woLineItemInsertedValue && oppoApiName == ''){   
                                                            oppoApiName = strField2.getDescribe().getName();
                                                            Break; 
                                                        }        
                                                    }
                                                    WOL.put(fieldName, oppo.get(oppoApiName));
                                                } 
                                                else if(wofmd.LineItemvalueType == 'Assign From Standard Quote'){
                                                    if( opportunityIDQuoteRecords.size() > 0){
                                                        if( opportunityIDQuoteRecords.keyset().contains(oppo.Id)){
                                                            String oppoApiName = '';
                                                            for(Schema.SObjectField strField2 : quoteFeildMap.values()){
                                                                if( strField2.getDescribe().getlabel() == wofmd.woLineItemInsertedValue && oppoApiName == ''){   
                                                                    oppoApiName = strField2.getDescribe().getName();
                                                                    Break; 
                                                                }        
                                                            }
                                                            WOL.put(fieldName, opportunityIDQuoteRecords.get(oppo.Id).get(oppoApiName));
                                                        }
                                                    }
                                                }
                                                else if(wofmd.LineItemvalueType == 'Assign From Product'){
                                                    String oppoApiName = '';
                                                    for(Schema.SObjectField strField2 : productFeildMap.values()){
                                                        if( strField2.getDescribe().getlabel() == wofmd.woLineItemInsertedValue && oppoApiName == ''){   
                                                            oppoApiName = strField2.getDescribe().getName();
                                                            Break; 
                                                        }        
                                                    }
                                                    WOL.put(fieldName, pro.get(oppoApiName));      
                                                }
                                            }
                                        }
                                    }
                                    finalWorkOrderLine.add(WOL);
                                    System.debug('finalWorkOrderLinefinalWorkOrderLine.size()--->'+finalWorkOrderLine.size());
                                }
                            }
                            else if(fetchedWorkOrder.Create_As_Per__c == 'Per Line'){
                                Work_Order_Line_Item__c WOL = new Work_Order_Line_Item__c();
                                WOL.Product__c = pro.Id;
                                WOL.Opportunity_Product__c = oli.Id;
                                WOL.Work_Order__c = fetchedWorkOrder.Id;
                                WOL.Number_of_WO_Line__c = noOfWorKOrderLine;
                                
                                For(workOrderAllData woad :mappingData[0].workOrderAllData){
                                    if(woad.woRelatedTypeValue == fetchedWorkOrder.RecordType.name){
                                        for(woliFieldMappingData wofmd : woad.woliFieldMappingData){
                                            String fieldName = '';
                                            String fieldType = '';
                                            for(Schema.SObjectField strField : workOrderLineFeildMAp.values()){
                                                if(strField != null){
                                                    if( strField.getDescribe().getLabel() == wofmd.lineItemselectField && fieldName == ''){                             
                                                        fieldName = strField.getDescribe().getName();
                                                        fieldType = String.valueOf(strField.getDescribe().getType());
                                                        Break; 
                                                    } 
                                                }
                                            }
                                            if(wofmd.LineItemvalueType == 'Assign Value'){
                                                if(fieldType == 'BOOLEAN')
                                                    WOL.put(fieldName, Boolean.valueOf(wofmd.woLineItemInsertedValue));
                                                else if(fieldType == 'DATE')
                                                    WOL.put(fieldName, Date.valueOf(wofmd.woLineItemInsertedValue));
                                                else if(fieldType == 'DateTime')
                                                    WOL.put(fieldName, DateTime.valueOfGmt(wofmd.woLineItemInsertedValue));
                                                else if(fieldType == 'Double')
                                                    WOL.put(fieldName,Double.valueOf(wofmd.woLineItemInsertedValue));   
                                                else if(fieldType == 'Integer')
                                                    WOL.put(fieldName,Integer.valueOf(wofmd.woLineItemInsertedValue)); 
                                                else if(fieldType == 'Base64')
                                                    WOL.put(fieldName, Blob.valueOf(wofmd.woLineItemInsertedValue));
                                                else if(fieldType == 'CURRENCY' || fieldType == 'Percent')
                                                    WOL.put(fieldName, Decimal.valueOf(wofmd.woLineItemInsertedValue));
                                                else
                                                    WOL.put(fieldName, wofmd.woLineItemInsertedValue);
                                            }
                                            else if(wofmd.LineItemvalueType == 'Assign From Opportunity'){
                                                String oppoApiName = '';
                                                for(Schema.SObjectField strField2 : opportunityFeildsMap.values()){
                                                    if( strField2.getDescribe().getLabel() == wofmd.woLineItemInsertedValue && oppoApiName == ''){   
                                                        oppoApiName = strField2.getDescribe().getName();
                                                        Break; 
                                                    }        
                                                }
                                                WOL.put(fieldName, oppo.get(oppoApiName));
                                            }
                                            else if(wofmd.LineItemvalueType == 'Assign From Standard Quote'){
                                                if( opportunityIDQuoteRecords.size() > 0){
                                                    if( opportunityIDQuoteRecords.keyset().contains(oppo.Id)){
                                                        String oppoApiName = '';
                                                        for(Schema.SObjectField strField2 : quoteFeildMap.values()){
                                                            if( strField2.getDescribe().getlabel() == wofmd.woLineItemInsertedValue && oppoApiName == ''){   
                                                                oppoApiName = strField2.getDescribe().getName();
                                                                Break; 
                                                            }        
                                                        }
                                                        WOL.put(fieldName, opportunityIDQuoteRecords.get(oppo.Id).get(oppoApiName));
                                                    }
                                                }
                                            }
                                            else if(wofmd.LineItemvalueType == 'Assign From Standard Quote Line'){
                                                String oppoApiName = '';
                                                for(Schema.SObjectField strField2 : quoteLineItemFeildMap.values()){
                                                    if( strField2.getDescribe().getlabel() == wofmd.woLineItemInsertedValue && oppoApiName == ''){   
                                                        oppoApiName = strField2.getDescribe().getName();
                                                        Break; 
                                                    }        
                                                }
                                                
                                                if(opportunityIDQuoteLineItemRecords.keyset().contains(pro.Id)){
                                                    for(QuoteLineItem qli : opportunityIDQuoteLineItemRecords.get(pro.Id)){
                                                        if(qli.Quote.OpportunityId == oppo.Id)
                                                            WOL.put(fieldName, String.valueOf(qli.get(oppoApiName))); 
                                                    }
                                                }
                                            }
                                            else if(wofmd.LineItemvalueType == 'Assign From Product'){
                                                String oppoApiName = '';
                                                for(Schema.SObjectField strField2 : productFeildMap.values()){
                                                    if( strField2.getDescribe().getlabel() == wofmd.woLineItemInsertedValue && oppoApiName == ''){   
                                                        oppoApiName = strField2.getDescribe().getName();
                                                        Break; 
                                                    }        
                                                }
                                                WOL.put(fieldName, pro.get(oppoApiName));     
                                            }                                        
                                        }
                                    }
                                }
                                finalWorkOrderLine.add(WOL);
                            }
                            
                        }
                    }
                }
            }
        }
        if(finalWorkOrderLine.size() > 0){
            insert finalWorkOrderLine;
            system.debug('Work order line inserted');
        }
    }
    
    public static void createInvoiceWorkOrder( List < Opportunity > newList, Map < Id , Opportunity > newMap, List< Opportunity > oldList, Map< Id, Opportunity > oldMap ){
        system.debug('newList'+newList);
        system.debug('newMap'+newMap);
        system.debug('oldList'+oldList);
        system.debug('oldMap'+oldMap);
        String platformSelectionJson;
        String invoiceingData;
        List < Work_Order_Setting__c > fetchedInvoiceingWorkorderSetting = [SELECT Id, Invoice_Payment_JSON__c, Platform_Selection_JSON__c,Invoicing_Fields__c , Is_Active__c, RecordTypeId FROM Work_Order_Setting__c where RecordTypeId = '012C20000004MpxIAE' AND Is_Active__c = true ];
        
        if(fetchedInvoiceingWorkorderSetting.size() > 0){
            for(Work_Order_Setting__c wos:fetchedInvoiceingWorkorderSetting){
                invoiceingData = wos.Invoice_Payment_JSON__c;
                platformSelectionJson = wos.Invoicing_Fields__c ;
            }
        } 
        List <InvoiceingDataWrapper > invoiceingdatass = new  List < InvoiceingDataWrapper >();
        List < invoiceingFieldsMapping > platformSelectionDataa = new List < invoiceingFieldsMapping >();
        
        if( invoiceingData != null )
            invoiceingdatass = ( List < InvoiceingDataWrapper > ) JSON.deserialize( invoiceingData ,List < InvoiceingDataWrapper >.class);
        
        if( platformSelectionJson != null )
            platformSelectionDataa = ( List < invoiceingFieldsMapping > ) JSON.deserialize( platformSelectionJson ,List < invoiceingFieldsMapping >.class);
        
        Double InvoiceAmount;
        Double count;
        
        Map< id,Quote > OpportunityFetchedQuotes = new Map< id,Quote >();
        
        if( platformSelectionDataa[0].invoicingFieldsData.size() > 0){
            string query1 = 'SELECT Id, OpportunityId ';
            for(invoicingFieldsData pdata : platformSelectionDataa[0].invoicingFieldsData){
                if(String.valueOf(pdata.FieldName) != null && String.valueOf(pdata.ObjectName) != null && String.valueOf(pdata.FieldValue) != null){
                    if(pdata.ObjectName == 'Standard Quote'){
                        String fieldName = '';
                        for(Schema.SObjectField strField : quoteFeildMap.values()){
                            if(strField != null){
                                if( strField.getDescribe().getLabel() == pdata.FieldValue && fieldName == ''){                             
                                    fieldName = strField.getDescribe().getName();
                                    Break; 
                                } 
                            }
                        }
                        query1 += ' ,' +  fieldName; 
                    }
                }
            }
            query1 = query1.removeEnd(',');
            System.debug('query1-->'+query1);
            
            List< id> opportunityIds = new List< Id >();
            for(Opportunity oppo : newlist){
                opportunityIds.add(oppo.Id);
            }
            
            List < Quote > records = new List < Quote >();
            if(!opportunityIds.isEmpty()){
                if( query1 != 'SELECT Id, OpportunityId '){
                    query1 +=  ' from Quote where OpportunityId =: opportunityIds And IsSyncing = true';
                    System.debug('query1-->'+query1);
                    records = Database.query(query1);
                }
            }
            
            System.debug('fetched records --->'+records);
            if(records.size() > 0){
                For(Quote quo : records){
                    OpportunityFetchedQuotes.put(quo.OpportunityId , quo);
                }
            }  
        }
        system.debug('OpportunityFetchedQuotes--->'+OpportunityFetchedQuotes+'   '+OpportunityFetchedQuotes.isempty());
        
        Map < ID,opportunityAggegrateFeildsValues > opportunityIdAggegrateFeildsValues = new Map < ID,opportunityAggegrateFeildsValues >();
        
        if(platformSelectionDataa[0].invoicingFieldsData.size() > 0 && !OpportunityFetchedQuotes.isEmpty()){
            for(Opportunity oppo : newList){
                opportunityAggegrateFeildsValues oafv = new opportunityAggegrateFeildsValues();
                Date end_Date1;
                Date start_date1;
                String payment_Type1;
                String paymentFrequency1;
                Integer subscription_Term1;
                Integer TotalAmountForInvoice1;
                
                for(invoicingFieldsData ps : platformSelectionDataa[0].invoicingFieldsData ){
                    if(ps.ObjectName == 'Standard Quote'){
                        if(OpportunityFetchedQuotes.containsKey(oppo.Id)){
                            Quote fetchedQuote = OpportunityFetchedQuotes.get(oppo.Id);
                            if(fetchedQuote != null){
                                String fieldName = '';
                                for(Schema.SObjectField strField : quoteFeildMap.values()){
                                    if(strField != null){
                                        if( strField.getDescribe().getLabel() == ps.FieldValue && fieldName == ''){                             
                                            fieldName = strField.getDescribe().getName();
                                            Break; 
                                        } 
                                    }
                                }
                                if(ps.FieldName == 'Start Date')
                                    start_date1 = Date.valueOf(fetchedQuote.get(fieldName));
                                else if(ps.FieldName == 'End Date')
                                    end_Date1 = Date.valueOf(fetchedQuote.get(fieldName));
                                else if(ps.FieldName == 'Payment Type')
                                    payment_Type1 = String.valueOf(fetchedQuote.get(fieldName));
                                else if(ps.FieldName == 'Payment Frequency')
                                    paymentFrequency1 = String.valueOf(fetchedQuote.get(fieldName));
                                else if(ps.FieldName == 'Subscription Term')
                                    subscription_Term1 = Integer.valueOf(fetchedQuote.get(fieldName));
                                else if(ps.FieldName == 'Net Total')
                                    TotalAmountForInvoice1 = Integer.valueOf(fetchedQuote.get(fieldName)); 
                            }
                        }
                    }
                    else if(ps.ObjectName == 'Opportunity'){
                        Opportunity fetchedopportunity = newmap.get(oppo.Id);
                        if(fetchedopportunity != null){
                            String fieldName = '';
                            for(Schema.SObjectField strField : opportunityFeildsMap.values()){
                                if(strField != null){
                                    if( strField.getDescribe().getLabel() == ps.FieldValue && fieldName == ''){                             
                                        fieldName = strField.getDescribe().getName();
                                        Break; 
                                    } 
                                }
                            }
                            if(ps.FieldName == 'Start Date')
                                start_date1 = Date.valueOf(fetchedopportunity.get(fieldName));
                            else if(ps.FieldName == 'End Date')
                                end_Date1 = Date.valueOf(fetchedopportunity.get(fieldName));
                            else if(ps.FieldName == 'Payment Type')
                                payment_Type1 = String.valueOf(fetchedopportunity.get(fieldName));
                            else if(ps.FieldName == 'Payment Frequency')
                                paymentFrequency1 = String.valueOf(fetchedopportunity.get(fieldName));
                            else if(ps.FieldName == 'Subscription Term')
                                subscription_Term1 = Integer.valueOf(fetchedopportunity.get(fieldName));
                            else if(ps.FieldName == 'Net Total')
                                TotalAmountForInvoice1 = Integer.valueOf(fetchedopportunity.get(fieldName)); 
                        }
                    }  
                }
                if(start_date1 != null && payment_Type1 != null && TotalAmountForInvoice1 != null){
                    
                    oafv.Ostart_date = start_date1;
                    oafv.Oend_Date = end_Date1;
                    oafv.Opayment_Type = payment_Type1;
                    oafv.OpaymentFrequency = paymentFrequency1;
                    oafv.Osubscription_Term = subscription_Term1;
                    oafv.OTotalAmountForInvoice = TotalAmountForInvoice1;  
                }
                opportunityIdAggegrateFeildsValues.put(oppo.Id,oafv);
            }
        }
        System.debug('opportunityIdAggegrateFeildsValues---->'+opportunityIdAggegrateFeildsValues);
        
        Map<Id, List < Work_Order__c > > opportunityWorkOrderList = new Map< Id, List < Work_Order__c > > ();
        
        for(Opportunity oppo : newList){
            if(invoiceingdatass[0].invoicingData.size() > 0 && opportunityIdAggegrateFeildsValues .size() >0){  
                for(invoicingData idw : invoiceingdatass[0].invoicingData ){
                    opportunityAggegrateFeildsValues oafv = opportunityIdAggegrateFeildsValues.get(oppo.Id); 
                    if(idw.isActive == true){
                        System.debug('passed payment type-idw.paymentType->' + idw.paymentType);
                        System.debug('saved payment type-oafv.Opayment_Type->' +oafv.Opayment_Type);
                        if(idw.paymentType != null && oafv.Opayment_Type != null){
                            if(idw.paymentType == oafv.Opayment_Type){
                                System.debug('fetched payment type-->' + oafv.Opayment_Type);
                                isInvoicing = true;
                                if(idw.opportunityFieldsFilter.size() > 0)
                                    for(opportunityFieldsFilter off: idw.opportunityFieldsFilter){
                                        filterCondition.add(off); 
                                    } 
                                List< opportunity > tempNewList = new  List< opportunity >{ newmap.get(oppo.ID)};
                                    Map< id,opportunity > tempNewMap = new  Map< id,opportunity >();
                                tempNewMap.put(oppo.Id,newmap.get(oppo.ID));
                                List< opportunity > tempOldList = new  List< opportunity >{ oldmap.get(oppo.ID)};
                                    Map< id,opportunity > tempOldMap = new  Map< id,opportunity >();
                                tempOldMap.put(oppo.Id,oldmap.get(oppo.ID));
                                valueChangeCheaker(tempNewList, tempNewMap, tempOldList, tempOldMap);  
                            }
                        }
                    }
                    else 
                        System.debug('In false condition');
                }
                
            }
        }
        
        List< ID > satisfiedOpportunites = new List< ID >();
        for(Opportunity oppo : newList){
            if(conditionSatisfyTracker.containsKey(oppo.Id)){
                if(boolean.valueOf(conditionSatisfyTracker.get(oppo.Id))){
                    satisfiedOpportunites.add(oppo.Id);
                }
            }
        }
        
        List< Work_Order__c > invoiceingFinalWorkOrder = new List< Work_Order__c >(); 
        if(conditionSatisfyTracker.size() > 0 && platformSelectionDataa[0].invoicingFieldsData.size() > 0 && !opportunityIdAggegrateFeildsValues.isEmpty()){
            for(Opportunity oppo : newList){
                if(conditionSatisfyTracker.containsKey(oppo.Id)){
                    if(boolean.valueOf(conditionSatisfyTracker.get(oppo.Id))){
                        opportunityAggegrateFeildsValues oafv = opportunityIdAggegrateFeildsValues.get(oppo.Id);
                        Date start_date = oafv.Ostart_date;
                        Date end_Date = oafv.Oend_Date;
                        String paymentFrequency = oafv.OpaymentFrequency;
                        String payment_Type = oafv.Opayment_Type;
                        Integer subscription_Term = oafv.Osubscription_Term;
                        decimal TotalAmountForInvoice = oafv.OTotalAmountForInvoice;
                        System.debug('TotalAmountForInvoice---->'+TotalAmountForInvoice);
                        Date invoiceStartDate;
                        Date invoiceEndDate;
                        if(start_date != null && end_Date != null && paymentFrequency != null && payment_Type != null && subscription_Term != null && TotalAmountForInvoice != null ){
                            Decimal RemainingMonths;
                            if(start_date != null && end_Date != null){
                                RemainingMonths = start_date.monthsBetween(end_Date);
                            } 
                            for(invoicingData c: invoiceingdatass[0].invoicingData){
                                String paymentType = c.paymentType;
                                if(c.paymentType == 'Upfront' && paymentType == c.paymentType && payment_Type =='Upfront' ){
                                    count = 1;
                                }
                                else if(c.paymentType == 'Recurring' && paymentType == c.paymentType && payment_Type =='Recurring'){
                                    Date tempD;
                                    if(paymentFrequency == 'Monthly'){
                                        count = subscription_Term;
                                        InvoiceAmount=(TotalAmountForInvoice/count).setScale(2);
                                        invoiceStartDate = start_date;
                                        tempD = invoiceStartDate.addMonths(1);
                                        invoiceEndDate = tempD.addDays(-1);
                                    }
                                    else if(paymentFrequency == 'Quarterly'){
                                        count=Math.ceil(subscription_Term/3);
                                        InvoiceAmount=(TotalAmountForInvoice/count).setScale(2);
                                        invoiceStartDate = start_date;
                                        tempD = invoiceStartDate.addMonths(3);
                                        invoiceEndDate = tempD.addDays(-1);
                                    }
                                    else if(paymentFrequency == 'Semiannual'){
                                        count=Math.ceil(subscription_Term/6);
                                        InvoiceAmount=(TotalAmountForInvoice/count).setScale(2);
                                        invoiceStartDate = start_date;
                                        tempD = invoiceStartDate.addMonths(6);
                                        invoiceEndDate = tempD.addDays(-1);
                                    }
                                    else if(paymentFrequency == 'Annual'){
                                        count=Math.ceil(subscription_Term/12);
                                        InvoiceAmount=(TotalAmountForInvoice/count).setScale(2);
                                        invoiceStartDate = start_date;
                                        tempD = invoiceStartDate.addMonths(12);
                                        invoiceEndDate = tempD.addDays(-1);
                                    }
                                }
                                else if(c.paymentType == 'Phased' && paymentType == c.paymentType && payment_Type =='Phased'){
                                    
                                }
                                
                                if(c.isActive == true && paymentType == c.paymentType){
                                    for(Integer i = 1 ; i <= count ; i++){
                                        Work_Order__c WO = new Work_Order__c();
                                        WO.Opportunity__c = oppo.Id;
                                        if( i == 1 && count == 1){
                                            WO.Invoice_Start_Date__c = start_date; 
                                            WO.Invoice_End_Date__c = end_Date;
                                            WO.Invoice_Amount__c = TotalAmountForInvoice;
                                        }
                                        else if(count > 1){
                                            system.debug('InvoiceAmountInvoiceAmount--->'+InvoiceAmount);
                                            WO.Invoice_Amount__c = InvoiceAmount;
                                            WO.Invoice_Start_Date__c = invoiceStartDate;
                                            WO.Invoice_End_Date__c = invoiceEndDate; 
                                        }
                                        for(FieldsMapping WOWI: c.FieldsMapping){
                                            if(WOWI.woRecordTypeValue != '')
                                                WO.RecordTypeId = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get(WOWI.woRecordTypeValue).getRecordTypeId();
                                            for(woFieldsMappingList gWO : WOWI.woFieldsMappingList){
                                                String fieldApiName = '';
                                                String fieldType = '';
                                                for(Schema.SObjectField strField : workOrderFeildMap.values()){
                                                    if(strField != null){
                                                        fieldType = String.valueOf(strField.getDescribe().getType());
                                                        if( strField.getDescribe().getLabel() == gWO.selectField && fieldApiName == ''){                             
                                                            fieldApiName = strField.getDescribe().getName();
                                                            Break; 
                                                        } 
                                                    }
                                                }
                                                
                                                if(gWO.valueType == 'Assign Value'){
                                                    if(fieldType == 'BOOLEAN')
                                                        WO.put(fieldApiName, Boolean.valueOf(gWO.InsertedValue));
                                                    else if(fieldType == 'DATE')
                                                        WO.put(fieldApiName, Date.valueOf(gWO.InsertedValue));
                                                    else if(fieldType == 'DateTime')
                                                        WO.put(fieldApiName, DateTime.valueOfGmt(gWO.InsertedValue));
                                                    else if(fieldType == 'Double')
                                                        WO.put(fieldApiName,Double.valueOf(gWO.InsertedValue));   
                                                    else if(fieldType == 'Integer')
                                                        WO.put(fieldApiName,Integer.valueOf(gWO.InsertedValue)); 
                                                    else if(fieldType == 'Base64')
                                                        WO.put(fieldApiName, Blob.valueOf(gWO.InsertedValue));
                                                    else if(fieldType == 'CURRENCY' || fieldType == 'Percent')
                                                        WO.put(fieldApiName, Decimal.valueOf(gWO.InsertedValue));
                                                    else
                                                        WO.put(fieldApiName, gWO.InsertedValue);
                                                }
                                                else if(gWO.valueType == 'Assign From Opportunity'){
                                                    String oppoApiName = '';
                                                    for(Schema.SObjectField strField2 : opportunityFeildsMap.values()){
                                                        if( strField2.getDescribe().getlabel() == gWO.InsertedValue && oppoApiName == ''){   
                                                            oppoApiName = strField2.getDescribe().getName();
                                                            Break; 
                                                        }        
                                                    }
                                                    WO.put(fieldApiName, oppo.get(oppoApiName));
                                                }
                                            }
                                        }
                                        if(count > 1 && RemainingMonths > 0 && RemainingMonths != null){
                                            date tempDate;
                                            if(paymentFrequency == 'Monthly' && RemainingMonths > 0){
                                                invoiceStartDate = invoiceEndDate.addDays(1);
                                                tempDate = invoiceStartDate.addMonths(1);
                                                invoiceEndDate = tempDate.addDays(-1);
                                                RemainingMonths = RemainingMonths - 1;
                                                
                                            }
                                            else if(paymentFrequency == 'Quarterly' && RemainingMonths > 0){
                                                invoiceStartDate = invoiceEndDate.addDays(1); 
                                                RemainingMonths = RemainingMonths - 3;
                                                tempDate = invoiceStartDate.addMonths(3);
                                                invoiceEndDate = tempDate.addDays(-1);
                                            }
                                            else if(paymentFrequency == 'Semiannual' && RemainingMonths > 0){
                                                invoiceStartDate = invoiceEndDate.addDays(1); 
                                                RemainingMonths = RemainingMonths - 6;
                                                tempDate = invoiceStartDate.addMonths(6);
                                                invoiceEndDate = tempDate.addDays(-1);
                                                
                                            }
                                            else if(paymentFrequency == 'Annual' && RemainingMonths > 0){
                                                invoiceStartDate = invoiceEndDate.addDays(1); 
                                                RemainingMonths = RemainingMonths - 12;
                                                tempDate = invoiceStartDate.addMonths(12);
                                                invoiceEndDate = tempDate.addDays(-1);
                                            }    
                                        }
                                        invoiceingFinalWorkOrder.add(WO);
                                        opportunityWorkOrderList.put(oppo.Id,invoiceingFinalWorkOrder);                        
                                    }
                                }    
                            }
                        }
                    }
                }
            }
        }
        
        if(invoiceingFinalWorkOrder.size() > 0){
            insert invoiceingFinalWorkOrder;
            for(Integer i =0 ; i < invoiceingFinalWorkOrder.size()-1 ; i++){
                invoiceingFinalWorkOrder[i].Next_Invoiceing_Work_Order__c = invoiceingFinalWorkOrder[i + 1].Id;
            } 
            Update invoiceingFinalWorkOrder; 
        }
        
        if(opportunityWorkOrderList.size() > 0){
            List< Invoice_Line_Item__c > toInsertQuoteLine = new List< Invoice_Line_Item__c >();
            Map< ID, List <ID >> OpportunityIDProductId2 = new MAp<Id,list < ID >>(); 
            
            for(Opportunity oppor : newList){
                if(conditionSatisfyTracker.containsKey(oppor.Id)){
                    if(boolean.valueOf(conditionSatisfyTracker.get(oppor.Id)))
                        opportunityIDList.add(oppor.Id);
                }  
            }
            
            if(opportunityIDList.size() > 0 ){
                for( QuoteLineItem qli : [SELECT Id, QuoteId, OpportunityLineItem.OpportunityId , Quantity, UnitPrice, Discount, Product2Id, Product2.IsActive, TotalPrice FROM QuoteLineItem where OpportunityLineItem.OpportunityId =: opportunityIDList and Product2.IsActive = true]){
                    
                    if(OpportunityIDProductId2.containsKey(qli.OpportunityLineItem.OpportunityId))
                        OpportunityIDProductId2.get(qli.OpportunityLineItem.OpportunityId).add(qli.Product2Id);
                    else if(!OpportunityIDProductId2.containsKey(qli.OpportunityLineItem.OpportunityId))   
                        OpportunityIDProductId2.put(qli.OpportunityLineItem.OpportunityId,new List< Id >{qli.Product2Id});
                }
            }
            
            for(Opportunity oppor : newList){
                if(conditionSatisfyTracker.containsKey(oppor.Id) && opportunityWorkOrderList.containsKey(oppor.Id) && OpportunityIDProductId2.containsKey(oppor.Id) ){
                    if(boolean.valueOf(conditionSatisfyTracker.get(oppor.Id))){
                        if( opportunityWorkOrderList.get(oppor.Id) != null){
                            for(Work_Order__c FWO : opportunityWorkOrderList.get(oppor.Id) ){
                                for(Id qli : OpportunityIDProductId2.get(oppor.Id)){
                                    Invoice_Line_Item__c WOLil = new Invoice_Line_Item__c();
                                    WOLil.Product__c = qli; 
                                    WOLil.Work_Order__c = FWO.ID;
                                    WOLil.Start_Date__c = FWO.Invoice_Start_Date__c;
                                    WOLil.End_Date__c = FWO.Invoice_End_Date__c;
                                    toInsertQuoteLine.add(WOLil);
                                }
                            }
                            
                        }
                    }
                }
            }
            insert toInsertQuoteLine; 
        }  
    }
    
    
    
    public class InvoiceingDataWrapper {
        public invoicingData[] invoicingData{get;set;}
    }
    
    public class invoicingData {
        public String paymentType{get;set;}
        public Boolean isActive{get;set;}
        public opportunityFieldsFilter[] opportunityFieldsFilter{get;set;}
        public FieldsMapping[] FieldsMapping{get;set;}
    }
    
    public class opportunityFieldsFilter{
        public String condition{get;set;}
        public String logicValue{get;set;}
        public Boolean active{get;set;}
        public InnerList[] InnerList{get;set;}
    }
    
    public class FieldsMapping{
        public String woRecordTypeValue{get;set;}
        public woFieldsMappingList[] woFieldsMappingList{get;set;}
    }
    public class woFieldsMappingList {
        public String selectField{get;set;}
        public String valueType{get;set;}
        public String InsertedValue{get;set;}
    }
    
    
    
    public class Filterwrapper {
        public workOrderSetting[] workOrderSetting{get;set;} 
    }    
    public class workOrderSetting {
        public String condition{get;set;}
        public String logicValue{get;set;}
        public InnerList[] InnerList{get;set;}
    }
    public class InnerList {
        public String opportunityselectField{get;set;}
        public String operator{get;set;}
        public String enteredValue{get;set;}
    }
    
    
    
    public class ConditionsWrapper {
        public workOrderAllData[] workOrderAllData{get;set;}  
    }
    public class workOrderAllData {
        public String workOrderLineItemCreateAsPer{get;set;}
        public String woRelatedTypeValue{get;set;}
        public String selectedFieldSet{get;set;}
        public String wolifieldSetName{get;set;}
        public workOrderFieldList[] workOrderFieldList{get;set;}
        Public woliFieldMappingData[] woliFieldMappingData{get;set;}
    }
    
    public class woliFieldMappingData{
        public String lineItemselectField{get;set;}
        public String LineItemvalueType{get;set;}
        public String woLineItemInsertedValue{get;set;}
    }
    public class workOrderFieldList {
        public String selectField{get;set;}
        public String valueType{get;set;}
        public String InsertedValue{get;set;}
    }
    
    
    
    public class invoiceingFieldsMapping {
        public invoicingFieldsData[] invoicingFieldsData{get;set;}
    }
    public class invoicingFieldsData {
        public String FieldName{get;set;}
        public String ObjectName{get;set;}
        public String FieldValue{get;set;}
    }  
    
    public class opportunityAggegrateFeildsValues {
        public Date Ostart_date{get;set;}
        public Date Oend_Date{get;set;}
        public String Opayment_Type{get;set;}
        public String OpaymentFrequency{get;set;}
        public Integer Osubscription_Term{get;set;}
        public Integer OTotalAmountForInvoice{get;set;}
    }
}