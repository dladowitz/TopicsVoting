# Ruby on Rails Development Rules

## Code Quality & Linting
- Always run `rubocop` after making code changes
- Run `rubocop -a` to auto-fix simple violations when possible
- Follow Rails conventions and idioms
- Use `bundle exec` prefix for all gem commands

## Testing with RSpec
- Always run tests after making changes: `bundle exec rspec`
- Run specific test files with: `bundle exec rspec spec/path/to/spec_file.rb`
- Write tests for new features and bug fixes
- Follow RSpec best practices: use `describe`, `context`, `it` appropriately
- Use `let` for test data setup instead of instance variables
- Use `subject` when testing a single method or behavior

## Rails Conventions
- Follow RESTful routing conventions
- Use Rails helpers and built-in methods instead of custom implementations
- Follow Rails naming conventions for models, controllers, and views
- Use Rails migrations for all database schema changes
- Use Rails generators when appropriate: `rails generate controller`, `rails generate model`, etc.

## Database
- Always create database migrations for schema changes
- Run `bundle exec rails db:migrate` after creating migrations
- Use `bundle exec rails db:rollback` to undo recent migrations if needed
- Update `db/seeds.rb` if seed data changes are needed

## Development Workflow
1. Create feature branch from main
2. Make code changes following Rails conventions
3. Write/update tests
4. Run `bundle exec rspec` to ensure tests pass
5. Run `bundle exec rubocop` to check code style
6. Commit changes with descriptive messages
