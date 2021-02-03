class AddNebraskaUser < ActiveRecord::Migration[6.0]
  MIN_BIRTHDAY = (Time.zone.now - 2.weeks)
  MAX_BIRTHDAY = (Time.zone.now - 14.years)
  def up
    @user_nebraska = User.where(email: 'nebraska@test.com').first_or_create(
      active: true,
      full_name: 'Nebraska Provider',
      greeting_name: 'Candice',
      language: 'english',
      opt_in_email: true,
      opt_in_text: true,
      organization: 'Nebraska Child Care',
      password: 'testpass1234!',
      password_confirmation: 'testpass1234!',
      service_agreement_accepted: true,
      timezone: 'Mountain Time (US & Canada)'
    )

    @user_nebraska.confirm

    @business_nebraska = Business.where(name: 'Nebraska Home Child Care', user: @user_nebraska).first_or_create!(
      license_type: Licenses.types.keys.first,
      county: 'Cook',
      zipcode: '68123'
    )

    def create_case(full_name,
                    business: @business,
                    case_number: Faker::Number.number(digits: 10),
                    effective_on: Faker::Date.between(from: 1.year.ago, to: Time.zone.today),
                    date_of_birth: Faker::Date.between(from: MAX_BIRTHDAY, to: MIN_BIRTHDAY),
                    copay: Random.rand(10) > 7 ? nil : Faker::Number.between(from: 1000, to: 10_000),
                    copay_frequency: nil,
                    add_expired_approval: false)
      expires_on = effective_on + 1.year - 1.day

      copay_frequency = copay ? Approval::COPAY_FREQUENCIES.sample : nil

      approvals = [
        Approval.find_or_create_by!(
          case_number: case_number,
          copay_cents: copay,
          copay_frequency: copay_frequency,
          effective_on: effective_on,
          expires_on: expires_on
        )
      ]

      if add_expired_approval
        approvals << Approval.find_or_create_by!(
          case_number: case_number,
          copay_cents: copay ? copay - 1200 : nil,
          copay_frequency: copay_frequency,
          effective_on: effective_on - 1.year,
          expires_on: effective_on - 1.day
        )
      end
      child = Child.find_or_initialize_by(business: business,
                                          full_name: full_name,
                                          date_of_birth: date_of_birth)
      child.approvals << approvals
      child.save!
    end

    rhonan = create_case('Rhonan Shaw', business: @business_nebraska)
    tanim = create_case('Tanim Zaidi', business: @business_nebraska, add_expired_approval: true)
    jasveen = create_case('Jasveen Khirwar', business: @business_nebraska, add_expired_approval: true)
    manuel = create_case('Manuel Céspedes', business: @business_nebraska)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
