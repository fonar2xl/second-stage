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
    }
    @IsTest
    static void runOnceBatchTest() {
        Test.startTest();
        BatchLauncherController.runOnceBatch('CheckContactsBatch');
        Test.stopTest();
    }
    @IsTest
    static void scheduleBatchTest() {
        Test.startTest();
        BatchLauncherController.scheduleBatch('0 0 0 * * ?', 'CheckContactsScheduler');
        Test.stopTest();
    }
    @IsTest
    static void abortBatchTest() {
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                '0 0 0 * * ?',
                new CheckContactsScheduler());
        BatchLauncherController.abortBatch(jobId);
        Test.stopTest();
    }
}