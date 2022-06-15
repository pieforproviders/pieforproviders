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

- Potential Errors
  - can't find AWS source bucket
    - log error to AppSignal w/ alerts to customer support & tech team
  - no files in AWS source bucket
    - log error to AppSignal w/ alerts to customer support & tech team
  - no contents in file(s)
    - log error to AppSignal w/ alerts to customer support & tech team
  - CSV parse failure of contents
    - log error to AppSignal w/ alerts to customer support & tech team
  - can't find AWS archive bucket
    - log error to AppSignal w/ alerts to tech team 
  - can't archive file(s) in AWS archive bucket
    - log error to AppSignal w/ alerts to tech team

- for each row:
  - find `Business` by splitting the file name
    - Potential Errors
      - can't find business by properly-formatted file name
        - log error to AppSignal w/ alerts to customer support & tech team
      - can't find business by improperly-formatted file name
        - log error to AppSignal w/ alerts to customer support & tech team
  - find `Child` by `Business` and DHS ID or First & Last Name
    - Potential Errors
      - can't find child
        - log error to AppSignal w/ alerts to customer support
  - if the row contains an attendance
    - if an `Attendance` exists for that child with the same check_in, check_out, and `ChildApproval`
      - do nothing
    - if an `Attendance` does not exist for that child with the same check_in, check_out, and `ChildApproval`
      - if a `ServiceDay` exists for that day for that child
        - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay` and the active `ChildApproval`
          - Potential Errors
            - [Attendance Model Validations](#attendance---model-validations)
              - log error to AppSignal w/ alerts to customer support & tech team
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - log error to AppSignal w/ alerts to customer support & tech team
        - add an `Attendance` w/ the `check_in`, `check_out`, associated to the new `ServiceDay`
          - Potential Errors
            - [Attendance Model Validations](#attendance---model-validations)
              - log error to AppSignal w/ alerts to customer support & tech team
  - if the row contains an absence
    - if the child is scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - log error to AppSignal w/ alerts to customer support & tech team
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_scheduled_day"`
          - Potential Errors
              - [Service Day Model Validations](#service-day---model-validations)
                - log error to AppSignal w/ alerts to customer support & tech team
    - if the child is not scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - log error to AppSignal w/ alerts to customer support & tech team
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_unscheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - log error to AppSignal w/ alerts to customer support & tech team

### Daily Wonderschool CSV Import
#### `Wonderschool::Necc::AttendanceCsvImporter`

> **Assumptions/Decisions**
> - We do not get absences from Wonderschool
> - if an attendance exists in the wonderschool import one day and does not exist the next day, we will not find missing attendances and remove them
> - will will not currently build a user-facing way to delete Wonderschool attendances

- Potential Errors
  - can't parse the URI
    - log error to AppSignal w/ alerts to customer support & tech team
  - can't parse the CSV file
    - log error to AppSignal w/ alerts to customer support & tech team
  - no contents in file
    - log error to AppSignal w/ alerts to customer support & tech team
  - can't find AWS archive bucket
    - log error to AppSignal w/ alerts to tech team
  - can't archive contents in AWS archive bucket
    - log error to AppSignal w/ alerts to tech team

- for each row:
  - find child by `wonderschool_id`
    - Potential Errors
      - can't find child
        - log error to Coralogix with no alerts (the WS import includes all the provider's kids, even if they're not receiving subsidy)
  - if an attendance exists with the `Attendance.wonderschool_id`
    - if the `check_in` or `check_out` are different
      - update the attendance w/ the `check_in`, `check_out`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
            - log error to AppSignal w/ alerts to customer support & tech team
    - if the `check_in` and `check_out` are the same
      - do nothing
  - if an attendance does not exist with the `Attendance.wonderschool_id`
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, `wonderschool_id` associated to that `ServiceDay`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
            - log error to AppSignal w/ alerts to customer support & tech team
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
        - Potential Errors
          - [Service Day Model Validations](#service-day---model-validations)
            - log error to AppSignal w/ alerts to customer support & tech team
      - add an `Attendance` w/ the `check_in`, `check_out`, `wonderschool_id` associated to the new `ServiceDay`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
            - log error to AppSignal w/ alerts to customer support & tech team

### User-facing UI Attendance & Absence Creation
#### `AttendanceBatchesController#create` & `ServiceDaysController#create`

- Potential Errors
  - param batch is empty
    - do nothing
  - param batch is malformed
    - return error in API response
    - display API error to user
    - log error to AppSignal for front-end w/ alerts to tech team & customer support

- for each record in the batch:
  - find `Child` by child_id
    - Potential Errors
      - can't find child
        - return error in API response
        - display API error to user
        - log error to AppSignal for front-end w/ alerts to tech team & customer support
      - child_id is wrong/nil/malformed
        - return error in API response
        - display API error to user
        - log error to AppSignal for front-end w/ alerts to tech team & customer support
  - ensure user has permissions to create for that child
    - Potential Errors
      - user does not have permissions
        - return error in API response
        - display API error to user
        - log error to AppSignal for front-end w/ alerts to tech team & customer support
  - find the current child_approval
    - Potential Errors
      - there is no current child approval for that date for that child
        - return error in API response
        - display API error to user
        - log error to AppSignal for front-end w/ alerts to tech team & customer support
  - if the record contains an attendance
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay` and the active `ChildApproval`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
            - return error in API response
            - display API error to user
            - log error to AppSignal for front-end w/ alerts to tech team & customer support
      - if the `ServiceDay` has an `absence_type`
        - change the `absence_type` to nil
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - return error in API response
              - display API error to user
              - log error to AppSignal for front-end w/ alerts to tech team & customer support
      - if the `ServiceDay` has a nil `absence_type`
        - do nothing
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
        - Potential Errors
          - [Service Day Model Validations](#service-day---model-validations)
            - return error in API response
            - display API error to user
            - log error to AppSignal for front-end w/ alerts to tech team & customer support
      - add an `Attendance` w/ the `check_in`, `check_out`, associated to the new `ServiceDay`
        - Potential Errors
          - [Attendance Model Validations](#attendance---model-validations)
            - return error in API response
            - display API error to user
            - log error to AppSignal for front-end w/ alerts to tech team & customer support
  - if the record contains an absence
    - if the child is scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - return error in API response
              - display API error to user
              - log error to AppSignal for front-end w/ alerts to tech team & customer support
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_scheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - return error in API response
              - display API error to user
              - log error to AppSignal for front-end w/ alerts to tech team & customer support
    - if the child is not scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - return error in API response
              - display API error to user
              - log error to AppSignal for front-end w/ alerts to tech team & customer support
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_unscheduled_day"`
          - Potential Errors
            - [Service Day Model Validations](#service-day---model-validations)
              - return error in API response
              - display API error to user
              - log error to AppSignal for front-end w/ alerts to tech team & customer support

### Daily Automatic Absence Creation
#### `Nebraska::AbsenceGenerator`

- for all children in Nebraska, generates a `ServiceDay` with `absence_type: "automatic_absence_on_scheduled_day"` if the child is scheduled that day and if there's no current attendances on that `ServiceDay`
  - Potential Errors
    - [Service Day Model Validations](#service-day---model-validations)
      - log error to AppSignal w/ alerts to tech team & customer support

## Attendance Edit
### User-facing UI Attendance Edit
#### `AttendancesController#update`

> **Assumptions/Decisions**
> - Users cannot edit WS attendance

- if the update changes an existing attendance
  - if the `check_in` or `check_out` are different
    - update the attendance w/ the `check_in`, `check_out`
      - Potential Errors
        - [Attendance Model Validations](#attendance---model-validations)
          - return error in API response
          - display API error to user
          - log error to AppSignal for front-end w/ alerts to tech team & customer support
  - if the `check_in` and `check_out` are the same
    - do nothing
- if the update adds an additional attendance
  - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay` and the active `ChildApproval`
    - Potential Errors
      - [Attendance Model Validations](#attendance---model-validations)
        - return error in API response
        - display API error to user
        - log error to AppSignal for front-end w/ alerts to tech team & customer support
- if the update changes the ServiceDay to an absence
  - if the child is scheduled for that day
      - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
        - Potential Errors
          - [Service Day Model Validations](#service-day---model-validations)
            - return error in API response
            - display API error to user
            - log error to AppSignal for front-end w/ alerts to tech team & customer support
  - if the child is not scheduled for that day
    - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`
      - Potential Errors
        - [Service Day Model Validations](#service-day---model-validations)
          - return error in API response
          - display API error to user
          - log error to AppSignal for front-end w/ alerts to tech team & customer support

## Attendance Deletion
### User-facing UI Attendance Delete
#### `AttendancesController#destroy`

> **Assumptions/Decisions**
> - Users cannot delete WS attendance

- delete the `Attendance` record
  - if there are more attendances for that day
    - do nothing
  - if there are no more attendances for that day
    - delete the `ServiceDay`
      - Potential Errors
        - can't delete the `ServiceDay`
          - return error in API response
          - display API error to user
          - log error to AppSignal for front-end w/ alerts to tech team & customer support

## Next Steps
- Kate to write tickets to address new error handling

## Open Questions
- How much should an attendance know about its service day?  Ideally - nothing - but how will the front-end/API consumers know when they need to explicitly turn a ServiceDay to an attendance, etc.?

## Engineering Improvements Suggested
- Move the reliant behavior (edits/attendances/ServiceDay absences, etc.) to their own commands and call them in explicit orders as necessary
- in AttendanceCsvImporter (internal) - don't update w/ absence if it's nil & existing record also has nil absence - just saves a db call (see: `app/services/attendance_csv_customer support.rb:78`)
- find another way to get Business from AttendanceCsvImporter rather than file name
- Better batching behavior (AttendanceBatchesController is not my fave)
- DRY up and refactor attendance batches controller - we're looking for the child and child approval multiple times, probably a better way to do this

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