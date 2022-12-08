/**
 * Created by alexey on 29/11/2022.
 */

public with sharing class BatchLauncherController {

    @AuraEnabled
    public static Map<String, String> checkScheduler(String nameScheduler) {

        Map<String, String> result = new Map<String, String>();
        List<CronTrigger> sch = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :nameScheduler];

        if (!sch.isEmpty()) {
            result.put('id', sch[0].Id);
        }
        return result;
    }

    @AuraEnabled
    public static void runOnceBatch(String nameBatchClass) {
        Type customType = Type.forName(nameBatchClass);
        Database.Batchable<SObject> instance = (Database.Batchable<SObject>) customType.newInstance();
        Database.executeBatch(instance);
    }

    @AuraEnabled
    public static Id scheduleBatch(String cron, String nameScheduler) {
        Type customType = Type.forName(nameScheduler);
        Schedulable instance = (Schedulable) customType.newInstance();
        String sch = cron;
        String jobID = System.schedule(nameScheduler, sch, instance);
        CronTrigger scheduler = [SELECT Id FROM CronTrigger WHERE Id = :jobID];
        return scheduler.Id;
    }

    @AuraEnabled
    public static void abortBatch(String ids) {
        System.abortJob(ids);
    }
}