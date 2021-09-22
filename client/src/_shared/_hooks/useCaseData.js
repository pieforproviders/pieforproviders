export function useCaseData() {
  const reduceTableData = (res, user) => {
    return res.flatMap(userResponse => {
      return userResponse.businesses.flatMap(business => {
        return business.cases.flatMap((childCase, index) => {
          return user.state === 'NE'
            ? {
                id: childCase.id ?? '',
                key: `${index}-${childCase.full_name}`,
                absences: childCase.absences ?? '',
                child: {
                  childName: childCase.full_name ?? '',
                  cNumber: childCase.case_number ?? '',
                  business: business.name ?? ''
                },
                earnedRevenue: childCase.earned_revenue ?? '',
                estimatedRevenue: childCase.estimated_revenue ?? '',
                fullDays: {
                  text: childCase.full_days ?? '',
                  tag: childCase.attendance_risk ?? ''
                },
                hours: childCase.hours ?? '',
                hoursAttended: childCase.hours_attended ?? '',
                familyFee: childCase.family_fee ?? '',
                active: childCase.active ?? true
              }
            : {
                id: childCase.id ?? '',
                key: `${index}-${childCase.full_name}`,
                childName: childCase.full_name ?? '',
                cNumber: childCase.case_number ?? '',
                business: business.name ?? '',
                attendanceRate: {
                  rate: childCase.attendance_rate ?? '',
                  riskCategory: childCase.attendance_risk ?? ''
                },
                guaranteedRevenue: childCase.guaranteed_revenue ?? '',
                maxApprovedRevenue: childCase.max_approved_revenue ?? '',
                potentialRevenue: childCase.potential_revenue ?? '',
                active: childCase.active ?? true
              }
        })
      })
    })
  }
  return { reduceTableData }
}
