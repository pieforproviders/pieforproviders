# Attendances & Absences

## Definitions

- absence  
A day on which a child is scheduled to attend but does not - represented by a `ServiceDay` with an `absence_type`

- attendance  
A day on which a child attends, whether or not they are scheduled - represented by an `Attendance` with `check_in` and `check_out`

- `ServiceDay`  
A record that `has_many` attendances and `belongs_to` a child

## Expected Behavior

### Absences added during Onboarding 

#### _Internal Onboarding CSV Import -  `Wonderschool::Necc::OnboardingCaseImporter`_

- as a new approval is added, create a new absence for every child in that approval from the beginning of the approval to the end of the approval (or to the day of onboarding, whichever comes first)

### Attendance Entry

#### _Internal Pie CSV Import - `AttendanceCsvImporter`_

- for each row:
  - if the row contains an attendance
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay`
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, associated to the new `ServiceDay`
  - if the row contains an absence
    - if the child is scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type`
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type`
    - if the child is not scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - delete the `ServiceDay`
      - if a `ServiceDay` does not exist for that day for that child
        - do nothing

    > Behavior currently not defined 
    > - error handling

#### _Daily Wonderschool CSV Import - `Wonderschool::Necc::AttendanceCsvImporter`_

**Assumption: We do not get absences from Wonderschool**

- for each row:
  - if an attendance exists with the `wonderschool_id`
    - update the attendance w/ the `check_in`, `check_out`
  - if an attendance does not exist with the `wonderschool_id`
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, `wonderschool_id` associated to that `ServiceDay`
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, `wonderschool_id` associated to the new `ServiceDay`

  > Behavior currently not defined 
  > - if an attendance exists in the wonderschool import one day and does not exist the next day, we do not find missing attendances and remove them
  > - there is currently no programmatic or user-facing way to do delete Wonderschool attendances
  > - error handling

#### _User-facing UI Attendance & Absence Creation - `AttendanceBatchesController#create` & `ServiceDaysController#create`_

- for each record in the batch:
  - if the record contains an attendance
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay`
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, associated to the new `ServiceDay`
  - if the record contains an absence
    - if the child is scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type`
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type`
    - if the child is not scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - delete the `ServiceDay`
      - if a `ServiceDay` does not exist for that day for that child
        - do nothing

  > Behavior currently not defined 
  > - error handling

### Daily Automatic Absence Creation

> `Nebraska::AbsenceGenerator`

- for all children in Nebraska, generates an absence if there's no current attendance AND if the child is scheduled that day

### Attendance Edit

#### _User-facing UI Attendance Edit - `AttendancesController#update`_

- if the update changes an existing attendance
  - update the attendance w/ the `check_in`, `check_out`
- if the update adds an additional attendance
  - if a `ServiceDay` exists for that day for that child
    - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay`
  - if a `ServiceDay` does not exist for that day for that child
    - create a `ServiceDay` for that day for that child
    - add an `Attendance` w/ the `check_in`, `check_out`, associated to the new `ServiceDay`
- if the update changes the ServiceDay to an absence
  - if the child is scheduled for that day
    - if a `ServiceDay` exists for that day for that child
      - change the `ServiceDay` to an absence w/ the `absence_type`
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child w/ the `absence_type`
  - if the child is not scheduled for that day
    - if a `ServiceDay` exists for that day for that child
      - delete the `ServiceDay`
    - if a `ServiceDay` does not exist for that day for that child
      - do nothing

  > Behavior currently not defined 
  > - error handling

### Attendance Deletion

#### _User-facing UI Attendance Delete - `AttendancesController#destroy`_

- delete the `Attendance` record
  - if there are no more attendances for that day
    - if the child is scheduled for that day
      - update the `ServiceDay` to `absence_type: "absence"`
    - if the child is not scheduled for that day
      - delete the `ServiceDay`

  > Behavior currently not defined 
  > - error handling

## Open Questions
- Undefined behavior as listed above
- Is this desired behavior?
> - if the child is not scheduled for that day  
>   - if a `ServiceDay` exists for that day for that child  
>     - delete the `ServiceDay`
- How much should an attendance know about its service day?  Ideally - nothing - but how will the front-end/API consumers know when they need to explicitly turn a ServiceDay to an attendance, etc.?

## Engineering Improvements Suggested

- Move the reliant behavior (edits/attendances/ServiceDay absences, etc.) to their own commands and call them in explicit orders as necessary