export function useCaseData() {
  const reduceTableData = (res, user) => {
    return res.flatMap(userResponse => {
      return userResponse.businesses.flatMap(business => {
        return business.cases.flatMap((childCase, index) => {
          return user.state === 'NE'
            ? {
                id: childCase.id ?? '',
                key: `${index}-${childCase.first_name}-${childCase.last_name}`,
                absences: childCase.nebraska_dashboard_case.absences ?? '',
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
                hours: childCase.nebraska_dashboard_case.hours ?? '',
                hoursAttended:
                  childCase.nebraska_dashboard_case.hours_attended ?? '',
                familyFee: childCase.nebraska_dashboard_case.family_fee ?? '',
                active: childCase.active ?? true,
                hoursAuthorized:
                  childCase.nebraska_dashboard_case.hours_authorized ?? '',
                hoursRemaining:
                  childCase.nebraska_dashboard_case.hours_remaining ?? '',
                fullDaysAuthorized:
                  childCase.nebraska_dashboard_case.full_days_authorized ?? '',
                fullDaysRemaining:
                  childCase.nebraska_dashboard_case.full_days_remaining ?? '',
                approvalEffectiveOn:
                  childCase.nebraska_dashboard_case.approval_effective_on ?? '',
                approvalExpiresOn:
                  childCase.nebraska_dashboard_case.approval_expires_on ?? ''
              }
            : {
                id: childCase.id ?? '',
                key: `${index}-${childCase.first_name}-${childCase.last_name}`,
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
                active: childCase.active ?? true,
                fullDaysAttended:
                  childCase.illinois_dashboard_case.full_days_attended ?? true,
                partDaysAttended:
                  childCase.illinois_dashboard_case.part_days_attended ?? true
              }
        })
      })
    })
  }
  return { reduceTableData }
}
