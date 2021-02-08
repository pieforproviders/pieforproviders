# frozen_string_literal: true

task read_wonderschool_necc_attendances: :environment do
  Wonderschool::Necc::AttendanceDownloader.new.call
end
