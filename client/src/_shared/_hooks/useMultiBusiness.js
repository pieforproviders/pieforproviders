export function useMultiBusiness() {
  const setIsMultiBusiness = multiBusiness => {
    localStorage.setItem('pie-multiBusiness', multiBusiness)
  }

  const isMultiBusiness = !!localStorage.getItem('pie-multiBusiness')

  return {
    isMultiBusiness: isMultiBusiness,
    setIsMultiBusiness: setIsMultiBusiness
  }
}
