/**
 * Created by alexey on 01/12/2022.
 */
@IsTest
public with sharing class CheckContactSchedulerTest {
    public static String CRON_EXP = '0 0 0 * * ?';
    @IsTest
    static void schedulerTest() {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 3; i++) {
            Contact newCont = new Contact(
                    FirstName   = 'Alexey',
                    LastName    = 'Kamenev',
                    Birthdate   = Date.today(),
                    Email       = 'test@gmail.com'
            );
            contacts.add(newCont);
        }
        insert contacts;
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',
                CRON_EXP,
                new CheckContactsScheduler());
        Test.stopTest();
    }
}