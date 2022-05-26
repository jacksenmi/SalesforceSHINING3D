public without sharing class Account_Controller {
	public Id accID {get; set;}
    public Boolean isError {get; set;}
    // 判断U9推送情况
    public String U9_Is_Success {Get; Set;}
    public Account_Controller(ApexPages.StandardController controller) {
    	accID = controller.getId();
        isError = false;
        Account acc = [SELECT Id, U9_Is_Success__c, (SELECT Id, ApprovalStatus__c FROM Account_Approval_Account__r) FROM Account WHERE Id =:accID];
        if (acc.Account_Approval_Account__r.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.AccountPushApproved));
            isError = true;
        } else {
            U9_Is_Success = acc.U9_Is_Success__c;
            for (Account_Approval__c acp : acc.Account_Approval_Account__r) {
                if (acp.ApprovalStatus__c == 'Approving') {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.AccountPushApproved));
                    isError = true;
                    break;
                }
            }
        }
        System.debug(LoggingLevel.INFO, '*** isError: ' + isError);
    }

    public PageReference accountpush() {  

    	OutBoundUtils.callOut_Sync(new List<Id>{accID}, 'AccountSyncOutbound');

        // Cbl_Account_IncreatCallout.IncreatCallout(accid);
        return new PageReference('/'+accid);
    } 

    @remoteAction
    public static Event_Log__c pushNS(String accID) {
        Event_Log__c eventLog = new Event_Log__c();
        // Organization org = [SELECT Id, IsSandbox  FROM Organization];
        // System.debug(LoggingLevel.INFO, '*** org: ' + org);

        // 正式环境暂不对接NS，直接更新成功, 等NS上线注释
        // if (org.IsSandbox) {
            eventLog = OutBoundUtils.callOut_Sync(new List<Id>{accID}, 'AccountSyncOutbound');
        // } else {
        //     Account acc = [SELECT Id, Name, NS_Is_Success__c  FROM Account WHERE Id =:accID];
        //     acc.NS_Is_Success__c = 'Success';
        //     update acc;
        // }
        return eventLog;
    }

    @remoteAction
    public static Event_Log__c pushU9(String accID) {
        Event_Log__c eventLog = OutBoundUtils.callOut_Sync(new List<Id>{accID}, 'U9_AccountSyncOutbound');
        return eventLog;
    }

}