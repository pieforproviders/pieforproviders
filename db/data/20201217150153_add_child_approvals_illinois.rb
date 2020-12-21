class AddChildApprovalsIllinois < ActiveRecord::Migration[6.0]
  def up
    Business.where(state: 'IL').each do |business|
      business.children.each do |child|
        ApprovalAmountGenerator.new(child, get_month_amounts(rand(1..12)), [Date::MONTHNAMES.compact - ["January", "February", "March"]].sample, '2020')
      end
    end
  end

  def get_month_amounts(x)
    amounts = []
    x.times do |x|
      amounts << { "month#{x}": { "part_days_approved_per_week": rand(1..3), "full_days_approved_per_week": rand(1..3) } }
    end
    amounts
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
