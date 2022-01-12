# frozen_string_literal: true

# Fixes Kids Can Schedules based on DHHS ID
desc 'Fixes Kids Can Schedules based on DHHS ID'
namespace :nebraska do
  task :fix_kids_can_schedules, [:options] => :environment do |_t, args|
    options = args[:options]

    puts 'Running a dry-run of the schedule fix' if options == 'dry-run'

    user = User.find_by(email: 'jgillman@kidscan.org')
    if user
      children = user.children

      # twice a day, 6a - 8:30a, 4p - 6p
      four_and_a_half_ids = %w[
        72689842
        03338324
        05121697
        03363684
        72143247
        89174737
        07958345
        35361370
        89701630
        81393806
        35675816
        25548799
        36070558
        63486909
        23614329
        10678139
        31614757
        53259873
        53921553
        99002101
        98756008
        77738001
        92944399
        34487144
        56021477
        13552599
        28360442
        24460428
        16879350
        15334035
        12276905
        28917673
        93372762
        96039797
      ]
      children.where(dhs_id: four_and_a_half_ids).map do |child|
        if options == 'dry-run'
          puts "#{child.full_name} schedules to be updated: #{child.schedules.pluck(:weekday, :duration)}"
          puts "#{child.full_name} absences to be destroyed: #{child.attendances.absences.pluck(:check_in,
                                                                                                :check_out,
                                                                                                :absence)}"
        else
          child.schedules.update_all(duration: 16_200)
          child.attendances.absences.destroy_all
        end
      end

      two_ids = %w[
        94700564
        11666250
        67028565
        21878661
        16021912
        34732432
        13474016
        27948614
        05998670
        22519516
        03655940
        94439404
        42135737
        02040705
        89785964
        20005175
        08234240
        76465422
        00624854
        62807696
        39104229
        72757517
        98693378
        76903342
        62096684
        00986422
        22393652
        61811415
        85497470
        66814162
        05016910
        12843788
        13701496
        97728128
        58151434
        51368912
        82343791
        51403264
        31524190
        67275604
        95464426
        81195445
        42263793
        51323448
        41603878
        61778978
        60261675
        64545435
        56821562
        40201834
        93025414
        58582507
        77128159
      ]
      children.where(dhs_id: two_ids).map do |child|
        if options == 'dry-run'
          puts "#{child.full_name} schedules to be updated: #{child.schedules.pluck(:weekday, :duration)}"
          puts "#{child.full_name} absences to be destroyed: #{child.attendances.absences.pluck(:check_in,
                                                                                                :check_out,
                                                                                                :absence)}"
        else
          child.schedules.update_all(duration: 7_200)
          child.attendances.absences.destroy_all
        end
      end

      Rake::Task['nebraska:fix_absences'].invoke unless options == 'dry-run'
    end
  end
end
