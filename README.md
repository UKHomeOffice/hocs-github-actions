# Standardised Workflows

This repository contains a set of centrally configured, consistent and reusable CI pipeline components.


## codeql-analysis-javascript.yml
This is a [CodeQL](https://codeql.github.com/) static analysis action for javascript.
Because this is an interpreted language we don't need the `autobuild` step.
Typically, this is run on a daily schedule and on changes to source code only, ignoring test code.

### Example usage
```yaml
name: 'CodeQL'
on:
  pull_request:
    types: [ opened, reopened, synchronize ]
    paths:
      - 'src/**'
      - 'server/**'
      - 'index.js'
  schedule:
    - cron: '0 12 * * *'

jobs:
  analyze:
    uses: UKHomeOffice/hocs-ci-infrastructure/.github/workflows/codeql-analysis-javascript.yml@v1
```

## codeql-analysis-jvm.yml
This is a [CodeQL](https://codeql.github.com/) static analysis action for jvm languages.
This build can use the caching gradle actions over generic job that uses the `autobuild` step.
Typically, this is run on a daily schedule and on changes to source code only, ignoring test code.

### Example usage
```yaml
name: 'CodeQL'
on:
  pull_request:
    types: [ opened, reopened, synchronize ]
    paths:
      - 'src/main/java/**'
  schedule:
    - cron: '0 12 * * *'

jobs:
  analyze:
    uses: UKHomeOffice/hocs-ci-infrastructure/.github/workflows/codeql-analysis-jvm.yml@v1
```

## docker-build-branch.yml
A language agnostic job to build a docker image, tag it with the pull request head SHA and publish it to a repository.
To save docker repository spam this will only trigger if a label is added to the PR with the value of `smoketest`.
Currently, this is arbitrarily limited to Quay. 

### Example usage
```yaml
name: 'Docker Build Branch'
on:
  pull_request:
    types: [ labeled, opened, reopened, synchronize ]

jobs:
  build:
    uses: UKHomeOffice/hocs-ci-infrastructure/.github/workflows/docker-build-branch.yml@v1
    with:
      images: 'quay.io/ukhomeofficedigital/hocs-audit'
    secrets: inherit
```

## docker-build-tag.yml
A language agnostic job to build a docker image, tag it with a SemVer value incremented by a label (`major`, `minor`, `patch`) on the PR and publish it to a repository.
It will also tag the commit SHA with the same SemVer Tag.
To save docker repository spam this will not trigger if a label is added to the PR with the value of `skip-release`.
Currently, this is arbitrarily limited to Quay. 

### Example usage
```yaml
name: 'Docker Build Tag'
on:
  pull_request:
    types: [ closed ]

jobs:
  build:
    uses: UKHomeOffice/hocs-ci-infrastructure/.github/workflows/docker-build-tag.yml@v1
    with:
      images: 'quay.io/ukhomeofficedigital/hocs-audit'
    secrets: inherit
```

## dockerfile-lint.yml
This is only run on PRs within this repository, and is used to validate a docker-compose file on PR. 


## pr-check.yml
This action is used to ensure one of the required labels is set on a PR in order for jobs that run after the PR is merged not to fail.
It is hardcoded to ensure one of `minor`,`major`,`patch`,`skip-release` is present.

### Example usage
```yaml
name: 'PR Checker'
on:
  pull_request:
    types: [ labeled, unlabeled, opened, reopened, synchronize ]

jobs:
  check:
    uses: UKHomeOffice/hocs-ci-infrastructure/.github/workflows/pr-check.yml@v1
```

## semver-tag.yml
This is only run locally to tag the commit SHA with a SemVer value incremented by a label (`major`, `minor`, `patch`).
This will not trigger if a label is added to the PR with the value of `skip-release`.
This will also walk a 'GitHub action' style major version tag along with the SemVer value.
e.g. `v1` with tag `1.2.3`.

## test-javascript.yml
This action will run `npm run lint` and `npm test` on a repository after building it with `npm ci`.
It will run tests in parallel against 3 versions of node; `14`, `16`, `18`.
Optionally this action will install dependencies required to run tests.
Optionally this action will start components from the docker-compose to run end to end tests against.

### Example usage

```yaml
name: 'Test'
on:
  pull_request:
    types: [ opened, reopened, synchronize ]

jobs:
  test:
    uses: UKHomeOffice/hocs-ci-infrastructure/.github/workflows/test-javascript.yml@v1
    with:
      components: 'localstack postgres'
      elastic: 'true'
      dependencies: 'libreoffice curl'
```

## test-jvm.yml
This action will run a gradle build on a repository.
It currently runs on Java 17.
Optionally this action will also install dependencies required to run tests.
Optionally this action will also start components from the docker-compose to run end to end tests against.

### Example usage

```yaml
name: 'Test'
on:
  pull_request:
    types: [ opened, reopened, synchronize ]

jobs:
  test:
    uses: UKHomeOffice/hocs-ci-infrastructure/.github/workflows/test-jvm.yml@v1
    with:
      components: 'localstack postgres'
      elastic: 'true'
      dependencies: 'libreoffice curl'
```
