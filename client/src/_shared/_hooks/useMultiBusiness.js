import createPersistedState from 'use-persisted-state'
const useMultiBusinessState = createPersistedState('pie-multiBusiness')

const useMultiBusiness = () => {
  const [multiBusiness, setMultiBusiness] = useMultiBusinessState(null)

  return {
    multiBusiness,
    setMultiBusiness
  }
}

export default useMultiBusiness
