# Security Policy

## Security Status

This repository contains the mercado web3 food delivery platform implementation.

**Unless a specific release states otherwise, this code has not received a full security audit.**

Use of this repository in production or production-like deployments should only happen after an independent security review of the relevant code, configuration, and deployment environment.

## Supported Versions

Security fixes are provided only for versions that are actively maintained. Experimental, archived, or deprecated code may not receive security updates.

## Bug Bounty Scope

This repository is **not** currently in scope for any paid bug bounty program.

Reports may still be reviewed through responsible disclosure, but bounty eligibility applies only where the affected repository is explicitly listed in an official bounty scope.

## What to Report

Please report a security issue only if it demonstrates realistic impact against one or more of the following:

- User funds or assets (order payments, restaurant payouts)
- Private keys, seed phrases, or signing flows
- Smart contract vulnerabilities
- Transaction construction or integrity
- Remote code execution in a realistic deployment
- Authentication or authorization bypass
- Payment data leakage

## Out of Scope

The following are generally out of scope unless they cause realistic high-impact harm:

- Issues affecting only local development environments
- Issues affecting only demo or testnet deployments
- Missing security headers on non-production apps
- Dependency vulnerability reports without a working exploit path
- Hypothetical attack paths without practical impact
- Reports that amount to "this code is unaudited"

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

To report a vulnerability, please use one of these methods:

1. **GitHub Security Advisories** (preferred): Use the "Report a vulnerability" button in the Security tab of this repository
2. **Email**: security@parity.io

Include:

- The affected file, function, or contract
- Clear reproduction steps
- Realistic impact assessment
- Any proof of concept (handle responsibly)

## Researcher Expectations

When investigating or reporting issues:

- Do not access, modify, or delete data that is not yours
- Do not disrupt services or degrade availability
- Do not publicly disclose until maintainers have had reasonable time to respond
- Do not use social engineering or physical attacks

## License

This project is licensed under GPL-3.0. See [LICENSE](./LICENSE) for details.
