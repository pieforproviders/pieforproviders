import { createLocalStorageStateHook } from 'use-local-storage-state'
export const useAuthToken = createLocalStorageStateHook('pie-token', null)
