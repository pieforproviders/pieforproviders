# Attendances & Absences

## Definitions
- absence  
A day on which a child is scheduled to attend but does not - represented by a `ServiceDay` with an `absence_type`

- attendance  
A day on which a child attends, whether or not they are scheduled - represented by an `Attendance` with `check_in` and an optional `check_out`

- `ServiceDay`  
A record that `has_many` attendances (0 or more) and `belongs_to` a child and represents a single day in the child's timezone

## Absences added during Onboarding 
### Internal Onboarding CSV Import
#### `Wonderschool::Necc::OnboardingCaseImporter`

- NO-OP: as a new approval is added, we will not create any prior absences

## Attendance Entry
### Internal Pie CSV Import
#### `AttendanceCsvImporter`

> **Assumptions/Decisions**
> - if this is an import for attendance dates before the child was onboarded, a Pie staffer must add absences to the spreadsheet to have them count appropriately
> 
> **Behavior currently not defined**
> - error handling

- Potential Errors
  - can't find AWS source bucket
  - no files in AWS source bucket
  - no contents in file(s)
  - CSV parse failure of contents
  - can't find AWS archive bucket
  - can't archive file(s) in AWS archive bucket

- for each row:
  - find `Business` by splitting the file name
    - Potential Errors
      - can't find business by properly-formatted file name
      - can't find business by improperly-formatted file name
  - find `Child` by `Business` and DHS ID or First & Last Name
    - Potential Errors
      - can't find child
  - if the row contains an attendance
    - if an `Attendance` exists for that child with the same check_in, check_out, and `ChildApproval`
      - do nothing
    - if an `Attendance` does not exist for that child with the same check_in, check_out, and `ChildApproval`
      - if a `ServiceDay` exists for that day for that child
        - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay` and the active `ChildApproval`
          - Potential Errors
            - [Attendance Model Validations](#attendance---model-validations)
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
        - add an `Attendance` w/ the `check_in`, `check_out`, associated to the new `ServiceDay`
          - Potential Errors
            - [Attendance Model Validations](#attendance---model-validations)
    - if the row contains an absence
      - if the child is scheduled for that day
        - if a `ServiceDay` exists for that day for that child
          - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
            - Potential Errors
              - [Service Day Model Validations](#service-day---model-validations)
        - if a `ServiceDay` does not exist for that day for that child
          - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_scheduled_day"`
            - Potential Errors
                - [Service Day Model Validations](#service-day---model-validations)
      - if the child is not scheduled for that day
        - if a `ServiceDay` exists for that day for that child
          - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`
            - Potential Errors
              - [Service Day Model Validations](#service-day---model-validations)
        - if a `ServiceDay` does not exist for that day for that child
          - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_unscheduled_day"`
            - Potential Errors
              - [Service Day Model Validations](#service-day---model-validations)

### Daily Wonderschool CSV Import
#### `Wonderschool::Necc::AttendanceCsvImporter`

> **Assumptions/Decisions**
> - We do not get absences from Wonderschool
> - if an attendance exists in the wonderschool import one day and does not exist the next day, we will not find missing attendances and remove them
>
> **Behavior currently not defined**
> - there is currently no user-facing way to delete Wonderschool attendances
> - error handling

- Potential Errors
  - can't parse the URI
  - can't parse the CSV file
  - no contents in file
  - can't find AWS archive bucket
  - can't archive file(s) in AWS archive bucket

- for each row:
  - find child by `wonderschool_id`
    - Potential Errors
      - can't find child
  - if an attendance exists with the `Attendance.wonderschool_id`
    - if the `check_in` or `check_out` are different
      - update the attendance w/ the `check_in`, `check_out`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
    - if the `check_in` and `check_out` are the same
      - do nothing
  - if an attendance does not exist with the `Attendance.wonderschool_id`
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, `wonderschool_id` associated to that `ServiceDay`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
        - Potential Errors
          - [Service Day Model Validations](#service-day---model-validations)
      - add an `Attendance` w/ the `check_in`, `check_out`, `wonderschool_id` associated to the new `ServiceDay`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)

### User-facing UI Attendance & Absence Creation
#### `AttendanceBatchesController#create` & `ServiceDaysController#create`

> **Behavior currently not defined**
> - error handling

- Potential Errors
  - param batch is empty
  - param batch is malformed

- for each record in the batch:
  - find `Child` by child_id
    - Potential Errors
      - can't find child
      - child_id is wrong/nil/malformed
  - ensure user has permissions to create for that child
    - Potential Errors
      - user does not have permissions
  - find the current child_approval
    - Potential Errors
      - user does not have permissions
  - if the record contains an attendance
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay` and the active `ChildApproval`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
      - if the `ServiceDay` has an `absence_type`
        - change the `absence_type` to nil
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
      - if the `ServiceDay` has a nil `absence_type`
        - do nothing
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
        - Potential Errors
          - [Service Day Model Validations](#service-day---model-validations)
      - add an `Attendance` w/ the `check_in`, `check_out`, associated to the new `ServiceDay`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
  - if the record contains an absence
    - if the child is scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_scheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
    - if the child is not scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_unscheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)

### Daily Automatic Absence Creation
#### `Nebraska::AbsenceGenerator`

> **Behavior currently not defined**
> - error handling

- for all children in Nebraska, generates a `ServiceDay` with `absence_type: "automatic_absence_on_scheduled_day"` if the child is scheduled that day and if there's no current attendances on that `ServiceDay`
  - Potential Errors
    - [Service Day Model Validations](#service-day---model-validations)

## Attendance Edit
### User-facing UI Attendance Edit
#### `AttendancesController#update`

> **Assumptions/Decisions**
> - Users cannot edit WS attendance
> 
> **Behavior currently not defined**
> - error handling

- if the update changes an existing attendance
  - if the `check_in` or `check_out` are different
    - update the attendance w/ the `check_in`, `check_out`
      - Potential Errors
        - [Attendance Model Validations](#attendance---model-validations)
  - if the `check_in` and `check_out` are the same
    - do nothing
- if the update adds an additional attendance
  - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay` and the active `ChildApproval`
    - Potential Errors
      - [Attendance Model Validations](#attendance---model-validations)
- if the update changes the ServiceDay to an absence
  - if the child is scheduled for that day
      - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
        - Potential Errors
          - [Service Day Model Validations](#service-day---model-validations)
  - if the child is not scheduled for that day
    - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`
      - Potential Errors
        - [Service Day Model Validations](#service-day---model-validations)

## Attendance Deletion
### User-facing UI Attendance Delete
#### `AttendancesController#destroy`

> **Assumptions/Decisions**
> - Users cannot delete WS attendance
> 
> **Behavior currently not defined**
> - error handling

- delete the `Attendance` record
  - if there are more attendances for that day
    - do nothing
  - if there are no more attendances for that day
    - delete the `ServiceDay`

## Next Steps
- Undefined behavior as listed above (explicitly call out possible error states)
- Audit current behavior for differences
- Write tickets to address ^

## Open Questions
- Implementation: How much should an attendance know about its service day?  Ideally - nothing - but how will the front-end/API consumers know when they need to explicitly turn a ServiceDay to an attendance, etc.?
- What are we using Schedules for?  Decouple from ServiceDays

## Engineering Improvements Suggested
- Move the reliant behavior (edits/attendances/ServiceDay absences, etc.) to their own commands and call them in explicit orders as necessary
- in AttendanceCsvImporter (internal) - don't update w/ absence if it's nil & existing record also has nil absence - just saves a db call (see: `app/services/attendance_csv_importer.rb:78`)
- find another way to get Business from AttendanceCsvImporter rather than file name
- get Business at the top of the AttendanceCsvImporter and set for each file (we're currently setting it in every row)
- Better batching behavior (AttendanceBatchesController is not my fave)
- DRY up and refactor attendance batches controller - we're looking for the child and child approval multiple times, probably a better way to do this

## Required Changes to Current Behavior
- Remove validation that requires ServiceDay w/ an absence_type to be associated to a Schedule
- Add `absence_on_scheduled_day` to types
- Add `absence_on_unscheduled_day` to types
- Change input from all sources to include new absence types

## Possible Error States
### Attendance - Model Validations
- `Attendance.check_in` is required
- `Attendance.check_in` must be a time_param format
- `Attendance.check_out` must be a time_param format or nil
- `Attendance.check_in` must be before `Attendance.check_out`
- `Attendance` must be associated to a `ServiceDay`
- `Attendance` must be associated to a `ChildApproval`

### Service Day - Model Validations
- `ServiceDay.absence_type` must be one of our pre-defined list of types (absence, covid_absence) or nil
- `ServiceDay.date` is required
- `ServiceDay.date` must be a date_time_param format
- `ServiceDay` must be associated to a `Child`