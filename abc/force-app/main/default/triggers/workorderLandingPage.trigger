trigger workorderLandingPage on Opportunity (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            workorderLandingPageHandler.onAfterUpdate(Trigger.New,Trigger.Newmap,Trigger.Old,Trigger.Oldmap);
        }
    }
}