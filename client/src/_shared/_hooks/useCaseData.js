export function useCaseData() {
  const reduceTableData = (res, user) => {
    return res.flatMap(userResponse => {
      return userResponse.businesses.flatMap(business => {
        return business.cases.flatMap((childCase, index) => {
          return user.state === 'NE'
            ? {
                id: childCase.id ?? '',
                key: `${index}-${childCase.full_name}`,
                absences: childCase.nebraska_dashboard_case.absences ?? '',
                child: {
                  childName: childCase.nebraska_dashboard_case.full_name ?? '',
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
                active: childCase.active ?? true
              }
            : {
                id: childCase.nebraska_dashboard_case.id ?? '',
                key: `${index}-${childCase.nebraska_dashboard_case.full_name}`,
                childName: childCase.nebraska_dashboard_case.full_name ?? '',
                cNumber: childCase.nebraska_dashboard_case.case_number ?? '',
                business: business.name ?? '',
                attendanceRate: {
                  rate: childCase.nebraska_dashboard_case.attendance_rate ?? '',
                  riskCategory:
                    childCase.nebraska_dashboard_case.attendance_risk ?? ''
                },
                guaranteedRevenue:
                  childCase.nebraska_dashboard_case.guaranteed_revenue ?? '',
                maxApprovedRevenue:
                  childCase.nebraska_dashboard_case.max_approved_revenue ?? '',
                potentialRevenue:
                  childCase.nebraska_dashboard_case.potential_revenue ?? '',
                active: childCase.active ?? true
              }
        })
      })
    })
  }
  return { reduceTableData }
}
