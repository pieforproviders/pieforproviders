import { useApiResponse } from '_shared/_hooks/useApiResponse'
import { useSelector } from 'react-redux'
import { useProgress } from '_shared/_hooks/useProgress'
import { useCaseData } from '_shared/_hooks/useCaseData'

export const useApiService = () => {
  const { makeRequest } = useApiResponse()
  const { token, user } = useSelector(state => ({
    token: state.auth.token,
    user: state.user
  }))
  const { parseResult } = useProgress()
  const { reduceTableData } = useCaseData()

  return {
    getChildCases: async (filterDate = undefined) => {
      const baseUrl = '/api/v1/case_list_for_dashboard'
      const response = await makeRequest({
        type: 'get',
        url: filterDate
          ? baseUrl + `?filter_date=${filterDate.dateFilterValue.date}`
          : baseUrl,
        headers: { Authorization: token }
      })

      const parsedResponse = await parseResult(response)
      if (parsedResponse.error) {
        //handle error
        return
      }

      return reduceTableData(parsedResponse, user)
    }
  }
}
