# frozen_string_literal: true

# Methods for creating or getting a Lookup:: object.
# Create if needed, else pick a random sample from those that already exist.
class CreateOrSampleLookup
  DEFAULT_STATE_INFO = { name: 'Illinois', abbr: 'IL' }.freeze
  DEFAULT_COUNTY_NAME = 'Some County'
  DEFAULT_CITY_NAME = 'Some City'
  DEFAULT_ZIPCODE = '99999'

  # -------------------------------------------------------------------

  # Create a state if there are none, else pick one at random from the db
  def self.state
    Lookup::State.none? ? Lookup::State.create(DEFAULT_STATE_INFO) : Faker::Base.sample(Lookup::State.all)
  end

  # Create a county in the given state if there are no counties in the state,
  #  else pick a county at random.
  # If no state is given, create one if needed or pick one at random.
  def self.county(state: self.state)
    counties_in_state = Lookup::County.where(state: state)
    sample_or_create(Lookup::County, counties_in_state) do
      Lookup::County.create(name: DEFAULT_COUNTY_NAME, state: state)
    end
  end

  # Create a city in the given state and county if there are no cities in there already.
  #  else pick a city at random.
  # If no state is given, create one if needed or get one at random.
  # If no county is given, create one if needed or get one at random.
  def self.city(state: self.state, county: nil)
    county = county(state: state) if county.nil?
    cities_in_state = Lookup::City.where(state: state, county: county)

    sample_or_create(Lookup::City, cities_in_state) do
      Lookup::City.create(name: DEFAULT_CITY_NAME, state: state, county: county)
    end
  end

  # Create a zipcode in the given state and city if there are no zipcode for the city already.
  #  else pick a zipcode for that city at random.
  # If no state is given, create one if needed or get one at random.
  # If no city is given, create one if needed or get one at random.
  def self.zipcode(state: self.state, city: nil)
    city = city(state: state) if city.nil?
    zips_in_city = Lookup::Zipcode.where(city: city)

    sample_or_create(Lookup::City, zips_in_city) do
      Lookup::Zipcode.create(code: DEFAULT_ZIPCODE, state: city.state, city: city, county: city.county)
    end
  end

  # If the list of items is empty OR there are no items for the klass (class),
  #  run whatever block is given (yield)
  # else
  #  pick an item at random from the list
  def self.sample_or_create(klass, sample_list)
    if sample_list.empty? || klass.send(:none?)
      yield
    else
      Faker::Base.sample(sample_list)
    end
  end
end
