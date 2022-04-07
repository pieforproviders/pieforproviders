# frozen_string_literal: true

# This is a 1-off task to copy the effective_on and expires_on dates
# from approvals to associated child_approvals
desc 'Copy effective_on and expires_on dates from approvals to child_approvals'
task copy_approvals_effective_on_and_expires_on_dates: :environment do
  Approval.in_batches do |approvals|
    approvals.each do |approval|
      next if approval.child_approvals.empty?

      # rubocop:disable Rails/SkipsModelValidations
      approval.child_approvals.update_all(
        {
          expires_on: approval.expires_on,
          effective_on: approval.effective_on
        }
      )
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end
