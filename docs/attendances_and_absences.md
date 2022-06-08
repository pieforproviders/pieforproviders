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
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_scheduled_day"`
    - if the child is not scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_unscheduled_day"`

### Daily Wonderschool CSV Import
#### `Wonderschool::Necc::AttendanceCsvImporter`

> **Assumptions/Decisions**
> - We do not get absences from Wonderschool
> - if an attendance exists in the wonderschool import one day and does not exist the next day, we will not find missing attendances and remove them
>
> **Behavior currently not defined**
> - there is currently no user-facing way to delete Wonderschool attendances
> - error handling

- for each row:
  - if an attendance exists with the `wonderschool_id`
    - if the `check_in` or `check_out` are different
      - update the attendance w/ the `check_in`, `check_out`
    - if the `check_in` and `check_out` are the same
      - do nothing
  - if an attendance does not exist with the `wonderschool_id`
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, `wonderschool_id` associated to that `ServiceDay`
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, `wonderschool_id` associated to the new `ServiceDay`

### User-facing UI Attendance & Absence Creation
#### `AttendanceBatchesController#create` & `ServiceDaysController#create`

> **Behavior currently not defined**
> - error handling

- for each record in the batch:
  - if the record contains an attendance
    - if a `ServiceDay` exists for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay`
      - if the `ServiceDay` has an `absence_type`
        - change the `absence_type` to nil
      - if the `ServiceDay` has a nil `absence_type`
        - do nothing
    - if a `ServiceDay` does not exist for that day for that child
      - create a `ServiceDay` for that day for that child
      - add an `Attendance` w/ the `check_in`, `check_out`, associated to the new `ServiceDay`
  - if the record contains an absence
    - if the child is scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_scheduled_day"`
    - if the child is not scheduled for that day
      - if a `ServiceDay` exists for that day for that child
        - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`
      - if a `ServiceDay` does not exist for that day for that child
        - create a `ServiceDay` for that day for that child w/ the `absence_type: "absence_on_unscheduled_day"`

### Daily Automatic Absence Creation
#### `Nebraska::AbsenceGenerator`

> **Behavior currently not defined**
> - error handling

- for all children in Nebraska, generates a `ServiceDay` with `absence_type: "automatic_absence_on_scheduled_day"` if the child is scheduled that day and if there's no current attendances on that `ServiceDay`

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
  - if the `check_in` and `check_out` are the same
    - do nothing
- if the update adds an additional attendance
  - add an `Attendance` w/ the `check_in`, `check_out` associated to that `ServiceDay`
- if the update changes the ServiceDay to an absence
  - if the child is scheduled for that day
      - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_scheduled_day"`
  - if the child is not scheduled for that day
    - change the `ServiceDay` to an absence w/ the `absence_type: "absence_on_unscheduled_day"`

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

## Engineering Improvements Suggested
- Move the reliant behavior (edits/attendances/ServiceDay absences, etc.) to their own commands and call them in explicit orders as necessary
