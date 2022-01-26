# frozen_string_literal: true

# Serializer for businesses
class BusinessBlueprint < Blueprinter::Base
  identifier :id

  view :illinois_dashboard do
    field :name
    exclude :id
    association :children, name: :cases, blueprint: ChildBlueprint, view: :illinois_dashboard do |business, options|
      business.children.not_deleted.distinct.approved_for_date(options[:filter_date])
    end
  end

  view :nebraska_dashboard do
    field :name
    exclude :id
    # TODO: Multithreading? Pseudocode
    # field :children, name: :cases, blueprint: Nebraska::DashboardCaseBlueprint do |busines, options|
    #   array1, array2 = business.children.with_dashboard_case(options[:filter_date]).partition
    #   t1 = Thread.new(array1.map do |child|
    #          Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date])}
    #   end
    #   t2 = Thread.new(array2.map do |child|
    #          Nebraska::DashboardCase.new(child: child, filter_date: options[:filter_date])}
    #   end
    #   t1.join - to finalize the thread
    #   t2.join - to finalize the thread
    #   concat(t1, t2) - concat the results and pass to the blueprint
    # end
    association :children, name: :cases, blueprint: ChildBlueprint, view: :nebraska_dashboard do |business, options|
      business.children.with_dashboard_case(options[:filter_date])
    end
  end
end
