task :wonderschool_necc_dashboard do
  Wonderschool::Necc::DashboardProcessor.new.call
end

task :wonderschool_necc_attendance do
  Wonderschool::Necc::AttendanceProcessor.new.call
end

task :wonderschool_necc_onboarding do
  Wonderschool::Necc::OnboardingProcessor.new.call
end

task :process_from_s3 do
  STDOUT.puts <<~INFO
    Type the number of the S3 Processor you want to run:

    1) Wonderschool NECC Dashboard
    2) Wonderschool NECC Attendances
    3) Wonderschool NECC Onboarding
    
    pressing any other key will quit
  INFO
  input = STDIN.gets.strip
  if input == '1'
    Rake::Task["wonderschool_necc_dashboard"].reenable
    Rake::Task["wonderschool_necc_dashboard"].invoke
  elsif input == '2'
    Rake::Task["wonderschool_necc_attendance"].reenable
    Rake::Task["wonderschool_necc_attendance"].invoke
  elsif input == '3'
    Rake::Task["wonderschool_necc_onboarding"].reenable
    Rake::Task["wonderschool_necc_onboarding"].invoke
  else
    STDOUT.puts "So sorry for the confusion"
  end
end