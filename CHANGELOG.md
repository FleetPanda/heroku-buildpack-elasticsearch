# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-23

### Added

- Initial release of Heroku buildpack for Elasticsearch 7.10.2
- Support for Ruby on Rails applications
- Automatic detection of Elasticsearch gems in Gemfile
- Optimized configuration for CI/CD environments
- Single-node Elasticsearch cluster setup
- Configurable JVM heap size via `ES_JAVA_OPTS` environment variable
- Helper scripts for waiting for Elasticsearch startup
- `.profile.d` scripts for environment setup
- Comprehensive documentation and examples
- Example Rake tasks for index management
- Example Rails initializer for Elasticsearch client
- Example test helper for RSpec integration
- Example GitHub Actions workflow
- Support for `app.json` and `heroku.yml` configuration
- Caching of Elasticsearch binary between builds

### Features

- **bin/detect**: Detects Rails apps with Elasticsearch gems
- **bin/compile**: Downloads, extracts, and configures Elasticsearch 7.10.2
- **bin/release**: Provides process type for running Elasticsearch
- **test-setup.sh**: Waits for Elasticsearch to be ready before tests
- **wait-for-elasticsearch.sh**: Helper script to check Elasticsearch health

### Documentation

- README.md: Overview and configuration guide
- INSTALLATION.md: Step-by-step setup instructions
- QUICK_START.md: Fast setup for experienced users
- TROUBLESHOOTING.md: Common issues and solutions
- CONTRIBUTING.md: Guidelines for contributors

### Examples

- Gemfile.example: Elasticsearch gem configuration
- app.json.example: Heroku CI configuration
- heroku.yml.example: Docker-based CI configuration
- elasticsearch_initializer.example.rb: Rails initializer
- spec_helper.example.rb: RSpec configuration
- elasticsearch.rake.example: Rake tasks for index management
- post_model.example.rb: Rails model with Elasticsearch integration
- github-actions-workflow.example.yml: GitHub Actions CI workflow

## Future Versions

### Planned

- Support for Elasticsearch 8.x
- Support for multiple Elasticsearch versions
- Improved memory management
- Better error handling and recovery
- Integration with other CI/CD platforms
- Automated testing suite
- Docker image for local development

### Under Consideration

- X-Pack security support
- Elasticsearch cluster setup for multiple nodes
- Custom plugin support
- Backup and restore functionality
- Monitoring and alerting integration

## Known Issues

- Elasticsearch data is ephemeral in CI environments (by design)
- Single-node cluster only (suitable for CI)
- No persistence between builds (expected behavior)

## Support

For issues, questions, or suggestions, please open an issue on GitHub.
