# Pie for Providers Data Model Narrative

## Purpose

The purpose of this document is to bridge the gap between the data model and real world usage/domain knowledge for engineers.

## Users

The most likely user for Pie for Providers in the MVP phase is a *Shared Service Alliance* staff member who is supporting *Family Childcare Providers* in billing and subsidy eligibility.  This document is meant to describe the connection between user domain knowledge/experience/interaction and the data model.  All **Capitalized and Bolded** terms are table-backed models in the Rails application.  There will be some notation on whether or not behavior is currently implemented or needs to be designed/decided, as of 10/20/2020.

## Onboarding and Account Creation

As a user, I will create an account, generating a **User** record.

I will log in and be "onboarded" via the UI; I will upload the case records of the businesses I am supporting and the children for whom they provide care.  During onboarding, I will provide information about the **Child** receiving childcare and the subsidy, the **Business** that provides childcare to that **Child**, and the **Approval** letter that outlines details about the subsidy for which the family (a collection of **Children** in the same household with the same case number) is eligible.  Each case record entered in during onboarding is the associated information that makes up a **ChildApproval**.

> ### Onboarding Example
>
> I am an Illinois SSA staff member, and I am supporting two **Businesses**, "Happy Hearts Childcare" and "Little Leaf Day School".
> During onboarding, I enter 6 children's cases:
>
> - Juan Ortiz
> - Julia Ortiz
> - Shao Liuxian
> - Thalia Makrouli
> - Kimbu Mòsi
> - Amaury Mòsi
>
> Juan and Julia Ortiz are siblings, both attending Happy Hearts Childcare.  The state sent an Approval letter that covers both of the Children, at the same business.  Their records in onboarding look like this:  
>
> | First name (Child.full_name) | Last name (Child.full_name) | Date of birth (Child.date_of_birth)| Business Name (Business.name) | Business Zip Code (Business.zipcode) | Business County (Business.county) | Business QRIS rating (TO BE IMPLEMENTED) | Case number (Approval.case_number) | Full days (ChildApprovalRateTypes) | Part days (ChildApprovalRateTypes) | Effective on (Approval.effective_on) | Expires on (Approval.expires_on) | Co-pay (Approval.copay_cents[monetize]) | Co-pay frequency (Approval.copay_frequency[enum]) |
> | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
> | Juan | Ortiz | 2015-04-14 | Happy Hearts Childcare | 60606 | Cook | Gold | 1234567 | 18 | 4 | 2019-11-12 | 2020-11-12 | $100 | Monthly |
> | Julia | Ortiz | 2017-12-01 | Happy Hearts Childcare | 60606 | Cook | Gold | 1234567 | 22 | 5 | 2019-11-12 | 2020-11-12 | $100 | Monthly |
>
> Kimbu and Amaury Mòsi are siblings, and they attend different child care centers.  The state sent an Approval letter that covers both of the Children, at different businesses.  Their records in onboarding look like this:
>
> | First name (Child.full_name) | Last name (Child.full_name) | Date of birth (Child.date_of_birth) | Business Name (Business.name) | Business Zip Code (Business.ZipCode) | Business County (Business.County) | Business QRIS rating (TO BE IMPLEMENTED) | Case number (Approval.case_number) | Full days (ChildApprovalRateTypes) | Part days (ChildApprovalRateTypes) | Effective on (Approval.effective_on) | Expires on (Approval.expires_on) | Co-pay (Approval.copay_cents[monetize]) | Co-pay frequency (Approval.copay_frequency[enum]) |  
> | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
> | Kimbu | Mòsi | 2014-06-30 | Happy Hearts Childcare | 60606 | Cook | Gold | 4567890 | 10 | 10 | 2020-02-04 | 2021-02-04 | $12 | Weekly |
> | Amaury | Mòsi | 2012-09-11 | Little Leaf Day School | 60101 | DuPage | Bronze | 4567890 | 11 | 7 | 2020-02-04 | 2021-02-04 | $12 | Weekly |  
> 
> The remaining childrren will each have their own record with unique case numbers
    
**TO BE IMPLEMENTED**: At the end of onboarding, I will have entered data to create 4 **Approvals** (one for each family), 6 **Children**, 6 **ChildApprovals**, 2 **Businesses**

The backend will then do the following:  

- based on **Child**'s age, **County** where care is received, QRIS rating of the **Business** [some other info?] - associate a **SubsidyRule** with each **ChildApproval**

- check on **Child**'s address because the provider will not receive a subsidy for a child that is not a resident of Illinois [TO BE IMPLEMENTED]

This concludes onboarding and creating subsidy cases at the beginning of a user's account setup.  It should be noted that when a child is renewed for the subsidy:

- **TO BE IMPLEMENTED**: if their case number remains the same, new **ChildApprovals** will be generated for each child, associated to the original **Approval**, with new effective_on and expires_on dates
- **TO BE IMPLEMENTED**: if their case number is different when renewal happens, a new **Approval** and associated **ChildApprovals** will be generated for each child
- When a **Child** is created, 12 **[State]ApprovalAmounts** will be added and associated to the **ChildApproval** created at that time, starting from the given "first_month_name" and "first_month_year", one per month, with the appropriate rate_type columns (i.e. in **IllinoisApprovalAmounts**, there will be a column for `part_days_approved` and a column for `full_days_approved`) (this is currently only implemented for Nebraska)

## Attendance and other Income Tracking

As a child attends their child care provider, they generate **Attendances** (which the provider can bill the state for in order to receive subsidy funds).

**TO BE IMPLEMENTED**: In other states, things like enrollment fees or providing a child transportation can be reimbursed by the state as a part of a **SubsidyRule**.

**TO BE IMPLEMENTED**: On the fly, the UI will request, for example, "Predicted Revenue by Child" - Pie will use the **Attendances** for the current time period, as well as the other billable rates defined in the **SubsidyRule** that belongs to the associated **ChildApproval** to determine what the state owes for that Child (did the child meet the threshold of what they were approved for?), along with some other predictive algorithms TBD.

**TO BE IMPLEMENTED** adding rate type amounts to ChildApprovals - might make sense to have associated StateApprovals like we have for Subsidy Rules
