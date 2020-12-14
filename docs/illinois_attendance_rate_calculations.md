# Pie for Providers IL Attendance Rate Calculations

## Purpose

The purpose of this document is to document calculations that will be used to determine attendance rate, attendance risk, and revenue for providers.


## Eligible Payout Days per Month

```ruby
# pseudocode

# if the provider is only open business days
eligible_payout_days_this_month = business_days_this_month - holidays

# if the provider is open business days + 1 weekend day
eligible_payout_days_this_month = all_days_this_month - non_working_weekend_days - holidays

# if the provider is open 7 days a week
eligible_payout_days_this_month = all_days_this_month - holidays

# TODO: if they're open, say M-W-F - edge case
```

## Attendance Rate

According to IL CCAP Staff, `family_attendance_rate` is calculated as follows:

```ruby
# pseudocode

# assume case number == family

family_days_attended = 0
for child in family_children do
  family_days_attended += child.attendances.where(date: this_month, attendance_duration: less_than_5_hours).count
  family_days_attended += child.attendances.where(date: this_month, attendance_duration: between_5_hours_and_12_hours_inclusive).count
  # these longer attendances technically count for TWO TYPES of attendances (either part + full or full + full) so we count them twice
  family_days_attended += (child.attendances.where(date: this_month, attendance_duration: more_than_12_hours_less_than_17_hours).count * 2)
  family_days_attended += (child.attendances.where(date: this_month, attendance_duration: between_17_hours_and_24_hours_inclusive).count * 2)
end

family_days_approved = 0
for child in family_children do
  # if the child is approved for, say, 4 full time days and 1 part time day per month, and this month is March 2021, which starts on a Monday
  # and ends on a Wednesday - the child would technically be approved for 25 days in March
  # this calculation would give us 4 * 5 weeks (20) and 1 * 5 weeks (5) and will be limited by eligible days in the next step
  family_days_approved += child.illinois_monthly_approved_amounts.find(date: this_month).part_days_approved_per_week * weeks_this_month
  family_days_approved += child.illinois_monthly_approved_amounts.find(date: this_month).full_days_approved_per_week * weeks_this_month
end
# if there are only 23 eligible days this month (March 2021 - business days only, for example), we will take the 23 instead of the 25 since
# there's no way for the child to get paid for more than the 23 days
family_days_approved = [family_days_approved, eligible_payout_days_this_month].min

family_attendance_rate = family_days_attended / family_days_approved
```

## Calculating approved days and attended days per child

```ruby
attended_part_days = child.attendances.where(date: this_month, attendance_duration: less_than_5_hours).count
attended_full_days = child.attendances.where(date: this_month, attendance_duration: between_5_hours_and_12_hours_inclusive).count
# these longer attendances technically count for TWO TYPES of attendances (part + full) so we add to both types
attended_part_days += child.attendances.where(date: this_month, attendance_duration: more_than_12_hours_less_than_17_hours).count
attended_full_days += child.attendances.where(date: this_month, attendance_duration: more_than_12_hours_less_than_17_hours).count
# these longer attendances technically count for TWO TYPES of attendances (full + full) so we multiply the count by two
attended_full_days += (child.attendances.where(date: this_month, attendance_duration: between_17_hours_and_24_hours_inclusive).count * 2)

part_days_approved = child.illinois_monthly_approved_amounts.find(date: this_month).part_days_approved_per_week * weeks_this_month
full_days_approved = child.illinois_monthly_approved_amounts.find(date: this_month).full_days_approved_per_week * weeks_this_month

if school_age && attended_full_days > full_days_approved
  full_day_overage = attended_full_days - full_days_approved
  borrowed_part_days = part_days_approved - full_day_overage
  if borrowed_part_days >= 0
    part_days_approved -= borrowed_part_days
    full_days_approved += borrowed_part_days
  else
    part_days_approved < 0
    full_days_approved += part_days_approved
  end
end
```

## Attendance Risk

Attendance risk is the likelihood of the provider to receive all the subsidy funding for which the children in their care are eligible.  This is business logic determined by Pie for Providers.

