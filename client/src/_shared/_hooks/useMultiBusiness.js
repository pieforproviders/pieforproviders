import useLocalStorageState from 'use-local-storage-state'

const useMultiBusiness = () => {
  const [multiBusiness, setMultiBusiness] = useLocalStorageState(
    'pie-multiBusiness',
    null
  )

  return {
    multiBusiness,
    setMultiBusiness
  }
}

export default useMultiBusiness
