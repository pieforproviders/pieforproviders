export function useCaseAttendanceData() {
  const reduceTableData = res => {
    return res.flatMap((child, index) => {
      return child.state === 'NE'
        ? {
            id: child.id ?? '',
            key: `${index}-${child.full_name}`,
            child: {
              childName: child.full_name ?? '',
              cNumber: child.case_number ?? '',
              business: child.business.name ?? ''
            },
            active: child.active ?? true
          }
        : {
            id: child.id ?? '',
            key: `${index}-${child.full_name}`,
            childName: child.full_name ?? '',
            cNumber: child.case_number ?? '',
            business: child.business.name ?? '',
            active: child.active ?? true
          }
    })
  }
  return { reduceTableData }
}
