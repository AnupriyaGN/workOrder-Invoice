public class workorderLandingPageHandler {
    public static void onAfterUpdate(List<Opportunity>newList,Map<Id,Opportunity>newMap,List<Opportunity>oldList, Map<Id,Opportunity>oldMap){
        System.debug('calling work order and lineitem creation from handler');
        workorderLandingPageHelper.valueChangeCheaker(newList,newMap,oldList,oldMap);
        System.debug('Calling invoiceing from handler');
        //workorderLandingPageHelper.createInvoiceWorkOrder(newList,newMap,oldList,oldMap);
    }
}