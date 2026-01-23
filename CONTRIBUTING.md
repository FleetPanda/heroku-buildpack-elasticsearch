# Contributing

Thank you for your interest in contributing to the Heroku Elasticsearch buildpack! This document provides guidelines and instructions for contributing.

## Code of Conduct

Please be respectful and constructive in all interactions.

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request:

1. Check existing issues to avoid duplicates
2. Open a new issue with a clear description
3. Include relevant logs and error messages
4. Provide steps to reproduce the issue

### Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages: `git commit -am 'Add feature: description'`
6. Push to your fork: `git push origin feature/your-feature`
7. Open a pull request with a clear description

### Code Style

- Use bash for shell scripts
- Follow existing code style and conventions
- Add comments for complex logic
- Test scripts on both macOS and Linux

### Testing

Before submitting a PR:

1. Test the buildpack locally with Docker
2. Verify all scripts are executable
3. Check for syntax errors: `bash -n script.sh`
4. Test on a real Heroku app if possible

## Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/heroku-buildpack-elasticsearch.git
cd heroku-buildpack-elasticsearch

# Make the scripts executable
chmod +x bin/*

# Test locally
bash bin/detect /path/to/test/app
bash bin/compile /path/to/test/app /tmp/cache /tmp/env
```

## Areas for Contribution

- **Documentation**: Improve guides, add examples, fix typos
- **Features**: Add support for newer Elasticsearch versions, additional configuration options
- **Testing**: Improve test coverage, add integration tests
- **Examples**: Create more real-world examples for Rails apps
- **CI/CD**: Add support for GitHub Actions, GitLab CI, etc.

## Elasticsearch Version Updates

To update to a newer Elasticsearch version:

1. Update the version in `bin/compile`
2. Test the download URL
3. Update documentation with new version
4. Test thoroughly on Heroku
5. Update CHANGELOG

## Release Process

1. Update version in documentation
2. Update CHANGELOG
3. Create a git tag: `git tag v1.0.0`
4. Push tag: `git push origin v1.0.0`
5. Create release notes on GitHub

## Questions?

Open an issue or discussion for questions about contributing.

Thank you for helping improve this buildpack!
