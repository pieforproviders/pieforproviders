import React from 'react'
import PropTypes from 'prop-types'

export function CSVImportReview({ kids }) {
  return (
    <div className="csv-import-review">
      {kids && (
        <div className="kids-list">
          {kids.map(kid => {
            const { info, id } = kid
            return (
              <div key={id}>
                {info[0]} {info[1]} {info[2]}
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}

CSVImportReview.propTypes = {
  kids: PropTypes.arrayOf(PropTypes.object)
}
