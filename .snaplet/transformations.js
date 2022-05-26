const { copycat, faker } = require('@snaplet/copycat')

/**
 * @type { import("./transformations").Transformations }
 */

module.exports = () => ({
  public: {
    approvals: ({ row }) => ({
      case_number: copycat.uuid(row.case_number)
    }),
    businesses: ({ row }) => ({
      name: copycat.fullName(row.name)
    }),
    children: ({ row }) => ({
      first_name: copycat.firstName(row.first_name),
      last_name: copycat.lastName(row.last_name)
    }),
    users: ({ row }) => ({
      email: copycat.email(row.email),
      phone_number: copycat.phoneNumber(row.phone_number),
      state: copycat.oneOf(row.state, faker.locales.en.address.state),
      timezone: copycat.timezone(row.timezone),
      organization: copycat.word(row.organization),
      current_sign_in_ip: copycat.ipv4(row.current_sign_in_ip),
      last_sign_in_ip: copycat.ipv4(row.last_sign_in_ip)
    })
  }
})