This logic is calculated at a point in time during any given month:

```ruby

# if the provider is only open business days
days_left_this_month = business_days_left_this_month - holidays

# if the provider is open business days + 1 weekend day
days_left_this_month = all_days_left_this_month - non_working_weekend_days - holidays

# if the provider is open 7 days a week
days_left_this_month = all_days_left_this_month - holidays


# pseudocode - this will be run on each child specifically
for child in family_children do
  # if last day of entered attendance is not halfway through the month, we don't have enough info
  if latest_attendance_data_date < days_in_month / 2
    child_attendance_risk = "not_enough_info"
  else
    # if the family HAS NOT met the threshold
    if family_attendance_rate < threshold
      # if there aren't enough days left in the month for this family to hit the threshold
      # ex: .495 (threshold) * 20 (approved) - 8 (attended) = 1.9 days need to be attended yet (round up)
      # ex: 2 (number of kids) * 4 (days left in the month) = 8 days left to possibly attend
      # ex: this conditional is false
      if (threshold * family_days_approved - family_days_attended) > family_children.count * days_left_in_this_month
        child_attendance_risk = "not_met"
      # if the family hasn't met the threshold proportionately as calculated by how much of the month has elapseed
      # ex: 8 (attended) / [(26 / 30) * 20] < 0.495
      # ex: 8 / [0.867 * 20] < 0.495
      # ex: 8 / 17.333 < 0.495 (you don't have to attend 100% of the days to meet the threshold - what percentage are we at so far)
      # ex: 0.462 < 0.495
      # ex: this conditional is true
      elsif family_days_attended / [(days_elapsed_this_month / days_in_this_month) * family_days_approved] < threshold
        child_attendance_risk = "at_risk"
      # all other cases
      else
        child_attendance_risk = "on_track"
      end
    # if the family HAS met the threshold
    else
      must_attend_part_days = part_days_approved > 0 ? true : false
      must_attend_full_days = full_days_approved > 0 ? true : false

      if (!must_attend_part_days || attended_part_days > 0) && (!must_attend_full_days || attended_full_days > 0)
        child_attendance_risk = "sure_bet"
      else
        child_attendance_risk = "on_track"
      end
    end
  end
end
```

## Revenue

While family attendance rate is calculated by total days approved and total days attended no matter if a rate_type was attended or not, REVENUE relies on whether or not a rate type has at least 1 attendance; if it doesn't, that whole rate type is 0'ed out in terms of revenue expected from the state.

```ruby
# psuedocode

attended_full_days = [attended_full_days, full_days_approved].min
attended_part_days = [attended_part_days, part_days_approved].min

# if the child is approved for more days than are eligible for pay this month, remove extra days from part_days because
# that's lower pay, so the max would be if the child attended more full_days
part_days_approved = [part_days_approved, eligible_days_this_month - full_days_approved].min

# TODO: COPAY DECISIONS

maximum_revenue = full_days_approved * full_day_rate + part_days_approved * part_day_rate - copay

potential_revenue = if child.attendance_risk == "not_met"
  full_days_difference = full_days_approved - attended_full_days
  part_days_difference = part_days_approved - attended_part_days
  potential_revenue_full_days = [days_left_in_month, full_days_difference].min
  if full_days_difference < 0
  if full_days_difference < days_left_in_month
    potential_revenue_part_days = [days_left_in_month - full_days_difference, part_days_difference].min
  else
    potential_revenue_part_days = 0
  end
  (full_days_attended + potential_revenue_full_days) * full_day_rate + (part_days_attended + potential_revenue_part_days) * part_day_rate - copay
else
  maximum_revenue
end

guaranteed_revenue = if family_attendance_rate > threshold
  if full_days_attended > 0
    full_day_revenue = full_days_approved * full_day_rate
  else
    full_day_revenue = 0
  end
  
  if part_days_attended > 0
    part_day_revenue = part_days_approved * part_day_rate
  else
    part_day_revenue = 0
  end
  full_day_revenue + part_day_revenue - copay
else
  full_days_attended * full_day_rate +  part_days_attended * part_day_rate - copay
end
```
