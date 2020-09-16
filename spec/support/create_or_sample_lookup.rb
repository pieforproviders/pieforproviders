# frozen_string_literal: true

# Methods for creating or getting a Lookup:: object.
# Create if needed, else pick a random sample from those that already exist.
class CreateOrSampleLookup
  DEFAULT_STATE_ATTRIBS = { name: 'Illinois', abbr: 'IL' }.freeze
  DEFAULT_COUNTY_ATTRIBS = { name: 'Some County' }.freeze
  DEFAULT_CITY_ATTRIBS = { name: 'Some City' }.freeze
  DEFAULT_ZIPCODE_ATTRIBS = { code: '99999' }.freeze

  # -------------------------------------------------------------------

  # If there are no states, then create one with these attributes.
  #  else (if there _are_ any states) get one at random (ignores the given attributes).
  # If a state must be created, use the DEFAULT_STATE_ATTRIBS to fill in
  #  any attributes not given.
  def self.random_state_or_create(state_attribs = {})
    sample_or_if_none(Lookup::State, Lookup::State.all) do
      Lookup::State.find_or_create_by!(DEFAULT_STATE_ATTRIBS.merge(state_attribs))
    end
  end

  # If there are no counties in the given state,
  #  then create one with these attributes.
  #  else (if there _are_ counties in the state),
  #   get one at random (ignores the given attributes).
  # If a county must be created, use the DEFAULT_COUNTY_ATTRIBS to fill in
  #  any attributes not given, and if a state is not given,
  #     use random_state_or_create.
  def self.random_county_or_create(county_attribs = {})
    state = county_attribs.fetch(:state, random_state_or_create)

    all_county_attribs = DEFAULT_COUNTY_ATTRIBS.merge(county_attribs).merge({ state: state })
    counties_in_state = Lookup::County.where(state: (all_county_attribs[:state]))
    sample_or_if_none(Lookup::County, counties_in_state) do
      Lookup::County.create!(all_county_attribs)
    end
  end

  # If there are no cities in the given state and county,
  #  then create one with these attributes.
  #  else (if there _are_ cities in the state and county),
  #   get one at random (ignores the given attributes).
  # If a city must be created, use the DEFAULT_CITY_ATTRIBS to fill in
  #  any attributes not given.
  #    If a state is not given, use random_state_or_create to get one.
  #    If a county is not given, use random_county_or_create to get one.
  def self.random_city_or_create(city_attribs = {})
    county_state = make_county_state_as_needed(county: city_attribs[:county], state: city_attribs[:state])
    county = county_state[:county]
    state = county_state[:state]
    all_city_attribs = DEFAULT_CITY_ATTRIBS.merge(city_attribs)
                                           .merge({ county: county, state: state })
    cities_in_state = Lookup::City.where(state: state, county: county)

    sample_or_if_none(Lookup::City, cities_in_state) do
      Lookup::City.find_or_create_by!(all_city_attribs)
    end
  end

  # If there are no zipcodes for the given city,
  #  then create one with these attributes.
  #  else (if there _are_ zipcodes in the city),
  #   get one at random (ignores the given attributes).
  # If a zipcode must be created, use the DEFAULT_ZIPCODE_ATTRIBS to fill in
  #  any attributes not given.
  #    If a city is not given, use random_city_or_create to get one.
  #    If a state is not given, use random_state_or_create to get one.
  #    If a county is not given, use random_county_or_create to get one.
  #
  def self.random_zipcode_or_create(zipcode_attribs = {})
    city_county_state = make_city_county_state_as_needed(city: zipcode_attribs[:city],
                                                         county: zipcode_attribs[:county],
                                                         state: zipcode_attribs[:state])
    all_zipcode_attribs = DEFAULT_ZIPCODE_ATTRIBS.merge(zipcode_attribs)
                                                 .merge({ city: city_county_state[:city],
                                                          county: city_county_state[:county], state: city_county_state[:state] })
    zips_in_city = Lookup::Zipcode.where(city: city_county_state[:city])
    sample_or_if_none(Lookup::Zipcode, zips_in_city) do
      Lookup::Zipcode.find_or_create_by!(all_zipcode_attribs)
    end
  end

  # If the list of items is empty OR there are no items for the klass (class),
  #  run whatever block is given (yield)
  # else
  #  pick an item at random from the list
  def self.sample_or_if_none(klass, sample_list)
    if sample_list.empty? || klass.send(:none?)
      yield
    else
      Faker::Base.sample(sample_list)
    end
  end

  def self.make_county_state_as_needed(county: nil, state: nil)
    if county.nil?
      made_state = state.nil? ? random_state_or_create : state
      made_county = random_county_or_create(state: made_state)
      { county: made_county, state: made_state }
    else
      # Always use the state of the county so we use info actually
      #   in the db (referential integrity is maintained).
      { county: county, state: county.state }
    end
  end

  def self.make_city_county_state_as_needed(city: nil, county: nil, state: nil)
    if city.nil?
      county_state = make_county_state_as_needed(county: county, state: state)
      made_county = county_state[:county]
      made_state = county_state[:state]
      made_city = random_city_or_create(state: made_state, county: made_county)
      { city: made_city, county: made_county, state: made_state }
    else
      # Always use the county and state of the city so we use info actually
      #   in the db (referential integrity is maintained).
      { city: city, county: city.county, state: city.state }
    end
  end
end
