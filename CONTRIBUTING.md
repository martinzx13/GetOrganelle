# Contributing to GetOrganelle Mitochondrial Assembly Project

Thank you for your interest in contributing to this project! This document provides guidelines for contributing to the GetOrganelle mitochondrial genome assembly workflow.

## Project Overview

This project provides a comprehensive workflow for assembling and annotating mitochondrial genomes from whole-genome shotgun sequencing data, with a focus on fish species using the Mitofish database.

## How to Contribute

### Types of Contributions

We welcome several types of contributions:

1. **Bug Reports**: Report issues with scripts, documentation, or workflows
2. **Feature Requests**: Suggest new features or improvements
3. **Documentation**: Improve existing documentation or add new tutorials
4. **Code**: Submit bug fixes or new features
5. **Example Data**: Share example datasets or case studies
6. **Testing**: Test workflows and report results

### Getting Started

1. **Fork the repository**
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/GetOrganelle.git
   cd GetOrganelle
   ```
3. **Create a branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

### Making Changes

#### Code Contributions

1. **Follow existing code style**:
   - Bash scripts: Use consistent indentation (2 or 4 spaces)
   - Python scripts: Follow PEP 8 guidelines
   - Add comments for complex logic

2. **Test your changes**:
   - Test scripts with sample data
   - Verify that existing workflows still work
   - Document any new dependencies

3. **Update documentation**:
   - Update README.md if adding new features
   - Add examples to TUTORIAL.md if applicable
   - Update QUICKREF.md for new commands

#### Documentation Contributions

1. **Check for accuracy**: Ensure all commands and examples work
2. **Be clear and concise**: Write for users of all skill levels
3. **Include examples**: Provide working code examples
4. **Update TOC**: If adding new sections, update table of contents

### Submitting Changes

1. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

2. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

3. **Create a Pull Request**:
   - Go to the original repository
   - Click "New Pull Request"
   - Select your branch
   - Provide a clear description of changes
   - Reference any related issues

### Pull Request Guidelines

- **Title**: Clear, concise description of changes
- **Description**: Explain what, why, and how
- **Testing**: Describe how you tested the changes
- **Documentation**: Note any documentation updates
- **Breaking Changes**: Clearly mark any breaking changes

## Code Style Guidelines

### Bash Scripts

```bash
#!/bin/bash
# 
# script_name.sh
# Brief description of what the script does
#
# Usage: bash script_name.sh ARG1 ARG2

set -e  # Exit on error
set -u  # Exit on undefined variable

# Use descriptive variable names
SAMPLE_NAME=$1
INPUT_FILE=$2

# Add comments for complex operations
# This function processes the input data
process_data() {
    local input=$1
    # Processing logic here
}
```

### Python Scripts

```python
#!/usr/bin/env python3
"""
Module/script description.

Usage:
    python script_name.py --arg1 value --arg2 value
"""

import argparse
import sys


def main():
    """Main execution function."""
    # Implementation here
    pass


if __name__ == '__main__':
    main()
```

## Testing

### Before Submitting

1. **Test scripts**: Run scripts with sample data
2. **Check documentation**: Verify all commands work
3. **Validate paths**: Ensure all file paths are correct
4. **Test cross-platform**: Test on Linux/macOS if possible

### Test Checklist

- [ ] Scripts execute without errors
- [ ] Documentation is accurate and clear
- [ ] Examples produce expected results
- [ ] No broken links in documentation
- [ ] File paths are relative or documented
- [ ] Dependencies are documented

## Documentation Standards

### README.md

- Keep overview concise but comprehensive
- Include installation instructions
- Provide quick start guide
- Link to detailed documentation

### TUTORIAL.md

- Step-by-step instructions
- Working examples
- Troubleshooting section
- Expected outputs

### Code Comments

- Explain "why" not just "what"
- Document parameters and return values
- Include usage examples in docstrings

## Reporting Issues

### Bug Reports

Include:
1. **Description**: Clear description of the bug
2. **Steps to Reproduce**: Exact steps to reproduce the issue
3. **Expected Behavior**: What you expected to happen
4. **Actual Behavior**: What actually happened
5. **Environment**: OS, software versions, etc.
6. **Logs**: Relevant error messages or logs

### Feature Requests

Include:
1. **Use Case**: Why this feature would be useful
2. **Description**: What the feature should do
3. **Examples**: How it would be used
4. **Alternatives**: Any workarounds you've considered

## Community Guidelines

### Be Respectful

- Welcome newcomers
- Be patient with questions
- Provide constructive feedback
- Respect different perspectives

### Communication

- Use clear, professional language
- Stay on topic
- Be responsive to feedback
- Acknowledge contributions

## Development Setup

### Prerequisites

```bash
# Install development dependencies
conda env create -f environment.yml
conda activate getorganelle

# Install testing tools (optional)
pip install pytest flake8
```

### Project Structure

```
GetOrganelle/
├── README.md              # Main documentation
├── TUTORIAL.md            # Detailed tutorial
├── QUICKREF.md            # Quick reference guide
├── CONTRIBUTING.md        # This file
├── LICENSE                # Project license
├── environment.yml        # Conda environment
├── requirements.txt       # Python dependencies
├── config.template        # Configuration template
├── samples.template       # Samples file template
├── .gitignore            # Git ignore rules
├── scripts/               # Workflow scripts
│   ├── setup_database.sh
│   ├── assemble_mitochondria.sh
│   └── batch_assembly.py
└── data/                 # Data directories
    ├── raw_reads/
    └── references/
```

## Additional Resources

### External Documentation

- [GetOrganelle GitHub](https://github.com/Kinggerm/GetOrganelle)
- [Mitofish Database](http://mitofish.aori.u-tokyo.ac.jp/)
- [MitoZ Documentation](https://github.com/linzhi2013/MitoZ)

### Contact

- **Issues**: Use GitHub Issues for bug reports and questions
- **Discussions**: Use GitHub Discussions for general questions

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

## Acknowledgments

Contributions of all kinds are appreciated and will be acknowledged in the project documentation.

---

Thank you for contributing to this project!
