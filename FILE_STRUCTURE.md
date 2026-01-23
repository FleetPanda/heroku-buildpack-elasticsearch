# Buildpack File Structure

This document describes the structure and purpose of each file in the Heroku Elasticsearch buildpack.

## Core Buildpack Scripts

### `bin/detect`
The detection script that determines whether to apply this buildpack. It checks for:
- Elasticsearch-related gems in Gemfile (elasticsearch, searchkick, tire)
- Presence of `.elasticsearch-buildpack` marker file
- `ELASTICSEARCH_BUILDPACK_ENABLED` environment variable

Returns exit code 0 if applicable, 1 otherwise.

### `bin/compile`
The main compilation script that performs the buildpack transformation:
- Downloads Elasticsearch 7.10.2 binary (cached between builds)
- Extracts to `$BUILD_DIR/.elasticsearch`
- Creates `elasticsearch.yml` configuration for CI environment
- Creates `jvm.options` with reduced memory footprint (512MB heap)
- Creates startup script at `bin/heroku/elasticsearch.sh`
- Creates helper script `wait-for-elasticsearch.sh`
- Creates `.profile.d/elasticsearch.sh` for environment setup

### `bin/release`
Returns metadata for the Heroku runtime, including the default process type for Elasticsearch.

## Documentation

### `README.md`
Main documentation file covering:
- Features and overview
- How the buildpack works
- Usage instructions for different configuration methods
- Ruby on Rails integration guidance
- Development information

### `QUICK_START.md`
Fast setup guide for users who want to get running in 5 minutes. Includes:
- Step-by-step commands
- Minimal configuration examples
- Verification steps
- Common commands reference

### `INSTALLATION.md`
Detailed installation guide covering:
- Prerequisites
- Forking/cloning the buildpack
- Multiple setup methods (CLI, app.json, heroku.yml)
- Rails app configuration
- Test environment setup
- Local testing with Docker
- Troubleshooting basics

### `TROUBLESHOOTING.md`
Comprehensive troubleshooting guide including:
- Build failures and solutions
- Runtime issues
- Test failures
- Configuration problems
- Debugging tips

### `CONTRIBUTING.md`
Guidelines for community contributions:
- Code of conduct
- How to report issues
- Submission process
- Code style guidelines
- Development setup
- Areas for contribution

### `CHANGELOG.md`
Version history and release notes documenting:
- Features added in each release
- Known issues
- Planned features
- Support information

## Configuration Examples

### `app.json.example`
Example Heroku CI configuration using `app.json`:
- Buildpack specification
- Environment variables
- Formation (dyno types and quantities)
- Test scripts

### `heroku.yml.example`
Example Heroku CI configuration using `heroku.yml`:
- Docker build configuration
- Runtime process definitions
- Release phase configuration
- Test configuration

### `Procfile.ci`
Example Procfile for running Elasticsearch in CI environment.

## Ruby on Rails Examples

### `Gemfile.example`
Example Gemfile snippet showing:
- Elasticsearch client gem installation
- Alternative gems (searchkick, tire)
- Other common Rails gems

### `elasticsearch_initializer.example.rb`
Rails initializer for Elasticsearch client configuration:
- Environment-specific URL selection
- Client initialization
- Connection verification
- Helper module for common operations

### `spec_helper.example.rb`
RSpec configuration for Elasticsearch testing:
- Client setup
- Elasticsearch readiness verification
- Index cleanup between tests
- Helper methods for tests

### `post_model.example.rb`
Example Rails model with Elasticsearch integration:
- Model definition with associations
- Elasticsearch mapping and settings
- Custom serialization for indexing
- Search methods
- Automatic indexing callbacks

### `elasticsearch.rake.example`
Rake tasks for Elasticsearch management:
- Create indices task
- Delete indices task
- Cluster health check
- Reindex documents
- Clear cache

## CI/CD Integration Examples

### `github-actions-workflow.example.yml`
GitHub Actions workflow for Rails app with Elasticsearch:
- PostgreSQL service setup
- Elasticsearch service setup
- Ruby setup and dependencies
- Database initialization
- Elasticsearch readiness check
- Index creation
- Test execution
- Coverage upload

## Helper Scripts

### `test-setup.sh`
Setup script for Heroku CI test phase:
- Waits for Elasticsearch to be ready
- Verifies connection
- Runs Rails database setup
- Creates Elasticsearch indices
- Logs setup completion

## Project Files

### `LICENSE`
MIT License for the buildpack.

### `.gitignore`
Git ignore patterns for:
- Buildpack artifacts
- OS-specific files
- IDE configuration
- Ruby dependencies
- Test coverage
- Environment files

### `FILE_STRUCTURE.md`
This file - describes the purpose and contents of each file.

## Directory Structure

```
heroku-buildpack-elasticsearch/
├── bin/
│   ├── detect              # Detection script
│   ├── compile             # Compilation script
│   └── release             # Release metadata script
├── README.md               # Main documentation
├── QUICK_START.md          # Fast setup guide
├── INSTALLATION.md         # Detailed setup guide
├── TROUBLESHOOTING.md      # Issue resolution guide
├── CONTRIBUTING.md         # Contribution guidelines
├── CHANGELOG.md            # Version history
├── LICENSE                 # MIT License
├── .gitignore              # Git ignore patterns
├── FILE_STRUCTURE.md       # This file
├── Procfile.ci             # Example Procfile
├── app.json.example        # Example app.json
├── heroku.yml.example      # Example heroku.yml
├── Gemfile.example         # Example Gemfile
├── elasticsearch_initializer.example.rb
├── spec_helper.example.rb
├── post_model.example.rb
├── elasticsearch.rake.example
├── test-setup.sh           # Test setup script
└── github-actions-workflow.example.yml
```

## Getting Started

1. Start with `QUICK_START.md` for fast setup
2. Read `README.md` for overview and configuration options
3. Follow `INSTALLATION.md` for detailed step-by-step setup
4. Review example files for your specific use case
5. Consult `TROUBLESHOOTING.md` if you encounter issues
6. Check `CONTRIBUTING.md` if you want to contribute

## File Modifications

When using this buildpack with your Rails app, you'll typically:
1. Copy example files to your app directory
2. Customize them for your specific needs
3. Commit them to your repository
4. Configure Heroku with the buildpack URL

The buildpack itself should not be modified unless you're contributing improvements back to the project.
