/**
 * Created by alexey on 23/11/2022.
 */

public with sharing class PaymentTriggerHandler {
    public static void changeStageOppAndCreateTask(List<Payment__c> newPayments) {

        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();

        List<String> oppNameNewPayments = getOppNameNewPayments(newPayments);

        List<Payment__c> payments = getPayments(oppNameNewPayments);

        List<Opportunity> opportunities = getOpportunities(oppNameNewPayments);

        List<Task> newTask = new List<Task>();
        Datetime now = Datetime.now();
        changeStageAndCreateTask(opportunities, payments, now, newTask, opportunitiesToUpdate);

        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
        if (!newTask.isEmpty()) {
            insert newTask;
        }
    }

    private static List<String> getOppNameNewPayments(List<Payment__c> newPayments) {
        List<String> oppNameNewPayments = new List<String>();

        for (Payment__c pay : newPayments) {
            oppNameNewPayments.add(pay.OpportunityName__c);
        }
        return oppNameNewPayments;
    }

    private static List<Payment__c> getPayments(List<String> oppNameNewPayments) {
        List<Payment__c> payments = [
                SELECT Id, OpportunityName__c, Amount__c
                FROM Payment__c
                WHERE OpportunityName__c IN :oppNameNewPayments
        ];
        return payments;
    }

    private static List<Opportunity> getOpportunities(List<String> oppNameNewPayments) {
        List<Opportunity> opportunities = [
                SELECT Id, Name, StageName, Amount, (SELECT Id, Contact.OwnerId FROM OpportunityContactRoles WHERE IsPrimary = TRUE)
                FROM Opportunity
                WHERE Name IN :oppNameNewPayments
        ];
        return opportunities;
    }

    private static void changeStageAndCreateTask(List<Opportunity> opportunities, List<Payment__c> payments,
            Datetime now, List<Task> newTask, List<Opportunity> opportunitiesToUpdate) {
        for (Opportunity opp : opportunities) {
            Decimal amount = totalSumPayment(payments, opp);
            if (amount < opp.Amount && opp.StageName != 'Partially Paid') {
                opp.StageName = 'Partially Paid';
                opportunitiesToUpdate.add(opp);
            } else if (amount >= opp.Amount && opp.StageName != 'Fully Paid') {
                opp.StageName = 'Fully Paid';
                opportunitiesToUpdate.add(opp);
                createTask(opp, now, newTask);
            }
        }
    }

    private static Decimal totalSumPayment(List<Payment__c> payments, Opportunity opp) {
        Decimal amount = 0;
        for (Payment__c pay : payments) {
            if (pay.OpportunityName__c == opp.Name) {
                amount += pay.Amount__c;
            }
        }
        return amount;
    }

    private static void createTask(Opportunity opp, Datetime now, List<Task> newTask) {
        Task task = new Task(
                IsReminderSet = true,
                OwnerId = opp.OpportunityContactRoles[0].Contact.OwnerId,
                Priority = 'High',
                Status = 'Not Started',
                Subject = 'Delivery of goods',
                ReminderDateTime = Datetime.newInstance(
                        now.year(),
                        now.month(),
                        now.day() + 1,
                        10,
                        0,
                        0
                ),
                WhatId = opp.Id
        );
        newTask.add(task);
    }

}