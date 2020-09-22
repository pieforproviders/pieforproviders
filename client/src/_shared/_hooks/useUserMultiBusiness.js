import { createLocalStorageStateHook } from 'use-local-storage-state'
export const useUserMultiBusiness = createLocalStorageStateHook(
  'pie-multiBusiness',
  false
)
