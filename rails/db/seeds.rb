user = User.first_or_create!(
  email: ENV.fetch("TESTUSER_EMAIL", "test@test.com"),
  full_name: "Kate Donaldson"
)

child = Child.first_or_create!(
  full_name: Faker::Movies::HarryPotter.character,
  greeting_name: Faker::Name.first_name,
  date_of_birth: Faker::Date.birthday(min_age: 0, max_age: 9),
  users: [user]
)

UserChild.find_by(user: user, child: child).update_attributes(relationship: "provider")