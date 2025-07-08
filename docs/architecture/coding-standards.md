# Coding Standards

## Testing Framework

### Running Tests

#### All Tests
```bash
# Run all tests
bundle exec rails test
```

#### Individual Test Files
```bash
# Run a specific test file
bundle exec ruby -Itest test/models/catalyst/agent_test.rb
bundle exec ruby -Itest test/generators/catalyst/install_generator_test.rb
bundle exec ruby -Itest test/models/catalyst/execution_test.rb
```

#### Test Database Management
```bash
# Reset test database after schema changes
cd test/dummy && bundle exec rake db:migrate:reset
```

### Database Schema Updates
- When updating models or migrations, ensure test database schema is updated
- Dummy app migrations are in `test/dummy/db/migrate/`
- Both template migrations and dummy app migrations must be kept in sync

### Model Conventions
- Include concern modules (e.g., `Catalyst::Agentable`) for shared behavior

### Code Quality
- All tests must pass before committing
- Rubocop must pass before committing
