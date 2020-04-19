import axios from './axios'

export const getUsers = async () => {
  const { data } = await axios.get('/api/v1/users')
  return data
}

export const getBusinesses = async () => {
  const { data } = await axios.get('/api/v1/businesses')
  return data
}

export default {
  getBusinesses,
  getUsers
}
