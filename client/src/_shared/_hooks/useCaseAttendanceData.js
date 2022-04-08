export function useCaseAttendanceData() {
  const reduceTableData = res => {
    return res.flatMap((child, index) => {
      return child.state === 'NE'
        ? {
            id: child.id ?? '',
            key: `${index}-${child.first_name}-${child.last_name}`,
            child: {
              childFirstName: child.first_name ?? '',
              childLastName: child.last_name ?? '',
              cNumber: child.case_number ?? '',
              business: child.business.name ?? ''
            },
            active: child.active ?? true
          }
        : {
            id: child.id ?? '',
            key: `${index}-${child.first_name}-${child.last_name}`,
            childFirstName: child.first_name ?? '',
            childLastName: child.last_name ?? '',
            cNumber: child.case_number ?? '',
            business: child.business.name ?? '',
            active: child.active ?? true
          }
    })
  }
  return { reduceTableData }
}
