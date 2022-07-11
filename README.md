# HOCS CI Infrastructure


This is the HOCS CI infrastructure.
This is a repo referenced by other repos to provide centrally configured, consistent and reusable CI pipeline components. 

## Getting Started

Reference the repo workflow in `uses` definition on the calling project.
Ensure that Secrets are set to `inherit`.
```
name: 'Docker Build Branch'
on:
  pull_request:
    types: [ labeled, opened, reopened, synchronize ]

jobs:
  publish:
    uses: UKHomeOffice/hocs-github-workflows/.github/workflows/docker-build-branch.yml@main
    with:
      images: 'quay.io/ukhomeofficedigital/hocs-search'
    secrets: inherit
```

## Using the Service

### Authors

This project is authored by the Home Office.

### License

This project is licensed under the MIT license. For details please see License

This project contains public sector information licensed under the Open Government Licence v3.0. (http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/)
