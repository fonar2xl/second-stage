/**
 * Created by alexey on 01/12/2022.
 */
@IsTest
public with sharing class BatchLauncherControllerTest {
    @IsTest
    static void checkSchedulerTest() {
        Test.startTest();
        String jobId = System.schedule('CheckContactsScheduler',
                '0 0 0 * * ?',
                new CheckContactsScheduler());
        BatchLauncherController.checkScheduler('CheckContactsScheduler');
        Test.stopTest();
        List<CronTrigger> sch = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'CheckContactsScheduler'];
        System.assert(!sch.isEmpty());
    }
    @IsTest
    static void runOnceBatchTest() {
        Test.startTest();
        BatchLauncherController.runOnceBatch('CheckContactsBatch');
        Test.stopTest();
        List<AsyncApexJob> a = [SELECT Id, Status FROM AsyncApexJob];
        System.assert(!a.isEmpty());
        System.assertEquals('Completed', a[0].Status);
    }
    @IsTest
    static void scheduleBatchTest() {
        Test.startTest();
        BatchLauncherController.scheduleBatch('0 0 0 * * ?', 'CheckContactsScheduler');
        Test.stopTest();
        List<CronTrigger> sch = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'CheckContactsScheduler'];
        System.assert(!sch.isEmpty());
    }
    @IsTest
    static void abortBatchTest() {
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                '0 0 0 * * ?',
                new CheckContactsScheduler());
        List<CronTrigger> sch = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'ScheduledApexTest'];
        BatchLauncherController.abortBatch(jobId);
        Test.stopTest();
        List<CronTrigger> schAfterAbort = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'ScheduledApexTest'];
        System.assert(!sch.isEmpty());
        System.assert(schAfterAbort.isEmpty());
    }
}