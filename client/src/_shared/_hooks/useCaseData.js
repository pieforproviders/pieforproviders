export function useCaseData() {
  const reduceTableData = (res, user) => {
    return res.flatMap(userResponse => {
      return userResponse.businesses.flatMap(business => {
        return business.cases.flatMap((childCase, index) => {
          const baseData = {
            id: childCase.id ?? '',
            key: `${index}-${childCase.first_name}-${childCase.last_name}`,
            active: childCase.active ?? true,
            approvalEffectiveOn:
              childCase.nebraska_dashboard_case?.approval_effective_on ??
              childCase.illinois_dashboard_case?.approval_effective_on ??
              '',
            approvalExpiresOn:
              childCase.nebraska_dashboard_case?.approval_expires_on ??
              childCase.illinois_dashboard_case?.approval_expires_on ??
              ''
          }

          if (user.state === 'NE') {
            return {
              ...baseData,
              absences: childCase.nebraska_dashboard_case.absences ?? '',
              absences_dates: childCase.nebraska_dashboard_case.absences_dates,
              child: {
                childFirstName: childCase.first_name ?? '',
                childLastName: childCase.last_name ?? '',
                cNumber: childCase.nebraska_dashboard_case.case_number ?? '',
                business: business.name ?? ''
              },
              earnedRevenue:
                childCase.nebraska_dashboard_case.earned_revenue ?? '',
              estimatedRevenue:
                childCase.nebraska_dashboard_case.estimated_revenue ?? '',
              fullDays: {
                text: childCase.nebraska_dashboard_case.full_days ?? '',
                tag: childCase.nebraska_dashboard_case.attendance_risk ?? ''
              },
              partDays: {
                text: 'partialDays',
                info: childCase.nebraska_dashboard_case.part_days
              },
              totalPartDays: {
                text: 'totalPartDays',
                info: childCase.nebraska_dashboard_case.total_part_days
              },
              remainingPartDays:
                childCase.nebraska_dashboard_case.remaining_part_days,
              hours: childCase.nebraska_dashboard_case.hours ?? '',
              hoursAttended:
                childCase.nebraska_dashboard_case.hours_attended ?? '',
              familyFee: childCase.nebraska_dashboard_case.family_fee ?? '',
              hoursAuthorized:
                childCase.nebraska_dashboard_case.hours_authorized ?? '',
              hoursRemaining:
                childCase.nebraska_dashboard_case.hours_remaining ?? '',
              fullDaysAuthorized:
                childCase.nebraska_dashboard_case.full_days_authorized ?? '',
              fullDaysRemaining:
                childCase.nebraska_dashboard_case.full_days_remaining ?? ''
            }
          } else {
            return {
              ...baseData,
              childFirstName: childCase.first_name ?? '',
              childLastName: childCase.last_name ?? '',
              cNumber: childCase.illinois_dashboard_case.case_number ?? '',
              business: business.name ?? '',
              attendanceRate: {
                rate: childCase.illinois_dashboard_case.attendance_rate ?? '',
                riskCategory:
                  childCase.illinois_dashboard_case.attendance_risk ?? ''
              },
              guaranteedRevenue:
                childCase.illinois_dashboard_case.guaranteed_revenue ?? '',
              maxApprovedRevenue:
                childCase.illinois_dashboard_case.max_approved_revenue ?? '',
              potentialRevenue:
                childCase.illinois_dashboard_case.potential_revenue ?? '',
              fullDaysAttended:
                childCase.illinois_dashboard_case.full_days_attended ?? true,
              partDaysAttended:
                childCase.illinois_dashboard_case.part_days_attended ?? true,
              childInfo: childCase ?? ''
            }
          }
        })
      })
    })
  }

  return { reduceTableData }
}
